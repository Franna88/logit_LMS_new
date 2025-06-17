import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/game_state_provider.dart';
import '../models/learning_house.dart';
import '../widgets/boat_widget.dart';
import '../widgets/learning_house_marker.dart';
import '../widgets/learning_house_popup.dart';
import '../widgets/diver_buddy_button.dart';
import '../widgets/wave_painter.dart';
import 'game_map_screen.dart';
import 'role_selection_screen.dart' as role_screen;

class LearningHouseSelectionScreen extends StatefulWidget {
  const LearningHouseSelectionScreen({super.key});

  @override
  State<LearningHouseSelectionScreen> createState() => _LearningHouseSelectionScreenState();
}

class _LearningHouseSelectionScreenState extends State<LearningHouseSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _boatAnimationController;
  late AnimationController _waveAnimationController;
  
  // Learning house data
  List<LearningHouse> _learningHouses = [];

  @override
  void initState() {
    super.initState();
    _boatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _waveAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _initializeLearningHouses();
  }

  @override
  void dispose() {
    _boatAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  void _initializeLearningHouses() {
    _learningHouses = [
      LearningHouse(
        id: 'padi',
        name: 'PADI',
        fullName: 'Professional Association of Diving Instructors',
        description: 'The world\'s leading scuba training organization, offering courses for all skill levels with a focus on safety and environmental awareness.',
        x: 0.25,
        y: 0.3,
        logoPath: 'assets/images/diving_houses/padi.png',
        specialty: 'Recreational Diving',
      ),
      LearningHouse(
        id: 'ssi',
        name: 'SSI',
        fullName: 'Scuba Schools International',
        description: 'A global leader in scuba diving education, known for innovative training methods and comprehensive certification programs.',
        x: 0.75,
        y: 0.25,
        logoPath: 'assets/images/diving_houses/ssi-logo.png',
        specialty: 'Digital Learning',
      ),
      LearningHouse(
        id: 'naui',
        name: 'NAUI',
        fullName: 'National Association of Underwater Instructors',
        description: 'America\'s premier diving education organization, emphasizing safety through comprehensive training and flexible programs.',
        x: 0.2,
        y: 0.65,
        logoPath: 'assets/images/diving_houses/naui-logo.png',
        specialty: 'Safety First',
      ),
      LearningHouse(
        id: 'cmas',
        name: 'CMAS',
        fullName: 'Confédération Mondiale des Activités Subaquatiques',
        description: 'The world confederation of underwater activities, promoting diving sports and underwater sciences globally.',
        x: 0.8,
        y: 0.7,
        logoPath: 'assets/images/diving_houses/cmas.png',
        specialty: 'Technical Diving',
      ),
      LearningHouse(
        id: 'gue',
        name: 'GUE',
        fullName: 'Global Underwater Explorers',
        description: 'Elite technical diving education organization focused on standardized procedures and advanced exploration techniques.',
        x: 0.5,
        y: 0.45,
        logoPath: 'assets/images/diving_houses/GUE-logo_new.png',
        specialty: 'Technical Excellence',
      ),
    ];
  }

  void _onLearningHouseTapped(LearningHouse house, GameStateProvider gameState) async {
    if (gameState.isBoatMoving) return;
    
    // Check if boat is already at this learning house
    final boatX = gameState.boatX;
    final boatY = gameState.boatY;
    final distance = ((boatX - house.x).abs() + (boatY - house.y).abs());
    final isAlreadyAtHouse = distance < 0.1;
    
    if (isAlreadyAtHouse) {
      _showLearningHousePopup(house, gameState);
    } else {
      // Animate boat to learning house first
      await gameState.moveBoatToPosition(house.x, house.y);
      
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Then show popup
      if (mounted) {
        _showLearningHousePopup(house, gameState);
      }
    }
  }

  void _showLearningHousePopup(LearningHouse house, GameStateProvider gameState) {
    // Calculate popup position near the learning house
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final houseScreenX = screenSize.width * house.x;
    final houseScreenY = screenSize.height * house.y;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Stack(
        children: [
          Positioned(
            left: _calculatePopupX(houseScreenX, screenSize.width),
            top: _calculatePopupY(houseScreenY, screenSize.height, padding),
            child: Material(
              color: Colors.transparent,
              child: LearningHousePopup(
                house: house,
                onEnterLearningHouse: () => _navigateToGameMap(house),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculatePopupX(double houseX, double screenWidth) {
    const popupWidth = 300.0;
    const margin = 20.0;
    
    // Try to position to the right of learning house
    double x = houseX + 100;
    
    // If it goes off screen, position to the left
    if (x + popupWidth > screenWidth - margin) {
      x = houseX - popupWidth - 100;
    }
    
    // Ensure it doesn't go off the left edge
    if (x < margin) {
      x = margin;
    }
    
    return x;
  }

  double _calculatePopupY(double houseY, double screenHeight, EdgeInsets padding) {
    const maxPopupHeight = 400.0;
    const margin = 20.0;
    
    // Calculate available screen height accounting for safe areas
    final availableHeight = screenHeight - padding.top - padding.bottom;
    final safeTop = padding.top + margin;
    final safeBottom = screenHeight - padding.bottom - margin;
    
    // Try to center vertically around learning house
    double y = houseY - (maxPopupHeight / 2);
    
    // Ensure it doesn't go off screen (accounting for safe areas)
    if (y < safeTop) {
      y = safeTop;
    } else if (y + maxPopupHeight > safeBottom) {
      y = safeBottom - maxPopupHeight;
      
      // If popup is still too tall for available space, position at top of safe area
      if (y < safeTop) {
        y = safeTop;
      }
    }
    
    return y;
  }

  void _navigateToGameMap(LearningHouse selectedHouse) {
    Navigator.of(context).pop(); // Close the popup first
    
    // Store the selected learning house in the game state
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    gameState.setSelectedLearningHouse(selectedHouse.id);
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameMapScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  void _navigateBackToRoleSelection() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const role_screen.RoleSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameStateProvider>(
        builder: (context, gameState, child) {
          return Stack(
            children: [
              // Map background image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/map_background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              // Subtle animated wave overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveAnimationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WavePainter(_waveAnimationController.value),
                    );
                  },
                ),
              ),

              // Back button
              Positioned(
                top: 50,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _navigateBackToRoleSelection,
                      borderRadius: BorderRadius.circular(25),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Learning house markers
              ..._learningHouses.map((house) {
                final screenSize = MediaQuery.of(context).size;
                const markerWidth = 134.0;
                const markerHeight = 170.0;
                
                // Calculate position with bounds checking
                double leftPosition = (screenSize.width * house.x) - (markerWidth / 2);
                double topPosition = (screenSize.height * house.y) - (markerHeight / 2);
                
                // Ensure marker stays within screen bounds
                leftPosition = leftPosition.clamp(0, screenSize.width - markerWidth);
                topPosition = topPosition.clamp(0, screenSize.height - markerHeight);
                
                return Positioned(
                  left: leftPosition,
                  top: topPosition,
                  child: LearningHouseMarker(
                    house: house,
                    onTap: () => _onLearningHouseTapped(house, gameState),
                  ),
                );
              }),

              // Animated boat
              AnimatedPositioned(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                left: MediaQuery.of(context).size.width * gameState.boatX - 90,
                top: MediaQuery.of(context).size.height * gameState.boatY - 90,
                child: BoatWidget(
                  isMoving: gameState.isBoatMoving,
                  waveAnimation: _waveAnimationController,
                ),
              ),

              // Diver Buddy Chat Bot
              const DiverBuddyButton(),

              // Loading indicator when boat is moving
              if (gameState.isBoatMoving)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.shade300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Navigating to learning house...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Title overlay
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade800.withOpacity(0.9),
                          Colors.blue.shade600.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Choose Your Learning House',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 