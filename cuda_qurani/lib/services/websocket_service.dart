import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  // ✅ SINGLETON PATTERN - Fix memory leak on hot restart
  static WebSocketService? _instance;
  
  // Factory constructor - always return same instance
  factory WebSocketService({String? serverUrl}) {
    if (_instance != null) {
      print('♻️ WebSocketService: Reusing existing singleton instance');
      return _instance!;
    }
    
    print('🆕 WebSocketService: Creating new singleton instance');
    _instance = WebSocketService._internal(
      serverUrl: serverUrl ?? 'ws://192.168.0.185:8000/ws/recite',
    );
    
    return _instance!;
  }
  
  // Private constructor
  WebSocketService._internal({required this.serverUrl});
  
  // Reset singleton (for testing only)
  static void resetInstance() {
    print('🔄 WebSocketService: Resetting singleton instance');
    _instance?.dispose();
    _instance = null;
  }
  
  WebSocketChannel? _channel;
  final String serverUrl;
  StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messages {
    // ✅ FIX: Recreate controller if closed
    if (_messageController.isClosed) {
      print('⚠️ WebSocketService: Message controller was closed, recreating...');
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
    }
    print('🎧 WebSocketService: messages getter called (has listeners: ${_messageController.hasListener})');
    return _messageController.stream;
  }
  
  Stream<bool> get connectionStatus {
    // ✅ FIX: Recreate controller if closed
    if (_connectionStatusController.isClosed) {
      print('⚠️ WebSocketService: Connection controller was closed, recreating...');
      _connectionStatusController = StreamController<bool>.broadcast();
    }
    return _connectionStatusController.stream;
  }
  bool _isConnected = false;
  bool _isReconnecting = false;
  bool _shouldAutoReconnect = true;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 3);

  bool get isConnected => _isConnected;
  bool get isReconnecting => _isReconnecting;

  Future<void> connect() async {
    if (_isConnected || _isReconnecting) {
      print('⚠️ WebSocket: Already connected or reconnecting, skipping...');
      return;
    }

    print('🔌 WebSocket: Attempting to connect to $serverUrl');
    
    // ✅ FIX: Recreate controllers if closed
    if (_messageController.isClosed) {
      print('🔄 WebSocket: Recreating closed message controller...');
      _messageController = StreamController<Map<String, dynamic>>.broadcast();
    }
    if (_connectionStatusController.isClosed) {
      print('🔄 WebSocket: Recreating closed connection controller...');
      _connectionStatusController = StreamController<bool>.broadcast();
    }
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;
      _isReconnecting = false;
      _reconnectAttempts = 0;
      _connectionStatusController.add(true);
      print('✅ WebSocket connected successfully');

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            
            // 📥 Log backend responses
            final msgType = data['type'] ?? 'unknown';
            if (msgType == 'started') {
              print('📥 Backend: Session STARTED (expected_ayah: ${data['expected_ayah']})');
            } else if (msgType == 'progress') {
              print('📥 Backend: PROGRESS (ayah: ${data['ayah']}, expected: ${data['expected_ayah']})');
            } else if (msgType == 'summary') {
              print('📥 Backend: SUMMARY received');
            } else if (msgType == 'error') {
              print('❌ Backend ERROR: ${data['message']}');
            } else {
              print('📥 Backend: $msgType');
            }
            
            print('📡 WebSocketService: Adding message to controller (hasListener: ${_messageController.hasListener})');
            _messageController.add(data);
            print('✅ WebSocketService: Message added successfully');
          } catch (e) {
            print('❌ Error parsing message: $e');
          }
        },
        onDone: () {
          _handleDisconnection('Connection closed by server');
        },
        onError: (error) {
          _handleDisconnection('WebSocket error: $error');
        },
      );
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add(false);
      print('Failed to connect: $e');
      
      if (_shouldAutoReconnect) {
        _scheduleReconnection();
      }
      rethrow;
    }
  }

  void _handleDisconnection(String reason) {
    if (!_isConnected) return;
    
    _isConnected = false;
    _connectionStatusController.add(false);
    print('WebSocket disconnected: $reason');
    
    if (_shouldAutoReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnection();
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      print('Max reconnection attempts reached. Stopping auto-reconnect.');
    }
  }
  
  void _scheduleReconnection() {
    if (_isReconnecting) return;
    
    _isReconnecting = true;
    _reconnectAttempts++;
    
    print('Scheduling reconnection attempt ${_reconnectAttempts}/${_maxReconnectAttempts} in ${_reconnectDelay.inSeconds} seconds...');
    
    _reconnectTimer = Timer(_reconnectDelay, () async {
      try {
        await connect();
      } catch (e) {
        print('Reconnection attempt ${_reconnectAttempts} failed: $e');
        _isReconnecting = false;
      }
    });
  }
  
  void enableAutoReconnect() {
    _shouldAutoReconnect = true;
  }
  
  void disableAutoReconnect() {
    _shouldAutoReconnect = false;
    _reconnectTimer?.cancel();
    _isReconnecting = false;
  }

  int _audioChunksSent = 0;
  
  void sendAudioChunk(String base64Audio) {
    if (_isConnected && _channel != null) {
      _audioChunksSent++;
      final message = jsonEncode({
        'type': 'audio',
        'data': base64Audio,
      });
      _channel!.sink.add(message);
      
      // 📤 Log every 10 chunks to avoid spam
      if (_audioChunksSent % 10 == 1) {
        print('📤 WebSocket: Sent audio chunk #$_audioChunksSent (${base64Audio.length} chars)');
      }
    } else {
      print('❌ Cannot send audio chunk: WebSocket not connected');
      if (_shouldAutoReconnect && !_isReconnecting) {
        _scheduleReconnection();
      }
    }
  }

  void sendStartRecording(int surahNumber) {
    if (_isConnected && _channel != null) {
      _audioChunksSent = 0; // Reset counter
      final message = jsonEncode({
        'type': 'start',
        'surah': surahNumber,
      });
      _channel!.sink.add(message);
      print('🚀 WebSocket: Sent START command for Surah $surahNumber');
    } else {
      print('❌ Cannot start recording: WebSocket not connected');
      if (_shouldAutoReconnect && !_isReconnecting) {
        _scheduleReconnection();
      }
    }
  }

  void sendStopRecording() {
    if (_isConnected && _channel != null) {
      final message = jsonEncode({
        'type': 'stop',
      });
      _channel!.sink.add(message);
      print('🛑 WebSocket: Sent STOP command (Total chunks sent: $_audioChunksSent)');
    } else {
      print('❌ Cannot stop recording: WebSocket not connected');
    }
  }
  
  void sendRecoverSession(String sessionId) {
    if (_isConnected && _channel != null) {
      final message = jsonEncode({
        'type': 'recover',
        'session_id': sessionId,
      });
      _channel!.sink.add(message);
      print('🔁 WebSocket: Sent SESSION RECOVERY request (session_id: $sessionId)');
    } else {
      print('❌ Cannot recover session: WebSocket not connected');
    }
  }
  
  void sendHeartbeat() {
    if (_isConnected && _channel != null) {
      final message = jsonEncode({
        'type': 'heartbeat',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      _channel!.sink.add(message);
      print('💓 WebSocket: Sent HEARTBEAT');
    }
  }

  void disconnect() {
    // 🔍 DEBUG: Print stack trace to find WHO called disconnect
    print('🔌 WebSocket: Disconnecting...');
    print('📍 DISCONNECT CALLED FROM:');
    print(StackTrace.current);
    
    _shouldAutoReconnect = false;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;  // ✅ Clear channel reference
    _isConnected = false;
    _isReconnecting = false;
    _reconnectAttempts = 0;  // ✅ Reset reconnect counter
    
    // ✅ FIX: Only add event if controller is not closed
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(false);
    }
    print('🔌 WebSocket: Disconnected and cleaned up');
  }

  void dispose() {
    print('🗑️ WebSocketService: dispose() called - DO NOT dispose singleton!');
    print('📍 DISPOSE CALLED FROM:');
    print(StackTrace.current);
    
    // ✅ DON'T close controllers or disconnect for singleton!
    // Singleton should live throughout app lifecycle
    // disconnect();
    // _messageController.close();
    // _connectionStatusController.close();
  }
}
