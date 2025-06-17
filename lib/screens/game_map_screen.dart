import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../services/game_state_provider.dart';
import '../models/poi.dart';
import '../widgets/boat_widget.dart';
import '../widgets/poi_marker.dart';
import '../widgets/course_popup.dart';
import '../widgets/game_ui_overlay.dart';
import '../widgets/diver_buddy_button.dart';
import '../widgets/wave_painter.dart';
import '../widgets/poi_popup.dart';
import '../widgets/purchase_dialog.dart';
import 'course_modules_screen.dart';
import 'hub_screen.dart';
import 'learning_house_selection_screen.dart';

class GameMapScreen extends StatefulWidget {
  const GameMapScreen({super.key});

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _boatAnimationController;
  late AnimationController _waveAnimationController;
  
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
  }

  @override
  void dispose() {
    _boatAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  void _onPOITapped(POI poi, GameStateProvider gameState) async {
    if (gameState.isBoatMoving) return;
    
    // Check if boat is already at this POI (within a reasonable threshold)
    final boatX = gameState.boatX;
    final boatY = gameState.boatY;
    final distance = ((boatX - poi.x).abs() + (boatY - poi.y).abs());
    final isAlreadyAtPOI = distance < 0.1; // Increased threshold for better detection
    
    // Always show popup immediately if we're close enough, otherwise move boat first
    if (isAlreadyAtPOI) {
      // Show popup immediately since we're already at the POI
      _showPOIPopup(poi, gameState);
    } else {
      // Animate boat to POI first
      await gameState.moveBoatToPOI(poi);
      
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Then show popup
      if (mounted) {
        _showPOIPopup(poi, gameState);
      }
    }
  }
  
  void _showPOIPopup(POI poi, GameStateProvider gameState) {
    if (poi.id == 'tropical_island') {
      _showHubPopup(poi, gameState);
    } else {
      _showCoursePopup(poi, gameState);
    }
  }

  void _showCoursePopup(POI poi, GameStateProvider gameState) {
    // Calculate popup position near the POI
    final screenSize = MediaQuery.of(context).size;
    final poiScreenX = screenSize.width * poi.x;
    final poiScreenY = screenSize.height * poi.y;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Stack(
        children: [
          // Positioned popup near the POI
          Positioned(
            left: _calculatePopupX(poiScreenX, screenSize.width),
            top: _calculatePopupY(poiScreenY, screenSize.height),
            child: Material(
              color: Colors.transparent,
              child: POIPopup(
                poi: poi,
                onVisitLocation: () => _navigateToPOI(poi),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHubPopup(POI poi, GameStateProvider gameState) {
    // Calculate popup position near the POI
    final screenSize = MediaQuery.of(context).size;
    final poiScreenX = screenSize.width * poi.x;
    final poiScreenY = screenSize.height * poi.y;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Stack(
        children: [
          // Positioned popup near the POI
          Positioned(
            left: _calculatePopupX(poiScreenX, screenSize.width),
            top: _calculatePopupY(poiScreenY, screenSize.height),
            child: Material(
              color: Colors.transparent,
              child: HubPopup(
                poi: poi,
                onVisitHub: () => _navigateToHub(),
              ),
            ),
          ),
        ],
      ),
    );
  }





  double _calculatePopupX(double poiX, double screenWidth) {
    const popupWidth = 280.0;
    const margin = 20.0;
    
    // Try to position to the right of POI (account for larger POI size)
    double x = poiX + 100;
    
    // If it goes off screen, position to the left
    if (x + popupWidth > screenWidth - margin) {
      x = poiX - popupWidth - 100;
    }
    
    // Ensure it doesn't go off the left edge
    if (x < margin) {
      x = margin;
    }
    
    return x;
  }

  double _calculatePopupY(double poiY, double screenHeight) {
    const popupHeight = 400.0;
    const margin = 50.0;
    
    // Try to center vertically around POI
    double y = poiY - (popupHeight / 2);
    
    // Ensure it doesn't go off screen
    if (y < margin) {
      y = margin;
    } else if (y + popupHeight > screenHeight - margin) {
      y = screenHeight - popupHeight - margin;
    }
    
    return y;
  }

  void _showPurchaseDialog(dynamic course, GameStateProvider gameState) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => PurchaseDialog(
        course: course,
        gameState: gameState,
        onShowSuccessMessage: _showSuccessMessage,
      ),
    );
  }



  void _navigateToHub() {
    Navigator.of(context).pop(); // Close the popup first
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HubScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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

  void _navigateToPOI(POI poi) {
    Navigator.of(context).pop(); // Close the popup first
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CourseModulesScreen(poi: poi),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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

  void _navigateBackToLearningHouses() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LearningHouseSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
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



  String _getPOIImage(POI poi) {
    switch (poi.type) {
      case 'island':
        return 'assets/images/island_poi.png';
      case 'reef':
        return 'assets/images/Photograpy_poi.png';
      case 'wreck':
        return 'assets/images/shipwreck_poi.png';
      case 'deep_water':
        return 'assets/images/deep_diving_poi.png';
      case 'cave':
        return 'assets/images/basics_poi.png';
      case 'forest':
        return 'assets/images/search_&_recovery.png';
      case 'military_wreck':
        return 'assets/images/large_ship_poi.png';
      case 'thermal':
        return 'assets/images/oil_rig_poi.png';
      default:
        return 'assets/images/basics_poi.png';
    }
  }

  IconData _getPOIIcon(POI poi) {
    switch (poi.type) {
      case 'island':
        return Icons.landscape;
      case 'reef':
        return Icons.camera_alt;
      case 'wreck':
        return Icons.directions_boat;
      case 'deep_water':
        return Icons.water;
      case 'cave':
        return Icons.explore;
      case 'forest':
        return Icons.search;
      case 'military_wreck':
        return Icons.military_tech;
      case 'thermal':
        return Icons.local_fire_department;
      default:
        return Icons.place;
    }
  }

  void _startCourse(dynamic course, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Start ${course.title}'),
        content: const Text('This would start the course content. For now, we\'ll simulate completion.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await gameState.completeCourse(course);
              gameState.addMoney(50); // Reward for completion
              if (mounted) {
                Navigator.of(context).pop();
                _showSuccessMessage('Course completed! +R50');
              }
            },
            child: const Text('Complete Course'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
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
                      onTap: _navigateBackToLearningHouses,
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

              // POI markers
              ...gameState.pois.map((poi) {
                final screenSize = MediaQuery.of(context).size;
                const markerWidth = 134.0; // Total width of POI marker
                const markerHeight = 170.0; // Total height of POI marker with name label
                
                // Calculate position with bounds checking
                double leftPosition = (screenSize.width * poi.x) - (markerWidth / 2);
                double topPosition = (screenSize.height * poi.y) - (markerHeight / 2);
                
                // Ensure POI marker stays within screen bounds
                leftPosition = leftPosition.clamp(0, screenSize.width - markerWidth);
                topPosition = topPosition.clamp(0, screenSize.height - markerHeight);
                
                return Positioned(
                  left: leftPosition,
                  top: topPosition,
                  child: POIMarker(
                    poi: poi,
                    onTap: () => _onPOITapped(poi, gameState),
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
                            'Navigating to destination...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 300))
                      .slideY(
                        begin: 1.0,
                        end: 0.0,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      ),
                ),

            ],
          );
        },
      ),
    );
  }
}

 