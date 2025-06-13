import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/poi.dart';
import '../models/diving_course.dart';

class GameStateProvider extends ChangeNotifier {
  List<POI> _pois = [];
  POI? _selectedPOI;
  bool _isBoatMoving = false;
  double _boatX = 0.5; // Starting position (center of map)
  double _boatY = 0.8; // Starting position (bottom of map)
  double _playerMoney = 500.0; // Starting money
  String? _selectedLearningHouse; // Store selected learning house

  // Getters
  List<POI> get pois => _pois;
  List<POI> get pointsOfInterest => _pois; // Alias for compatibility
  POI? get selectedPOI => _selectedPOI;
  bool get isBoatMoving => _isBoatMoving;
  double get boatX => _boatX;
  double get boatY => _boatY;
  double get playerMoney => _playerMoney;
  String? get selectedLearningHouse => _selectedLearningHouse;

  GameStateProvider() {
    _initializeGame();
  }

  void _initializeGame() {
    _createInitialPOIs();
    _loadGameState();
  }

  void _createInitialPOIs() {
    _pois = [
      POI(
        id: 'tropical_island',
        name: 'Base Camp Hub',
        description: 'Your diving headquarters - manage account, funds & settings',
        x: 0.15,
        y: 0.25,
        type: 'island',
        backgroundImage: 'assets/images/tropical_island.jpg',
        courses: [], // No courses - this is now the hub
      ),
      POI(
        id: 'coral_reef',
        name: 'Photography',
        description: 'Master underwater photography techniques and composition',
        x: 0.75,
        y: 0.35,
        type: 'reef',
        backgroundImage: 'assets/images/coral_reef.jpg',
        courses: [
          DivingCourse(
            id: 'marine_biology',
            title: 'Marine Biology Specialty',
            description: 'Learn about underwater ecosystems',
            price: 199.99,
            difficulty: 'Intermediate',
            duration: 90,
            topics: ['Marine Life', 'Coral Identification', 'Ecosystem', 'Conservation'],
            iconPath: 'assets/icons/marine_bio.png',
          ),
          DivingCourse(
            id: 'underwater_photography',
            title: 'Underwater Photography',
            description: 'Master the art of underwater photography',
            price: 249.99,
            difficulty: 'Intermediate',
            duration: 120,
            topics: ['Camera Settings', 'Lighting', 'Composition', 'Marine Subjects'],
            iconPath: 'assets/icons/photography.png',
          ),
          DivingCourse(
            id: 'macro_photography',
            title: 'Macro Photography Specialist',
            description: 'Capture stunning close-up images of small marine life',
            price: 179.99,
            difficulty: 'Advanced',
            duration: 100,
            topics: ['Macro Techniques', 'Lens Selection', 'Lighting Setup', 'Subject Approach'],
            iconPath: 'assets/icons/macro.png',
          ),
          DivingCourse(
            id: 'digital_imaging',
            title: 'Digital Underwater Imaging',
            description: 'Modern digital photography and video techniques',
            price: 299.99,
            difficulty: 'Advanced',
            duration: 150,
            topics: ['Digital Sensors', 'Post Processing', 'Video Recording', 'Image Management'],
            iconPath: 'assets/icons/digital.png',
          ),
        ],
      ),
      POI(
        id: 'shipwreck',
        name: 'Sunken Treasure',
        description: 'Historic shipwreck from the 18th century',
        x: 0.5,
        y: 0.45,
        type: 'wreck',
        backgroundImage: 'assets/images/shipwreck.jpg',
        courses: [
          DivingCourse(
            id: 'wreck_diving',
            title: 'Wreck Diver Specialty',
            description: 'Explore underwater history safely',
            price: 179.99,
            difficulty: 'Advanced',
            duration: 150,
            topics: ['Wreck Penetration', 'Safety', 'History', 'Photography'],
            iconPath: 'assets/icons/wreck.png',
          ),
          DivingCourse(
            id: 'advanced_wreck',
            title: 'Advanced Wreck Diving',
            description: 'Master complex wreck penetration techniques',
            price: 329.99,
            difficulty: 'Advanced',
            duration: 200,
            topics: ['Deep Penetration', 'Navigation', 'Emergency Procedures', 'Technical Equipment'],
            iconPath: 'assets/icons/advanced_wreck.png',
          ),
          DivingCourse(
            id: 'wreck_archaeology',
            title: 'Maritime Archaeology',
            description: 'Learn archaeological techniques for wreck exploration',
            price: 199.99,
            difficulty: 'Intermediate',
            duration: 130,
            topics: ['Historical Research', 'Artifact Recovery', 'Documentation', 'Preservation'],
            iconPath: 'assets/icons/archaeology.png',
          ),
          DivingCourse(
            id: 'treasure_hunting',
            title: 'Treasure Hunter Certification',
            description: 'Professional treasure hunting and recovery methods',
            price: 399.99,
            difficulty: 'Advanced',
            duration: 180,
            topics: ['Metal Detection', 'Recovery Techniques', 'Legal Aspects', 'Valuation'],
            iconPath: 'assets/icons/treasure.png',
          ),
        ],
      ),
      POI(
        id: 'deep_blue',
        name: 'The Deep Blue',
        description: 'Challenge yourself in the deepest waters',
        x: 0.85,
        y: 0.65,
        type: 'deep_water',
        backgroundImage: 'assets/images/deep_blue.jpg',
        courses: [
          DivingCourse(
            id: 'deep_diving',
            title: 'Deep Diver Specialty',
            description: 'Master deep water diving techniques',
            price: 229.99,
            difficulty: 'Advanced',
            duration: 200,
            topics: ['Deep Diving', 'Nitrogen Narcosis', 'Safety Stops', 'Equipment'],
            iconPath: 'assets/icons/deep_diving.png',
          ),
          DivingCourse(
            id: 'technical_diving',
            title: 'Technical Diving Fundamentals',
            description: 'Introduction to technical diving principles',
            price: 449.99,
            difficulty: 'Advanced',
            duration: 250,
            topics: ['Mixed Gas', 'Decompression', 'Equipment Config', 'Emergency Procedures'],
            iconPath: 'assets/icons/technical.png',
          ),
          DivingCourse(
            id: 'trimix_diving',
            title: 'Trimix Diver Certification',
            description: 'Advanced gas mixing for extreme depths',
            price: 599.99,
            difficulty: 'Advanced',
            duration: 300,
            topics: ['Gas Theory', 'Mix Calculations', 'Deep Exploration', 'Safety Protocols'],
            iconPath: 'assets/icons/trimix.png',
          ),
          DivingCourse(
            id: 'commercial_diving',
            title: 'Commercial Diving Operations',
            description: 'Professional diving for commercial applications',
            price: 799.99,
            difficulty: 'Advanced',
            duration: 400,
            topics: ['Industrial Work', 'Surface Supply', 'Communications', 'Safety Standards'],
            iconPath: 'assets/icons/commercial.png',
          ),
        ],
      ),
      POI(
        id: 'underwater_caves',
        name: 'Mysterious Caves',
        description: 'Explore hidden underwater cave systems',
        x: 0.05,
        y: 0.55,
        type: 'cave',
        backgroundImage: 'assets/images/cave_diving.jpg',
        courses: [
          DivingCourse(
            id: 'cave_diving',
            title: 'Cave Diver Specialty',
            description: 'Learn safe cave diving techniques and protocols',
            price: 349.99,
            difficulty: 'Advanced',
            duration: 240,
            topics: ['Cave Navigation', 'Emergency Procedures', 'Line Following', 'Rescue Techniques'],
            iconPath: 'assets/icons/cave_diving.png',
          ),
          DivingCourse(
            id: 'sidemount',
            title: 'Sidemount Diving',
            description: 'Master sidemount configuration for cave diving',
            price: 199.99,
            difficulty: 'Intermediate',
            duration: 150,
            topics: ['Sidemount Setup', 'Buoyancy Control', 'Gear Configuration', 'Emergency Drills'],
            iconPath: 'assets/icons/sidemount.png',
          ),
          DivingCourse(
            id: 'cavern_diving',
            title: 'Cavern Diver Certification',
            description: 'Introduction to overhead environment diving',
            price: 249.99,
            difficulty: 'Intermediate',
            duration: 180,
            topics: ['Light Zone Diving', 'Basic Navigation', 'Safety Protocols', 'Equipment Requirements'],
            iconPath: 'assets/icons/cavern.png',
          ),
          DivingCourse(
            id: 'cave_rescue',
            title: 'Cave Rescue Diver',
            description: 'Specialized rescue techniques for cave environments',
            price: 449.99,
            difficulty: 'Advanced',
            duration: 300,
            topics: ['Rescue Planning', 'Victim Recovery', 'Emergency Response', 'Equipment Systems'],
            iconPath: 'assets/icons/cave_rescue.png',
          ),
          DivingCourse(
            id: 'cave_survey',
            title: 'Cave Surveying & Mapping',
            description: 'Document and map underwater cave systems',
            price: 279.99,
            difficulty: 'Advanced',
            duration: 200,
            topics: ['Survey Techniques', 'Measurement Tools', 'Mapping Software', 'Documentation'],
            iconPath: 'assets/icons/survey.png',
          ),
        ],
      ),
      POI(
        id: 'kelp_forest',
        name: 'Search & Recovery',
        description: 'Learn underwater search patterns and object recovery techniques',
        x: 0.25,
        y: 0.7,
        type: 'forest',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [
          DivingCourse(
            id: 'kelp_forest_diving',
            title: 'Kelp Forest Explorer',
            description: 'Navigate and explore kelp forest ecosystems',
            price: 159.99,
            difficulty: 'Beginner',
            duration: 90,
            topics: ['Kelp Navigation', 'Marine Life', 'Photography', 'Conservation'],
            iconPath: 'assets/icons/kelp_forest.png',
          ),
          DivingCourse(
            id: 'search_recovery',
            title: 'Search & Recovery Specialist',
            description: 'Professional search and recovery operations',
            price: 199.99,
            difficulty: 'Advanced',
            duration: 160,
            topics: ['Search Patterns', 'Recovery Methods', 'Evidence Handling', 'Public Safety'],
            iconPath: 'assets/icons/search_recovery.png',
          ),
          DivingCourse(
            id: 'lift_bag',
            title: 'Lift Bag Operations',
            description: 'Master controlled lifting techniques',
            price: 129.99,
            difficulty: 'Intermediate',
            duration: 100,
            topics: ['Lift Bag Deployment', 'Weight Calculations', 'Safety Procedures', 'Equipment Maintenance'],
            iconPath: 'assets/icons/lift_bag.png',
          ),
          DivingCourse(
            id: 'evidence_recovery',
            title: 'Underwater Evidence Recovery',
            description: 'Specialized techniques for law enforcement divers',
            price: 299.99,
            difficulty: 'Advanced',
            duration: 200,
            topics: ['Chain of Custody', 'Documentation', 'Photography', 'Legal Procedures'],
            iconPath: 'assets/icons/evidence.png',
          ),
        ],
      ),
      POI(
        id: 'submarine_graveyard',
        name: 'Submarine Graveyard',
        description: 'Explore sunken military submarines from WWII',
        x: 0.6,
        y: 0.75,
        type: 'military_wreck',
        backgroundImage: 'assets/images/ship_wreck.jpg',
        courses: [
          DivingCourse(
            id: 'technical_wreck',
            title: 'Technical Wreck Diving',
            description: 'Advanced wreck penetration and exploration',
            price: 399.99,
            difficulty: 'Advanced',
            duration: 300,
            topics: ['Penetration Techniques', 'Mixed Gas Diving', 'Decompression', 'Historical Research'],
            iconPath: 'assets/icons/technical_wreck.png',
          ),
          DivingCourse(
            id: 'military_history',
            title: 'Military Diving History',
            description: 'Learn about underwater military archaeology',
            price: 129.99,
            difficulty: 'Beginner',
            duration: 75,
            topics: ['Military History', 'Submarine Technology', 'War Archaeology', 'Preservation'],
            iconPath: 'assets/icons/military_history.png',
          ),
          DivingCourse(
            id: 'submarine_penetration',
            title: 'Submarine Penetration Expert',
            description: 'Specialized techniques for submarine exploration',
            price: 449.99,
            difficulty: 'Advanced',
            duration: 280,
            topics: ['Submarine Layout', 'Emergency Exits', 'Hazard Recognition', 'Equipment Systems'],
            iconPath: 'assets/icons/submarine.png',
          ),
          DivingCourse(
            id: 'naval_archaeology',
            title: 'Naval Archaeology Specialist',
            description: 'Document and preserve military maritime heritage',
            price: 249.99,
            difficulty: 'Intermediate',
            duration: 180,
            topics: ['Historical Documentation', 'Artifact Preservation', 'Site Mapping', 'Research Methods'],
            iconPath: 'assets/icons/naval_arch.png',
          ),
          DivingCourse(
            id: 'war_history',
            title: 'WWII Pacific Theater History',
            description: 'Deep dive into Pacific war naval operations',
            price: 99.99,
            difficulty: 'Beginner',
            duration: 60,
            topics: ['Battle History', 'Ship Identification', 'Timeline Events', 'Strategic Analysis'],
            iconPath: 'assets/icons/war_history.png',
          ),
        ],
      ),
      POI(
        id: 'thermal_vents',
        name: 'Hydrothermal Vents',
        description: 'Discover unique life around underwater thermal vents',
        x: 0.5,
        y: 0.15,
        type: 'thermal',
        backgroundImage: 'assets/images/cave_diving.jpg',
        courses: [
          DivingCourse(
            id: 'scientific_diving',
            title: 'Scientific Diver Certification',
            description: 'Become a certified scientific research diver',
            price: 449.99,
            difficulty: 'Advanced',
            duration: 360,
            topics: ['Research Methods', 'Data Collection', 'Sampling Techniques', 'Safety Protocols'],
            iconPath: 'assets/icons/scientific_diving.png',
          ),
          DivingCourse(
            id: 'thermal_vent_biology',
            title: 'Thermal Vent Biology',
            description: 'Study unique life forms around thermal vents',
            price: 199.99,
            difficulty: 'Intermediate',
            duration: 140,
            topics: ['Extremophile Organisms', 'Vent Ecology', 'Chemosynthesis', 'Species Adaptation'],
            iconPath: 'assets/icons/thermal_biology.png',
          ),
          DivingCourse(
            id: 'geological_survey',
            title: 'Underwater Geological Survey',
            description: 'Map and study underwater geological formations',
            price: 299.99,
            difficulty: 'Advanced',
            duration: 220,
            topics: ['Rock Formation', 'Mineral Identification', 'Survey Techniques', 'Sample Collection'],
            iconPath: 'assets/icons/geology.png',
          ),
          DivingCourse(
            id: 'deep_sea_research',
            title: 'Deep Sea Research Methods',
            description: 'Advanced techniques for deep sea scientific exploration',
            price: 549.99,
            difficulty: 'Advanced',
            duration: 400,
            topics: ['Deep Sea Equipment', 'Research Protocols', 'Data Analysis', 'Publication Methods'],
            iconPath: 'assets/icons/deep_research.png',
          ),
          DivingCourse(
            id: 'environmental_monitoring',
            title: 'Environmental Monitoring',
            description: 'Monitor and assess underwater environmental conditions',
            price: 179.99,
            difficulty: 'Intermediate',
            duration: 120,
            topics: ['Water Quality', 'Pollution Assessment', 'Ecosystem Health', 'Monitoring Equipment'],
            iconPath: 'assets/icons/environmental.png',
          ),
        ],
      ),
    ];
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateJson = prefs.getString('game_state');
    
    if (gameStateJson != null) {
      final gameState = json.decode(gameStateJson);
      _boatX = gameState['boatX']?.toDouble() ?? 0.5;
      _boatY = gameState['boatY']?.toDouble() ?? 0.8;
      _playerMoney = gameState['playerMoney']?.toDouble() ?? 500.0;
      
      // Load POI states
      if (gameState['pois'] != null) {
        final poisData = gameState['pois'] as List;
        for (int i = 0; i < _pois.length && i < poisData.length; i++) {
          final poiData = poisData[i];
          if (poiData['courses'] != null) {
            final coursesData = poiData['courses'] as List;
            for (int j = 0; j < _pois[i].courses.length && j < coursesData.length; j++) {
              final courseData = coursesData[j];
              _pois[i].courses[j].isPurchased = courseData['isPurchased'] ?? false;
              _pois[i].courses[j].isCompleted = courseData['isCompleted'] ?? false;
              _pois[i].courses[j].progress = courseData['progress']?.toDouble() ?? 0.0;
            }
          }
        }
      }
    }
    notifyListeners();
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameState = {
      'boatX': _boatX,
      'boatY': _boatY,
      'playerMoney': _playerMoney,
      'pois': _pois.map((poi) => poi.toJson()).toList(),
    };
    await prefs.setString('game_state', json.encode(gameState));
  }

  Future<void> moveBoatToPOI(POI poi) async {
    if (_isBoatMoving) return;
    
    _isBoatMoving = true;
    _selectedPOI = poi;
    notifyListeners();

    // Wait much longer to ensure the UI animation fully completes
    await Future.delayed(const Duration(milliseconds: 3000));
    
    _boatX = poi.x;
    _boatY = poi.y;
    _isBoatMoving = false;
    notifyListeners();
    
    await _saveGameState();
  }

  Future<void> moveBoatToPosition(double x, double y) async {
    if (_isBoatMoving) return;
    
    _isBoatMoving = true;
    notifyListeners();

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 3000));
    
    _boatX = x;
    _boatY = y;
    _isBoatMoving = false;
    notifyListeners();
    
    await _saveGameState();
  }

  void setSelectedLearningHouse(String learningHouseId) {
    _selectedLearningHouse = learningHouseId;
    notifyListeners();
    _saveGameState();
  }

  bool canPurchaseCourse(DivingCourse course) {
    return _playerMoney >= course.price && !course.isPurchased;
  }

  Future<bool> purchaseCourse(DivingCourse course) async {
    if (!canPurchaseCourse(course)) return false;
    
    _playerMoney -= course.price;
    course.isPurchased = true;
    notifyListeners();
    
    await _saveGameState();
    return true;
  }

  Future<void> completeCourse(DivingCourse course) async {
    if (!course.isPurchased) return;
    
    course.isCompleted = true;
    course.progress = 1.0;
    notifyListeners();
    
    await _saveGameState();
  }

  Future<void> updateCourseProgress(DivingCourse course, double progress) async {
    if (!course.isPurchased) return;
    
    course.progress = progress.clamp(0.0, 1.0);
    if (course.progress >= 1.0) {
      course.isCompleted = true;
    }
    notifyListeners();
    
    await _saveGameState();
  }

  void deselectPOI() {
    _selectedPOI = null;
    notifyListeners();
  }

  // Add money (for future features like completing courses)
  void addMoney(double amount) {
    _playerMoney += amount;
    notifyListeners();
    _saveGameState();
  }

  // Content Dev methods
  List<DivingCourse> getAllCourses() {
    List<DivingCourse> allCourses = [];
    for (POI poi in _pois) {
      allCourses.addAll(poi.courses);
    }
    return allCourses;
  }

  void addCustomCourse(DivingCourse course) {
    // For now, add to the first POI as a placeholder
    // In a real implementation, this would be assigned via POI assignment screen
    if (_pois.isNotEmpty) {
      _pois[0].courses.add(course);
      notifyListeners();
      _saveGameState();
    }
  }

  void updatePOICourses(String poiId, List<String> courseIds) {
    // Find the POI
    POI? targetPOI;
    for (POI poi in _pois) {
      if (poi.id == poiId) {
        targetPOI = poi;
        break;
      }
    }
    
    if (targetPOI == null) return;

    // Get all available courses
    List<DivingCourse> allCourses = getAllCourses();
    
    // Clear current courses and add selected ones
    targetPOI.courses.clear();
    for (String courseId in courseIds) {
      DivingCourse? course = allCourses.firstWhere(
        (c) => c.id == courseId,
        orElse: () => allCourses.isNotEmpty ? allCourses.first : DivingCourse(
          id: courseId,
          title: 'Unknown Course',
          description: 'Course not found',
          price: 0.0,
          difficulty: 'Beginner',
          duration: 30,
          topics: [],
          iconPath: 'assets/icons/diving_icon.png',
        ),
      );
      targetPOI.courses.add(course);
    }
    
    notifyListeners();
    _saveGameState();
  }

  void addCourseToSpecificPOI(DivingCourse course, String poiName) {
    // Find the POI by name
    POI? targetPOI;
    for (POI poi in _pois) {
      if (poi.name == poiName) {
        targetPOI = poi;
        break;
      }
    }
    
    if (targetPOI != null) {
      targetPOI.courses.add(course);
      notifyListeners();
      _saveGameState();
    }
  }

  void updateCourse(DivingCourse updatedCourse, String poiName) {
    // Find the POI by name
    POI? targetPOI;
    for (POI poi in _pois) {
      if (poi.name == poiName) {
        targetPOI = poi;
        break;
      }
    }
    
    if (targetPOI != null) {
      // Find and update the course
      for (int i = 0; i < targetPOI.courses.length; i++) {
        if (targetPOI.courses[i].id == updatedCourse.id) {
          targetPOI.courses[i] = updatedCourse;
          break;
        }
      }
      notifyListeners();
      _saveGameState();
    }
  }
} 