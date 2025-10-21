# 🚀 Quick Start Guide

Get the Qurani Hafidz app running in 10 minutes!

## Prerequisites

- ✅ Flutter installed
- ✅ Python 3.12 installed
- ✅ NVIDIA GPU with CUDA support (optional but recommended)

## Backend Setup (5 minutes)

1. **Navigate to backend folder:**
   ```powershell
   cd backend
   ```

2. **Run setup script:**
   ```powershell
   .\setup.ps1
   ```
   
   Or manually:
   ```powershell
   py -3.12 -m venv venv
   venv\Scripts\activate
   pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu127
   pip install -r requirements.txt
   ```

3. **Start the server:**
   ```powershell
   uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

4. **Verify it's running:**
   Open http://localhost:8000 in your browser
   You should see: `{"message": "Qurani Recitation API", "status": "running"}`

## Flutter Setup (2 minutes)

1. **Open a new terminal and navigate to project root:**
   ```powershell
   cd ..
   ```

2. **Install dependencies:**
   ```powershell
   flutter pub get
   ```

3. **Run the app:**
   ```powershell
   flutter run
   ```

## Testing (3 minutes)

1. **Launch the app** on your device/emulator
2. **Grant microphone permission** when prompted
3. **Press the green microphone button** at the bottom
4. **Start reciting Surah Yasin** - you'll see real-time feedback!
5. **Press stop** to see your accuracy summary

## Troubleshooting

### Backend won't start
- Make sure Python 3.12 is installed: `py -3.12 --version`
- Check if port 8000 is available: `netstat -an | findstr :8000`

### Flutter build errors
- Run: `flutter clean && flutter pub get`
- Make sure Flutter SDK is up to date: `flutter upgrade`

### No audio/microphone
- Check permissions in app settings
- Try running on a real device instead of emulator

### WebSocket connection fails
- Ensure backend is running
- Check firewall settings
- Update the IP address in `lib/providers/recitation_provider.dart` if not on localhost

## Next Steps

- ✅ Read the full [README.md](README.md) for detailed documentation
- ✅ Configure Supabase for cloud storage (optional)
- ✅ Customize the app for more Surahs
- ✅ Deploy to production

## Need Help?

Check the [Troubleshooting section](README.md#troubleshooting) in the main README.

---

**Happy Reciting! 📖🎙️**
