# 🕌 Qurani Hafidz - AI-Powered Quran Recitation App

A real-time Quran recitation app with AI feedback, inspired by Tarteel. Built with Flutter, FastAPI, Whisper AI, and Supabase.

## ✨ Features

- 🎙️ **Real-time Audio Recording** - Stream audio directly to backend
- 🤖 **GPU-Accelerated Whisper** - Fast Arabic speech recognition
- ✅ **Word-Level Feedback** - Live color-coded highlighting (matched/mismatched/skipped)
- 📊 **Accuracy Tracking** - Detailed recitation statistics
- ☁️ **Cloud Storage** - Session history stored in Supabase
- 🎨 **Beautiful UI** - Clean Material Design matching Qurani Hafidz aesthetic

## 🏗️ Architecture

```
┌─────────────────┐         WebSocket         ┌──────────────────┐
│  Flutter App    │◄──────────────────────────►│   FastAPI        │
│  (Mobile)       │      Real-time Audio       │   Backend        │
└─────────────────┘                            └──────────────────┘
                                                        │
                                                        ├─► Whisper (GPU)
                                                        ├─► VAD Service
                                                        ├─► Text Aligner
                                                        └─► Supabase REST API
```

## 📋 Prerequisites

### For Flutter Frontend:
- Flutter SDK 3.9.0+
- Android Studio / VS Code
- Android SDK (for Android) or Xcode (for iOS)

### For Python Backend:
- Python 3.12+
- CUDA-compatible GPU (recommended: RTX 3050 or better)
- CUDA Toolkit 12.7
- 8GB+ RAM

## 🚀 Setup Instructions

### 1. Backend Setup

#### Step 1: Create Virtual Environment

```powershell
cd backend
py -3.12 -m venv venv
venv\Scripts\activate
```

#### Step 2: Install PyTorch with CUDA Support

```powershell
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu127
```

#### Step 3: Install Other Dependencies

```powershell
pip install -r requirements.txt
```

#### Step 4: Configure Environment Variables

```powershell
cp .env.example .env
```

Edit `.env` with your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your_service_role_key_here
```

#### Step 5: Run Backend Server

```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Verify GPU is working:**
Visit http://localhost:8000 - you should see `"gpu_available": true`

### 2. Frontend Setup

#### Step 1: Install Dependencies

```powershell
flutter pub get
```

#### Step 2: Configure Backend URL

Edit `lib/providers/recitation_provider.dart` if backend is not on localhost:

```dart
RecitationProvider({String serverUrl = 'ws://YOUR_IP:8000/ws/recite'})
```

#### Step 3: Run Flutter App

```powershell
flutter run
```

### 3. Supabase Setup (Optional)

Create tables in Supabase:

```sql
-- Sessions table
CREATE TABLE sessions (
  id BIGSERIAL PRIMARY KEY,
  session_id TEXT UNIQUE NOT NULL,
  surah INTEGER NOT NULL,
  matched FLOAT NOT NULL,
  errors FLOAT NOT NULL,
  skipped FLOAT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Transcripts table
CREATE TABLE transcripts (
  id BIGSERIAL PRIMARY KEY,
  session_id TEXT REFERENCES sessions(session_id),
  word TEXT NOT NULL,
  status TEXT NOT NULL,
  score FLOAT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Logs table
CREATE TABLE logs (
  id BIGSERIAL PRIMARY KEY,
  session_id TEXT REFERENCES sessions(session_id),
  details JSONB,
  timestamp TIMESTAMPTZ DEFAULT NOW()
);
```

## 🎯 Usage

1. **Launch the app** - Opens to Surah Yasin by default
2. **Press the microphone button** - Starts recording and streaming
3. **Recite verses** - See real-time word highlighting:
   - 🟢 Green = Correct (≥60% match)
   - 🔴 Red = Error (30-59% match)
   - ⚪ Gray = Skipped (<30% match)
4. **Press stop** - View accuracy summary and save to history

## 🔧 Configuration

### Whisper Model

To use the Tarteel-specific Quran model:

```python
# In backend/app/whisper_service.py
# Download model from huggingface.co/tarteel-ai/whisper-base-ar-quran
# Update model loading:
self.model = whisper.load_model("path/to/tarteel-model")
```

### Performance Tuning

For RTX 3050 or lower-end GPUs:

```python
# In backend/app/whisper_service.py
# Use smaller model
self.model = whisper.load_model("tiny")  # or "base"

# Adjust chunk duration in main.py
chunk_duration = 2.0  # Reduce from 3.0 for faster feedback
```

## 📁 Project Structure

```
cuda_qurani/
├── lib/                          # Flutter app
│   ├── models/                   # Data models
│   ├── providers/                # State management
│   ├── screens/                  # UI screens
│   └── services/                 # Backend services
├── backend/                      # Python backend
│   └── app/
│       ├── main.py              # FastAPI app
│       ├── whisper_service.py   # Whisper inference
│       ├── text_alignment.py    # Text comparison
│       ├── vad_service.py       # Voice detection
│       └── supabase_client.py   # Database client
├── assets/
│   └── data/
│       └── surah_yasin.json     # Quran reference data
└── README.md
```

## 🐛 Troubleshooting

### GPU Not Detected

```powershell
# Check CUDA installation
python -c "import torch; print(torch.cuda.is_available())"
```

If False, reinstall PyTorch with correct CUDA version.

### WebSocket Connection Failed

- Ensure backend is running on correct port
- Check firewall settings
- Update `serverUrl` in Flutter app to correct IP

### Audio Recording Issues

- Grant microphone permissions in app settings
- Test with different audio sample rates
- Check Android permissions in `AndroidManifest.xml`

## 🚢 Deployment

### Backend Deployment Options:

1. **RunPod** - GPU instances starting at $0.20/hr
2. **AWS EC2 (G4 instances)** - Production-grade GPU
3. **Google Cloud** - GPU-enabled Compute Engine
4. **Local Server** - Run on your gaming PC

### Flutter App Deployment:

```powershell
# Android APK
flutter build apk --release

# iOS (requires macOS)
flutter build ios --release
```

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- [ ] Add more Surahs
- [ ] Implement Tajweed feedback
- [ ] Offline mode support
- [ ] User authentication
- [ ] Progress tracking dashboard

## 📄 License

This project is created for educational purposes.

## 🙏 Acknowledgments

- **Tarteel.ai** - Inspiration and Whisper Arabic model
- **OpenAI Whisper** - Speech recognition
- **Supabase** - Backend database
- **Flutter** - Cross-platform framework

---

**Built with ❤️ for the Muslim community**
