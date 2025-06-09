# 🌊 Diving Course Adventure

A fun and interactive Flutter mini game for learning diving courses! Navigate your boat through beautiful ocean waters, discover diving locations, and purchase courses to become a certified diver.

## 🎮 Game Features

### 🗺️ Interactive Map
- Beautiful ocean environment with animated waves
- Multiple Points of Interest (POIs) including islands, coral reefs, shipwrecks, and deep water locations
- Smooth boat animations that sail between locations

### 🚢 Boat Navigation
- Tap on any POI to sail your boat there
- Smooth animations with realistic boat movement
- Wave effects and boat bobbing for immersive experience

### 🏊‍♂️ Diving Courses
- **Open Water Diver** - Perfect for beginners
- **Advanced Open Water** - Expand your skills
- **Marine Biology Specialty** - Learn about underwater ecosystems
- **Wreck Diver Specialty** - Explore underwater history
- **Deep Diver Specialty** - Master deep water techniques

### 💰 Game Economy
- Start with $500 to purchase courses
- Earn money by completing courses
- Track your progress and spending

### 📱 Modern UI
- Beautiful gradients and animations
- Responsive design for all screen sizes
- Game-like interface with progress tracking
- Smooth transitions and effects

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point with splash screen
├── models/                   # Data models
│   ├── diving_course.dart    # Course data structure
│   └── poi.dart             # Point of Interest model
├── screens/                  # Game screens
│   └── game_map_screen.dart # Main game map interface
├── services/                 # Business logic
│   └── game_state_provider.dart # Game state management
├── widgets/                  # Reusable UI components
│   ├── boat_widget.dart     # Animated boat component
│   ├── poi_marker.dart      # POI markers on map
│   ├── course_popup.dart    # Course selection dialog
│   └── game_ui_overlay.dart # HUD overlay
├── animations/              # Custom animations
└── utils/                   # Utility functions
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd logit
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📦 Dependencies

- **provider**: State management
- **flutter_animate**: Smooth animations and transitions
- **flutter_svg**: SVG graphics support
- **shared_preferences**: Local data persistence
- **flutter_custom_clippers**: Custom UI shapes

## 🎨 Assets Required

To complete the visual experience, add these assets:

### Images (`assets/images/`)
- `tropical_island.jpg` - Tropical island background
- `coral_reef.jpg` - Coral reef environment
- `shipwreck.jpg` - Underwater shipwreck
- `deep_blue.jpg` - Deep ocean waters

### Icons (`assets/icons/`)
- `open_water.png` - Open Water course icon
- `advanced.png` - Advanced course icon
- `marine_bio.png` - Marine Biology course icon
- `wreck.png` - Wreck diving course icon
- `deep_diving.png` - Deep diving course icon

### Fonts (`assets/fonts/`)
- `Roboto-Regular.ttf`
- `Roboto-Bold.ttf`

## 🎯 Game Flow

1. **Splash Screen**: Welcome animation with diving theme
2. **Main Map**: Ocean view with boat and POI markers
3. **Navigation**: Tap POIs to sail boat with smooth animation
4. **Course Selection**: Popup showing available courses at location
5. **Purchase/Start**: Buy new courses or start purchased ones
6. **Progress Tracking**: Visual indicators for course completion

## 🔧 Customization

### Adding New POIs
```dart
POI(
  id: 'new_location',
  name: 'New Diving Spot',
  description: 'Description of the location',
  x: 0.6, // Position on map (0.0 to 1.0)
  y: 0.4,
  type: 'custom_type',
  backgroundImage: 'assets/images/new_location.jpg',
  courses: [/* your courses */],
)
```

### Adding New Courses
```dart
DivingCourse(
  id: 'new_course',
  title: 'New Specialty Course',
  description: 'Course description',
  price: 199.99,
  difficulty: 'Intermediate',
  duration: 120,
  topics: ['Topic 1', 'Topic 2'],
  iconPath: 'assets/icons/new_course.png',
)
```

## 🎮 Game Mechanics

- **Money System**: Start with $500, spend on courses, earn by completing them
- **Progress Tracking**: Visual progress bars and completion indicators
- **Save System**: Game state persists between sessions
- **Animations**: Smooth boat movement, wave effects, UI transitions

## 🌟 Future Enhancements

- [ ] Course content with interactive lessons
- [ ] Achievement system
- [ ] Multiplayer features
- [ ] More diving locations
- [ ] Weather effects
- [ ] Day/night cycle
- [ ] Marine life encounters
- [ ] Equipment management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Diving community for inspiration
- Contributors and testers

---

**Happy Diving! 🤿**
