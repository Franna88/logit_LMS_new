import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/poi.dart';
import '../models/diving_course.dart';
import '../widgets/boat_widget.dart';
import '../widgets/poi_marker.dart';
import '../widgets/poi_popup.dart';
import '../widgets/diver_buddy_button.dart';
import '../widgets/wave_painter.dart';
import 'course_modules_screen.dart';
import 'dmt_assessment_screen.dart';
import 'learning_house_selection_screen.dart';

class CPDIslandMapScreen extends StatefulWidget {
  const CPDIslandMapScreen({super.key});

  @override
  State<CPDIslandMapScreen> createState() => _CPDIslandMapScreenState();
}

class _CPDIslandMapScreenState extends State<CPDIslandMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _boatAnimationController;
  late AnimationController _waveAnimationController;
  
  List<POI> _cpdPOIs = [];
  bool _isBoatMoving = false;
  double _boatX = 0.5;
  double _boatY = 0.8;

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
    
    _initializeCPDPOIs();
  }

  @override
  void dispose() {
    _boatAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  void _initializeCPDPOIs() {
    _cpdPOIs = [
      // DMT - Diver Medical Training (Main POI - Center)
      POI(
        id: 'dmt',
        name: 'DMT',
        description: 'Diver Medical Training - Emergency medical response for diving professionals',
        x: 0.5,
        y: 0.35,
        type: 'medical',
        backgroundImage: 'assets/images/dmt.jpg',
        courses: [
          DivingCourse(
            id: 'diver_first_aid',
            title: 'Diver Emergency First Aid',
            description: 'Essential first aid skills for diving emergencies',
            price: 199.99,
            difficulty: 'Intermediate',
            duration: 120,
            topics: ['CPR', 'Rescue Breathing', 'Shock Management', 'Bleeding Control'],
            iconPath: 'assets/icons/first_aid.png',
          ),
        ],
      ),
      
      // Top row POIs (spread across top)
      POI(
        id: 'instructor_development',
        name: 'Instructor Academy',
        description: 'Advanced instructor development and teaching methodologies',
        x: 0.15,
        y: 0.15,
        type: 'education',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'legal_compliance',
        name: 'Legal & Compliance Center',
        description: 'Legal aspects and compliance requirements for diving operations',
        x: 0.5,
        y: 0.1,
        type: 'legal',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'business_skills',
        name: 'Dive Business Hub',
        description: 'Business skills for diving professionals and entrepreneurs',
        x: 0.85,
        y: 0.15,
        type: 'business',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      // Left side POIs
      POI(
        id: 'safety_officer',
        name: 'Safety Officer Training',
        description: 'Professional safety officer certification and training',
        x: 0.1,
        y: 0.45,
        type: 'safety',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'emergency_response',
        name: 'Emergency Response Center',
        description: 'Advanced emergency response and rescue coordination',
        x: 0.05,
        y: 0.7,
        type: 'emergency',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      // Right side POIs
      POI(
        id: 'marine_conservation',
        name: 'Conservation Center',
        description: 'Marine conservation and environmental awareness programs',
        x: 0.9,
        y: 0.45,
        type: 'conservation',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'research_methods',
        name: 'Research Station',
        description: 'Scientific research methods and underwater data collection',
        x: 0.95,
        y: 0.7,
        type: 'research',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      // Middle area POIs (around DMT)
      POI(
        id: 'technical_skills',
        name: 'Technical Skills Lab',
        description: 'Advanced technical diving skills and equipment training',
        x: 0.25,
        y: 0.55,
        type: 'technical',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'photography_pro',
        name: 'Pro Photography Studio',
        description: 'Professional underwater photography and videography training',
        x: 0.75,
        y: 0.55,
        type: 'photography',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      // Bottom row POIs
      POI(
        id: 'equipment_specialist',
        name: 'Equipment Workshop',
        description: 'Diving equipment maintenance and repair specialist training',
        x: 0.2,
        y: 0.85,
        type: 'equipment',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'leadership_skills',
        name: 'Leadership Academy',
        description: 'Leadership and management skills for diving professionals',
        x: 0.5,
        y: 0.8,
        type: 'leadership',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
      
      POI(
        id: 'quality_assurance',
        name: 'Quality Assurance Hub',
        description: 'Quality assurance and standards compliance for diving training',
        x: 0.8,
        y: 0.85,
        type: 'quality',
        backgroundImage: 'assets/images/coral_diving.jpg',
        courses: [],
      ),
    ];
  }

  Future<void> _moveBoatToPOI(POI poi) async {
    setState(() {
      _isBoatMoving = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() {
      _boatX = poi.x;
      _boatY = poi.y;
    });
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    setState(() {
      _isBoatMoving = false;
    });
  }

  void _onPOITapped(POI poi) async {
    if (_isBoatMoving) return;
    
    final distance = ((_boatX - poi.x).abs() + (_boatY - poi.y).abs());
    final isAlreadyAtPOI = distance < 0.1;
    
    if (isAlreadyAtPOI) {
      _showPOIPopup(poi);
    } else {
      await _moveBoatToPOI(poi);
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        _showPOIPopup(poi);
      }
    }
  }

  void _showPOIPopup(POI poi) {
    final screenSize = MediaQuery.of(context).size;
    final poiScreenX = screenSize.width * poi.x;
    final poiScreenY = screenSize.height * poi.y;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => Stack(
        children: [
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

  double _calculatePopupX(double poiX, double screenWidth) {
    const popupWidth = 280.0;
    const margin = 20.0;
    
    double x = poiX + 100;
    
    if (x + popupWidth > screenWidth - margin) {
      x = poiX - popupWidth - 100;
    }
    
    if (x < margin) {
      x = margin;
    }
    
    return x;
  }

  double _calculatePopupY(double poiY, double screenHeight) {
    const popupHeight = 400.0;
    const margin = 50.0;
    
    double y = poiY - (popupHeight / 2);
    
    if (y < margin) {
      y = margin;
    } else if (y + popupHeight > screenHeight - margin) {
      y = screenHeight - popupHeight - margin;
    }
    
    return y;
  }

  void _navigateToPOI(POI poi) {
    Navigator.of(context).pop();
    
    // Check if this is the DMT POI to navigate to DMT screen
    if (poi.id == 'dmt') {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DMTAssessmentScreen(),
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
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Island background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/map_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Animated wave overlay
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
          ..._cpdPOIs.map((poi) {
            final screenSize = MediaQuery.of(context).size;
            const markerWidth = 134.0;
            const markerHeight = 170.0;
            
            double leftPosition = (screenSize.width * poi.x) - (markerWidth / 2);
            double topPosition = (screenSize.height * poi.y) - (markerHeight / 2);
            
            leftPosition = leftPosition.clamp(0, screenSize.width - markerWidth);
            topPosition = topPosition.clamp(0, screenSize.height - markerHeight);
            
            return Positioned(
              left: leftPosition,
              top: topPosition,
              child: POIMarker(
                poi: poi,
                onTap: () => _onPOITapped(poi),
              ),
            );
          }),

          // Animated boat
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            left: MediaQuery.of(context).size.width * _boatX - 90,
            top: MediaQuery.of(context).size.height * _boatY - 90,
            child: BoatWidget(
              isMoving: _isBoatMoving,
              waveAnimation: _waveAnimationController,
            ),
          ),

          // Diver Buddy Chat Bot
          const DiverBuddyButton(),

          // Loading indicator when boat is moving
          if (_isBoatMoving)
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
                        'Navigating to CPD location...',
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
                      Colors.green.shade800.withOpacity(0.9),
                      Colors.green.shade600.withOpacity(0.8),
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
                  'CPD WPA',
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
      ),
    );
  }
} 
