# 🚀 Quick Setup Guide

## 1. Install Flutter

### Windows:
1. Download Flutter SDK from [flutter.dev](https://docs.flutter.dev/get-started/install/windows)
2. Extract to `C:\src\flutter`
3. Add `C:\src\flutter\bin` to your PATH environment variable
4. Restart your terminal/command prompt

### macOS:
```bash
# Using Homebrew
brew install --cask flutter

# Or download from flutter.dev
```

### Linux:
```bash
# Download and extract Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz
tar xf flutter_linux_*.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
```

## 2. Verify Installation

```bash
flutter doctor
```

This should show checkmarks for:
- ✓ Flutter
- ✓ Android toolchain
- ✓ IDE (VS Code/Android Studio)

## 3. Run the Diving Game

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Or run on web
flutter run -d chrome
```

## 4. Troubleshooting

### "flutter command not found"
- Add Flutter to your system PATH
- Restart terminal after PATH changes
- On Windows: Use `where flutter` to verify

### Asset errors
- Run `flutter clean`
- Run `flutter pub get`
- Check pubspec.yaml formatting

### Dependencies issues
- Update Flutter: `flutter upgrade`
- Clear cache: `flutter pub cache repair`

## 5. Development Setup

### VS Code (Recommended):
1. Install Flutter extension
2. Install Dart extension
3. Open project folder
4. Press F5 to run

### Android Studio:
1. Install Flutter plugin
2. Install Dart plugin
3. Open project
4. Click Run button

## 6. Device Setup

### Android:
- Enable Developer Options
- Enable USB Debugging
- Connect device or start emulator

### iOS (macOS only):
- Connect iPhone/iPad
- Trust computer on device
- Run via Xcode or Flutter

### Web:
- Run `flutter run -d chrome`
- No additional setup needed

---

**Ready to dive! 🤿** 