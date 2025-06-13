import 'dart:math';
import 'package:flutter/material.dart';
import 'game_map_screen.dart';
import 'learning_house_selection_screen.dart';
import 'content_dev/content_dev_dashboard.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _cardController;
  late Animation<double> _waveAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveController);
    
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack, // Changed from elasticOut to prevent overflow
    ));
    
    // Delay the start of animations to prevent initial render issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          _waveController.repeat();
          _cardController.forward();
        } catch (e) {
          // Fallback: try again after a short delay
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              try {
                _waveController.repeat();
                _cardController.forward();
              } catch (e) {
                // Silent fail - animations will just not run
              }
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _navigateToRole(String role) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (role == 'student') {
            return const LearningHouseSelectionScreen();
          } else {
            return const ContentDevDashboard();
          }
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ensure we have valid constraints before building
          if (constraints.maxHeight <= 0 || constraints.maxWidth <= 0) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F172A), // Dark blue
                  Color(0xFF1E3A8A), // Medium blue
                  Color(0xFF3B82F6), // Light blue
                  Color(0xFF06B6D4), // Cyan
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated wave background
                if (_waveController.isAnimating)
                  AnimatedBuilder(
                    animation: _waveAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: WavePainter(_waveAnimation.value),
                        size: Size.infinite,
                      );
                    },
                  ),
                
                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: max(
                          400, // Minimum fallback height
                          constraints.maxHeight - 
                                   MediaQuery.of(context).padding.top - 
                                   MediaQuery.of(context).padding.bottom,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title
                            if (_cardController.isCompleted || _cardController.isAnimating)
                              AnimatedBuilder(
                                animation: _cardAnimation,
                                builder: (context, child) {
                                  // Safety check to prevent initial render issues
                                  if (!_cardController.isAnimating && _cardAnimation.value == 0.0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Transform.scale(
                                    scale: _cardAnimation.value.clamp(0.0, 1.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 20,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.scuba_diving,
                                            size: 40,
                                            color: Color(0xFF1E3A8A),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Choose Your Role',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Select how you want to experience the diving world',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                            letterSpacing: 0.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            else
                              // Fallback content when animation hasn't started
                              Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.scuba_diving,
                                      size: 40,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Choose Your Role',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Select how you want to experience the diving world',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            
                            const SizedBox(height: 40),
                            
                            // Role selection cards
                            if (_cardController.isCompleted || _cardController.isAnimating)
                              AnimatedBuilder(
                                animation: _cardAnimation,
                                builder: (context, child) {
                                  // Safety check to prevent initial render issues
                                  if (!_cardController.isAnimating && _cardAnimation.value == 0.0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Transform.translate(
                                    offset: Offset(0, (1 - _cardAnimation.value.clamp(0.0, 1.0)) * 50),
                                    child: Opacity(
                                      opacity: _cardAnimation.value.clamp(0.0, 1.0),
                                      child: Column(
                                        children: [
                                          // Student Card
                                          _buildRoleCard(
                                            title: 'Student',
                                            subtitle: 'Learn & Explore',
                                            description: 'Embark on diving adventures, purchase courses, and master underwater skills',
                                            icon: Icons.school,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                                            ),
                                            onTap: () => _navigateToRole('student'),
                                          ),
                                          
                                          const SizedBox(height: 20),
                                          
                                          // Content Dev Card
                                          _buildRoleCard(
                                            title: 'Content Developer',
                                            subtitle: 'Create & Manage',
                                            description: 'Design courses, create assessments, and manage diving education content',
                                            icon: Icons.edit_note,
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF1E3A8A), Color(0xFF06B6D4)],
                                            ),
                                            onTap: () => _navigateToRole('content_dev'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              // Fallback content when animation hasn't started
                              Column(
                                children: [
                                  // Student Card
                                  _buildRoleCard(
                                    title: 'Student',
                                    subtitle: 'Learn & Explore',
                                    description: 'Embark on diving adventures, purchase courses, and master underwater skills',
                                    icon: Icons.school,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                                    ),
                                    onTap: () => _navigateToRole('student'),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Content Dev Card
                                  _buildRoleCard(
                                    title: 'Content Developer',
                                    subtitle: 'Create & Manage',
                                    description: 'Design courses, create assessments, and manage diving education content',
                                    icon: Icons.edit_note,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1E3A8A), Color(0xFF06B6D4)],
                                    ),
                                    onTap: () => _navigateToRole('content_dev'),
                                  ),
                                ],
                              ),
                            
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 200, // Fixed height to prevent overflow
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: gradient.colors.first,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 30.0;
    final waveLength = size.width / 2;

    for (int i = 0; i < 3; i++) {
      path.reset();
      final yOffset = size.height * 0.7 + (i * 40);
      
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += 1) {
        final y = yOffset + 
            waveHeight * 
            sin((x / waveLength * 2 * 3.14159) + (animationValue * 2 * 3.14159) + (i * 0.5));
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      
      paint.color = Colors.white.withOpacity(0.05 + (i * 0.02));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 