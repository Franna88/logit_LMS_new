# 🛠️ Development Guide

## Quick Start

1. **Install Flutter** (if not already installed):
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## 🏗️ Architecture Overview

### State Management
- **Provider Pattern**: Used for game state management
- **GameStateProvider**: Central state management for boat position, POIs, courses, and player money
- **Reactive UI**: Widgets automatically update when state changes

### File Structure
```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── diving_course.dart       # Course data structure
│   └── poi.dart                # Point of Interest model
├── screens/                     # UI screens
│   └── game_map_screen.dart    # Main game interface
├── services/                    # Business logic
│   └── game_state_provider.dart # State management
└── widgets/                     # Reusable components
    ├── boat_widget.dart        # Animated boat
    ├── poi_marker.dart         # Map markers
    ├── course_popup.dart       # Course selection dialog
    └── game_ui_overlay.dart    # HUD overlay
```

## 🎮 Game Mechanics

### Boat Movement
- Tap POI → Boat animates to location
- Smooth interpolation using `AnimatedPositioned`
- Wave bobbing effect with `Transform.translate`

### Course System
- Purchase courses with in-game currency
- Track completion progress
- Persistent save system using `SharedPreferences`

### Visual Effects
- Ocean gradient background
- Animated wave patterns using `CustomPainter`
- Smooth UI transitions with `flutter_animate`

## 🎨 Customization

### Adding New POIs
1. Open `lib/services/game_state_provider.dart`
2. Add new POI to `_createInitialPOIs()` method:
```dart
POI(
  id: 'unique_id',
  name: 'Location Name',
  description: 'Description text',
  x: 0.3, // Map position (0.0-1.0)
  y: 0.6,
  type: 'location_type',
  backgroundImage: 'assets/images/background.jpg',
  courses: [/* course list */],
)
```

### Adding New Courses
```dart
DivingCourse(
  id: 'course_id',
  title: 'Course Title',
  description: 'Course description',
  price: 199.99,
  difficulty: 'Beginner|Intermediate|Advanced',
  duration: 120, // minutes
  topics: ['Topic 1', 'Topic 2'],
  iconPath: 'assets/icons/course_icon.png',
)
```

### Styling
- Colors defined in `lib/main.dart` theme
- Custom gradients in individual widgets
- Consistent spacing using multiples of 8

## 🔧 Development Tips

### Hot Reload
- Save files to see changes instantly
- Use `r` in terminal to hot reload
- Use `R` for hot restart

### Debugging
- Use `print()` statements for simple debugging
- Flutter Inspector for widget tree analysis
- `flutter logs` for device logs

### Performance
- Use `const` constructors where possible
- Minimize widget rebuilds with proper state management
- Profile with `flutter run --profile`

## 📱 Testing

### Running Tests
```bash
flutter test
```

### Device Testing
```bash
flutter run -d <device_id>
```

### Build for Release
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🐛 Common Issues

### Dependencies
- Run `flutter clean && flutter pub get` if packages fail
- Check Flutter version compatibility

### Assets
- Ensure assets are listed in `pubspec.yaml`
- Check file paths and extensions
- Run `flutter pub get` after adding assets

### State Management
- Use `notifyListeners()` after state changes
- Wrap widgets with `Consumer<GameStateProvider>`
- Check provider is properly initialized

## 🚀 Deployment

### Android
1. Update `android/app/build.gradle` version
2. Generate signed APK: `flutter build apk --release`
3. Upload to Google Play Console

### iOS
1. Update version in `ios/Runner/Info.plist`
2. Build: `flutter build ios --release`
3. Archive in Xcode and upload to App Store

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature-name`
3. Make changes and test thoroughly
4. Commit: `git commit -m "Add feature"`
5. Push: `git push origin feature-name`
6. Create Pull Request

## 📝 Code Style

- Use `dart format` for consistent formatting
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Add comments for complex logic
- Use meaningful variable names

---

Happy coding! 🚀 