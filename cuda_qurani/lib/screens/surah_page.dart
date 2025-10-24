import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quran_models.dart';
import '../providers/recitation_provider.dart';

class SurahPage extends StatefulWidget {
  final Surah surah;

  const SurahPage({super.key, required this.surah});

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  // Color constants from stt.backup
  static const Color primaryColor = Color(0xFF064420);
  static const Color correctColor = Color(0xFF27AE60);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color currentColor = Color(0xFF3498DB);
  static const Color warningColor = Color(0xFFF39C12);
  
  bool _hideUnreadAyat = false;  // Icon mata - hide unread
  bool _hideAllAyat = false;      // Icon buku - hide all
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,  // Abu-abu seperti screenshot
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white, size: 24),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Qurani Hafidz',
              style: TextStyle(fontSize: 16, height: 1.2),
            ),
            Text(
              'Surat ${widget.surah.name} ${widget.surah.number} - ${widget.surah.verses.length} Ayat',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      actions: [
        Consumer<RecitationProvider>(
          builder: (context, provider, _) {
            return IconButton(
              icon: Icon(
                provider.isConnected ? Icons.wifi : Icons.wifi_off,
                color: provider.isConnected ? Colors.greenAccent : Colors.redAccent,
                size: 20,
              ),
              onPressed: () async {
                if (!provider.isConnected) {
                  // Show reconnecting message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reconnecting to server...'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Attempt reconnection
                  await provider.reconnect();
                  
                  // Wait a bit
                  await Future.delayed(const Duration(milliseconds: 500));
                  
                  // Show result
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.isConnected 
                            ? 'Connected successfully!' 
                            : 'Connection failed. Please check backend server.'
                        ),
                        backgroundColor: provider.isConnected ? Colors.green : Colors.red,
                      ),
                    );
                  }
                } else {
                  // Already connected, show info
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Already connected to server'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              tooltip: provider.isConnected ? 'Connected (tap to refresh)' : 'Disconnected (tap to reconnect)',
            );
          },
        ),
        IconButton(
          icon: Icon(
            _hideAllAyat ? Icons.menu_book_outlined : Icons.menu_book,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _hideAllAyat = !_hideAllAyat;
            });
          },
          tooltip: _hideAllAyat ? 'Show Ayat' : 'Hide Ayat',
        ),
        IconButton(
          icon: Icon(
            _hideUnreadAyat ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _hideUnreadAyat = !_hideUnreadAyat;
            });
          },
          tooltip: _hideUnreadAyat ? 'Show Unread' : 'Hide Unread',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'reset') {
              _showResetSessionDialog();
            } else if (value == 'manual_test') {
              _showManualTestDialog();
            }
          },
          iconSize: 20,
          itemBuilder: (BuildContext context) => const [
            PopupMenuItem(value: 'manual_test', child: Text('Manual Test')),
            PopupMenuItem(value: 'reset', child: Text('Reset Session')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'settings', child: Text('Settings')),
            PopupMenuItem(value: 'help', child: Text('Help')),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: Center(
                  child: _buildQuranText(),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomBar(),
        ),
      ],
    );
  }

  Widget _buildQuranText() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Consumer<RecitationProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Stack(
              children: [
                // Juz and Page info
                Positioned(
                  top: 0,
                  left: 0,
                  child: Text(
                    'Juz 22',  // Hardcoded untuk contoh, bisa diganti dynamic
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    'Page 440',  // Hardcoded untuk contoh
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSurahHeader(),
                      const SizedBox(height: 16),
                      _buildBismillah(),
                      const SizedBox(height: 16),
                      _buildContinuousVerses(provider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Ornament border image (if you have it)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'سُورَة ${widget.surah.nameArabic}',
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'UthmanicHafs',
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBismillah() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontFamily: 'UthmanicHafs',
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildContinuousVerses(RecitationProvider provider) {
    List<InlineSpan> textSpans = [];
    final bool isRecording = provider.isRecording;

    // Normal order: RTL will display text on right, number on left
    for (int i = 0; i < widget.surah.verses.length; i++) {
      final verse = widget.surah.verses[i];
      final isCurrentVerse = provider.currentVerseIndex == verse.number;

      // 🎨 FIX: Get BOTH status - accuracy (verse_status) and sequence (tartib_status)
      final verseStatus = provider.verseStatus[verse.number]; // Akurasi bacaan
      final tartibStatus = provider.tartibStatus[verse.number] ?? TartibStatus.unread; // Urutan bacaan
      
      Color textColor = Colors.black87;
      Color backgroundColor = Colors.transparent;
      
      // Determine visibility and color based on ACCURACY first, then tartib
      bool shouldShow = true;
      
      // Check hide all ayat first (icon buku)
      if (_hideAllAyat) {
        // Hide all ayat, but show if already read
        final hasBeenRead = verseStatus != null || tartibStatus != TartibStatus.unread;
        if (hasBeenRead) {
          shouldShow = true;
          // 🎨 FIX: Prioritaskan AKURASI bukan urutan, dengan NULL HANDLING
          if (verseStatus == WordStatus.matched) {
            backgroundColor = correctColor.withValues(alpha: 0.2); // BENAR = HIJAU
          } else if (verseStatus == WordStatus.mismatched) {
            backgroundColor = errorColor.withValues(alpha: 0.2); // SALAH = MERAH
          } else if (tartibStatus == TartibStatus.skipped) {
            backgroundColor = warningColor.withValues(alpha: 0.2); // BELUM BACA = KUNING
          } else if (verseStatus == null && tartibStatus == TartibStatus.correct) {
            // ✅ NULL HANDLER: Ayat dibaca tapi belum dinilai (gray zone 40-60%)
            backgroundColor = warningColor.withValues(alpha: 0.1); // KUNING MUDA (pending)
          } else {
            backgroundColor = correctColor.withValues(alpha: 0.2); // Default hijau fallback
          }
        } else {
          // Unread: hide (layout tetap, text transparent)
          shouldShow = false;
          textColor = Colors.transparent;
          backgroundColor = Colors.transparent;
        }
      } else if (isRecording) {
        // ✅ FIX: During recording - support PER-WORD coloring if available
        if (isCurrentVerse && provider.currentWords.isNotEmpty) {
          // 🎨 REALTIME PER-WORD COLORING during recording
          for (int j = 0; j < provider.currentWords.length; j++) {
            final word = provider.currentWords[j];
            Color wordBg = Colors.transparent;
            
            switch (word.status) {
              case WordStatus.matched:
                wordBg = correctColor.withValues(alpha: 0.3);
                break;
              case WordStatus.mismatched:
                wordBg = errorColor.withValues(alpha: 0.3);
                break;
              case WordStatus.skipped:
                wordBg = warningColor.withValues(alpha: 0.3);
                break;
              case WordStatus.processing:
                wordBg = currentColor.withValues(alpha: 0.3); // BIRU untuk processing
                break;
              default:
                wordBg = warningColor.withValues(alpha: 0.2); // KUNING untuk pending
            }
            
            textSpans.add(
              TextSpan(
                text: word.text,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'UthmanicHafs',
                  wordSpacing: -5.9,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                  backgroundColor: wordBg,
                ),
              ),
            );
            if (j < provider.currentWords.length - 1) {
              textSpans.add(const TextSpan(text: ' '));
            }
          }
          
          // Space between verses
          if (i < widget.surah.verses.length - 1) {
            textSpans.add(const TextSpan(text: ' '));
          }
          
          continue; // Skip whole-verse rendering
        }
        
        // Fallback: Whole-verse coloring if no per-word data
        // 🎨 Prioritaskan AKURASI bukan urutan, dengan NULL HANDLING
        if (verseStatus == WordStatus.matched) {
          backgroundColor = correctColor.withValues(alpha: 0.2); // BENAR = HIJAU
          shouldShow = true;
        } else if (verseStatus == WordStatus.mismatched) {
          backgroundColor = errorColor.withValues(alpha: 0.2); // SALAH = MERAH
          shouldShow = true;
        } else if (tartibStatus == TartibStatus.skipped) {
          backgroundColor = warningColor.withValues(alpha: 0.2); // DILEWATI = KUNING
          shouldShow = true;
        } else if (verseStatus == null && tartibStatus == TartibStatus.correct) {
          // ✅ NULL HANDLER: Ayat dibaca tapi belum dinilai (gray zone 40-60%)
          backgroundColor = warningColor.withValues(alpha: 0.15); // KUNING MUDA (pending)
          shouldShow = true;
        } else if (tartibStatus == TartibStatus.unread) {
          // Hide unread based on icon mata
          shouldShow = !_hideUnreadAyat;
          if (!shouldShow) {
            textColor = Colors.transparent;
            backgroundColor = Colors.transparent;
          }
        }
      } else {
        // Not recording: show all with highlighting
        if (isCurrentVerse && provider.currentWords.isNotEmpty) {
          // Word-by-word highlighting (normal order, RTL handles display)
          for (int j = 0; j < provider.currentWords.length; j++) {
            final word = provider.currentWords[j];
            Color wordBg = Colors.transparent;
            
            switch (word.status) {
              case WordStatus.matched:
                wordBg = correctColor.withValues(alpha: 0.3);
                break;
              case WordStatus.mismatched:
                wordBg = errorColor.withValues(alpha: 0.3);
                break;
              case WordStatus.skipped:
                wordBg = warningColor.withValues(alpha: 0.3);
                break;
              default:
                wordBg = currentColor.withValues(alpha: 0.2);
            }
            
            textSpans.add(
              TextSpan(
                text: word.text,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'UthmanicHafs',
                  wordSpacing: -5.9,
                  letterSpacing: -0.5,
                  color: Colors.black87,
                  backgroundColor: wordBg,
                ),
              ),
            );
            if (j < provider.currentWords.length - 1) {
              textSpans.add(const TextSpan(text: ' '));
            }
          }
          
          // Verse number removed (using ornament only)
          // textSpans.add(const TextSpan(text: ' '));
          // textSpans.add(_buildVerseNumberSpan(verse.number, backgroundColor));
          
          // Space between verses
          if (i < widget.surah.verses.length - 1) {
            textSpans.add(const TextSpan(text: ' '));
          }
          
          continue; // Skip normal verse rendering
        }
        
        // 🎨 FIX: Normal verse status colors - PRIORITASKAN AKURASI dengan NULL HANDLING
        // Priority: 1. Accuracy (verse_status), 2. Current verse, 3. Tartib, 4. Null handler
        if (verseStatus == WordStatus.matched) {
          backgroundColor = correctColor.withValues(alpha: 0.15); // BENAR = HIJAU
        } else if (verseStatus == WordStatus.mismatched) {
          backgroundColor = errorColor.withValues(alpha: 0.15); // SALAH = MERAH
        } else if (isCurrentVerse) {
          backgroundColor = currentColor.withValues(alpha: 0.2); // SEDANG DIBACA = BIRU
        } else if (tartibStatus == TartibStatus.skipped) {
          backgroundColor = warningColor.withValues(alpha: 0.15); // DILEWATI = KUNING
        } else if (verseStatus == null && tartibStatus == TartibStatus.correct) {
          // ✅ NULL HANDLER: Ayat dibaca tapi belum dinilai (gray zone 40-60%)
          backgroundColor = warningColor.withValues(alpha: 0.08); // KUNING SANGAT MUDA (pending)
        }
      }

      // Verse text first (will appear on right in RTL)
      textSpans.add(
        TextSpan(
          text: verse.text,
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'UthmanicHafs',
            wordSpacing: -5.9,
            letterSpacing: -0.5,
            color: shouldShow ? textColor : Colors.transparent,
            backgroundColor: shouldShow ? backgroundColor : Colors.transparent,
          ),
        ),
      );

      // Verse number removed (using ornament only)
      // textSpans.add(const TextSpan(text: ' '));
      // textSpans.add(_buildVerseNumberSpan(verse.number, backgroundColor));

      // Space between verses
      if (i < widget.surah.verses.length - 1) {
        textSpans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 24,
          fontFamily: 'UthmanicHafs',
          wordSpacing: -5.9,
          letterSpacing: -0.5,
          color: Colors.black87,
        ),
        children: textSpans,
      ),
    );
  }

  WidgetSpan _buildVerseNumberSpan(int number, Color bgColor) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.3),
            width: 1,
          ),
          color: bgColor != Colors.transparent ? bgColor.withValues(alpha: 0.3) : Colors.transparent,
        ),
        child: Text(
          _toArabicNumerals(number),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const Map<String, String> arabicNumerals = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };
    return number.toString().split('').map((digit) => arabicNumerals[digit] ?? digit).join('');
  }

  Widget _buildBottomBar() {
    return Container(
      height: 90,
      color: Colors.transparent,
      child: Stack(
        children: [
          // Mic button (center, green)
          Positioned(
            bottom: 25,
            left: 0,
            right: 0,
            child: Center(
              child: Consumer<RecitationProvider>(
                builder: (context, provider, _) {
                  return Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: provider.isRecording ? errorColor : primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (provider.isRecording ? errorColor : primaryColor).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(32.5),
                        onTap: () async {
                          try {
                            if (provider.isRecording) {
                              // Stop recording
                              await provider.stopRecitation();
                            } else {
                              // ✅ FIX: Force sync state from service BEFORE checking
                              // This prevents stale state after navigation
                              final serviceConnected = provider.isServiceConnected;
                              print('🔍 Button pressed:');
                              print('   - provider.isConnected = ${provider.isConnected}');
                              print('   - service.isConnected = $serviceConnected');
                              
                              final needReconnect = !serviceConnected;
                              print('   - needReconnect = $needReconnect');
                              
                              if (needReconnect) {
                                // Show connecting message
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Connecting to server...'),
                                      backgroundColor: Colors.orange,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                                
                                // Try to reconnect
                                print('🔌 Reconnecting...');
                                await provider.reconnect();
                                
                                // Wait a bit for connection to establish
                                await Future.delayed(const Duration(milliseconds: 500));
                                
                                // Check if connected now (sync from service)
                                if (!provider.isConnected) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Could not connect to server. Please try again.'),
                                        backgroundColor: Colors.red,
                                        action: SnackBarAction(
                                          label: 'Retry',
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            await provider.reconnect();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                  return; // Don't start if not connected
                                }
                              } else {
                                print('✅ Connection verified, skipping reconnect');
                              }
                              
                              // Start recitation with surah number
                              print('🎤 Starting recitation...');
                              await provider.startRecitation(widget.surah.number);
                              
                              if (mounted && provider.isRecording) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Recording started'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  action: SnackBarAction(
                                    label: 'Retry',
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      // Clear error and try reconnect
                                      provider.clearError();
                                      await provider.reconnect();
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              provider.isRecording ? Icons.stop : Icons.mic,
                              key: ValueKey(provider.isRecording),
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetSessionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Session'),
          content: const Text('Are you sure you want to reset the current recitation session? All progress will be cleared.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<RecitationProvider>(
              builder: (context, provider, _) {
                return TextButton(
                  onPressed: () async {
                    // Stop current recording if active
                    if (provider.isRecording) {
                      await provider.stopRecitation();
                      await Future.delayed(const Duration(milliseconds: 300));
                    }
                    
                    // Clear error if any
                    provider.clearError();
                    
                    // Force reconnect to get fresh session
                    if (provider.isConnected) {
                      await provider.reconnect();
                    }
                    
                    Navigator.of(context).pop();
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session reset. Press mic to start new session.'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Reset', style: TextStyle(color: Colors.red)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showManualTestDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manual Test'),
          content: const Text('Send a test transcript to the backend for testing purposes.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Consumer<RecitationProvider>(
              builder: (context, provider, _) {
                return TextButton(
                  onPressed: () {
                    // Send manual test if provider has method
                    // For now just show confirmation
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manual test sent'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  child: const Text('Send Test'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
