import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:math';
import '../widgets/bubble_animation.dart';

class ContentBlock {
  final String type; // 'header', 'paragraph', 'image', 'video', 'bullet_list', 'quote', 'code'
  final String content;
  final String? subtitle;
  final List<String>? items;
  final String? imageUrl;
  final String? videoUrl;
  final String? caption;

  ContentBlock({
    required this.type,
    required this.content,
    this.subtitle,
    this.items,
    this.imageUrl,
    this.videoUrl,
    this.caption,
  });
}

class LessonContent {
  final String title;
  final String description;
  final List<ContentBlock> contentBlocks;
  final List<String> keyPoints;

  LessonContent({
    required this.title,
    required this.description,
    required this.contentBlocks,
    required this.keyPoints,
  });
}

class ModuleLessonScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;
  final String courseTitle;

  const ModuleLessonScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.courseTitle,
  });

  @override
  State<ModuleLessonScreen> createState() => _ModuleLessonScreenState();
}

class _ModuleLessonScreenState extends State<ModuleLessonScreen>
    with TickerProviderStateMixin {
  late AnimationController _diverController;
  late AnimationController _progressController;
  late AnimationController _waveController;
  late AnimationController _contentController;
  late Animation<double> _diverDepthAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _waveAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  int currentLessonIndex = 0;
  List<LessonContent> lessons = [];
  double moduleProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _diverController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _diverDepthAnimation = Tween<double>(
      begin: 0.0, // Start at Surface (0%)
      end: 1.0,   // End at 20m depth (100%)
    ).animate(CurvedAnimation(
      parent: _diverController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.elasticOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_waveController);

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeIn,
    ));

    _generateLessonContent();
    _updateProgress();
    _contentController.forward();
  }

  void _generateLessonContent() {
    // Generate rich dummy lesson content with various content blocks
    lessons = [
      LessonContent(
        title: 'Welcome to ${widget.moduleTitle}',
        description: 'This comprehensive lesson introduces you to the fundamental concepts and practical applications.',
        contentBlocks: [
          ContentBlock(
            type: 'header',
            content: 'Course Introduction',
            subtitle: 'Getting started with your learning journey',
          ),
          ContentBlock(
            type: 'paragraph',
            content: 'Welcome to this comprehensive diving course! This lesson will introduce you to the fundamental concepts that form the foundation of safe and enjoyable diving. Whether you\'re a beginner or looking to advance your skills, this content has been carefully designed by certified instructors.',
          ),
          ContentBlock(
            type: 'image',
            content: 'Course Overview',
            imageUrl: 'assets/images/course_intro.jpg',
            caption: 'Professional diving instruction with modern equipment and safety protocols',
          ),
          ContentBlock(
            type: 'video',
            content: 'Introduction Video',
            videoUrl: 'https://example.com/intro_video.mp4',
            caption: 'Watch this 3-minute introduction to understand what you\'ll learn in this course',
          ),
          ContentBlock(
            type: 'bullet_list',
            content: 'What You\'ll Learn',
            items: [
              'Essential safety protocols and procedures',
              'Proper equipment usage and maintenance',
              'Underwater navigation and communication',
              'Emergency response and rescue techniques',
              'Environmental awareness and conservation'
            ],
          ),
        ],
        keyPoints: [
          'Safety is the top priority in all diving activities',
          'Proper training builds confidence and competence',
          'Equipment knowledge is essential for safe diving',
          'Environmental protection is every diver\'s responsibility'
        ],
      ),
      LessonContent(
        title: 'Fundamental Principles',
        description: 'Understanding the basic principles that govern underwater activities and safety.',
        contentBlocks: [
          ContentBlock(
            type: 'header',
            content: 'Physics of Diving',
            subtitle: 'How pressure and depth affect your dive',
          ),
          ContentBlock(
            type: 'paragraph',
            content: 'As you descend underwater, water pressure increases dramatically. For every 10 meters (33 feet) of depth, pressure increases by 1 atmosphere. This fundamental principle affects every aspect of diving from your equipment to your body.',
          ),
          ContentBlock(
            type: 'quote',
            content: 'Understanding pressure is the key to safe diving. Every meter of depth brings new challenges and considerations.',
            subtitle: '- Dive Physics Expert',
          ),
          ContentBlock(
            type: 'image',
            content: 'Pressure vs Depth Chart',
            imageUrl: 'assets/images/pressure_chart.jpg',
            caption: 'Visual representation of how pressure increases with depth',
          ),
          ContentBlock(
            type: 'bullet_list',
            content: 'Pressure Effects',
            items: [
              'Air spaces in your body compress',
              'Equipment must handle pressure changes',
              'Gas consumption increases with depth',
              'Buoyancy changes as you descend'
            ],
          ),
        ],
        keyPoints: [
          'Pressure doubles at 10m depth',
          'Affects air spaces in your body',
          'Equipment must handle pressure changes',
          'Critical for safety planning'
        ],
      ),
      LessonContent(
        title: 'Practical Applications',
        description: 'Applying theoretical knowledge to real-world diving scenarios.',
        contentBlocks: [
          ContentBlock(
            type: 'header',
            content: 'Equipment Setup',
            subtitle: 'Proper configuration for safe diving',
          ),
          ContentBlock(
            type: 'video',
            content: 'Equipment Assembly Demo',
            videoUrl: 'https://example.com/equipment_setup.mp4',
            caption: 'Step-by-step guide to setting up your diving equipment',
          ),
          ContentBlock(
            type: 'paragraph',
            content: 'Proper equipment setup is crucial for safe diving. Your gear is your lifeline underwater, and understanding each piece of equipment and how it works together is essential for safe and enjoyable diving experiences.',
          ),
          ContentBlock(
            type: 'image',
            content: 'Complete Diving Setup',
            imageUrl: 'assets/images/diving_equipment.jpg',
            caption: 'Professional diving equipment properly assembled and ready for use',
          ),
          ContentBlock(
            type: 'bullet_list',
            content: 'Pre-Dive Checklist',
            items: [
              'Check all connections and seals',
              'Test regulator breathing',
              'Verify BCD inflation/deflation',
              'Confirm dive computer operation',
              'Review emergency procedures'
            ],
          ),
        ],
        keyPoints: [
          'Learn about basic diving gear',
          'Understand equipment functions',
          'Master pre-dive equipment checks',
          'Ensure proper equipment maintenance'
        ],
      ),
      LessonContent(
        title: 'Advanced Techniques',
        description: 'Developing advanced skills for specialized diving activities.',
        contentBlocks: [
          ContentBlock(
            type: 'header',
            content: 'Navigation Skills',
            subtitle: 'Finding your way underwater',
          ),
          ContentBlock(
            type: 'paragraph',
            content: 'Underwater navigation is a critical skill that combines compass use, natural navigation techniques, and modern technology. Whether you\'re exploring a new dive site or returning to the boat, proper navigation ensures safety and confidence.',
          ),
          ContentBlock(
            type: 'image',
            content: 'Underwater Compass',
            imageUrl: 'assets/images/diving_compass.jpg',
            caption: 'Professional diving compass used for underwater navigation',
          ),
          ContentBlock(
            type: 'video',
            content: 'Navigation Techniques',
            videoUrl: 'https://example.com/navigation_demo.mp4',
            caption: 'Learn compass navigation and natural navigation techniques',
          ),
          ContentBlock(
            type: 'bullet_list',
            content: 'Navigation Methods',
            items: [
              'Compass bearing navigation',
              'Natural landmark recognition',
              'Sand ripple pattern reading',
              'Light and shadow tracking',
              'Current direction awareness'
            ],
          ),
        ],
        keyPoints: [
          'Read compass bearings accurately',
          'Follow reciprocal headings',
          'Account for magnetic declination',
          'Practice in various conditions'
        ],
      ),
      LessonContent(
        title: 'Mastery and Certification',
        description: 'Demonstrating competency and preparing for certification.',
        contentBlocks: [
          ContentBlock(
            type: 'header',
            content: 'Final Assessment',
            subtitle: 'Demonstrating your skills and knowledge',
          ),
          ContentBlock(
            type: 'paragraph',
            content: 'Congratulations on reaching the final lesson! You have demonstrated mastery of essential diving concepts and are ready to apply these skills in real diving situations. This lesson prepares you for your final assessment and certification.',
          ),
          ContentBlock(
            type: 'quote',
            content: 'Certification is not the end of learning, but the beginning of a lifetime of underwater exploration and discovery.',
            subtitle: '- Master Instructor',
          ),
          ContentBlock(
            type: 'image',
            content: 'Certification Ceremony',
            imageUrl: 'assets/images/certification.jpg',
            caption: 'Celebrating successful completion of diving certification',
          ),
          ContentBlock(
            type: 'bullet_list',
            content: 'Certification Requirements',
            items: [
              'Complete all theoretical modules',
              'Pass written examinations',
              'Demonstrate practical skills',
              'Complete open water dives',
              'Show safety awareness'
            ],
          ),
          ContentBlock(
            type: 'video',
            content: 'Certification Process',
            videoUrl: 'https://example.com/certification_process.mp4',
            caption: 'Understanding the certification process and what comes next',
          ),
        ],
        keyPoints: [
          'Demonstrate skill mastery',
          'Complete final assessments',
          'Prepare for open water diving',
          'Continue lifelong learning'
        ],
      ),
    ];
  }

  void _updateProgress() {
    setState(() {
      moduleProgress = (currentLessonIndex + 1) / lessons.length;
    });
    
    // Reset progress controller for smooth animation
    _progressController.reset();
    _progressController.forward();
    
    // Move diver to exact position based on lesson index
    // Map lesson index (0-4) to animation value (0.0-1.0)
    double targetPosition = lessons.length > 1 ? currentLessonIndex / (lessons.length - 1) : 0.0;
    _diverController.animateTo(targetPosition);
  }

  void _nextLesson() {
    if (currentLessonIndex < lessons.length - 1) {
      _contentController.reset();
      setState(() {
        currentLessonIndex++;
      });
      _updateProgress();
      _contentController.forward();
    } else {
      _completeModule();
    }
  }

  void _previousLesson() {
    if (currentLessonIndex > 0) {
      _contentController.reset();
      setState(() {
        currentLessonIndex--;
      });
      _updateProgress();
      _contentController.forward();
    }
  }

  void _completeModule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF1E3A8A),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.school, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Presentation Complete!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Text(
          'Excellent work! You have completed the "${widget.moduleTitle}" presentation. You\'ve successfully dived through all 5 depth levels and mastered the concepts!',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to course modules
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: const Color(0xFF1E3A8A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
  }

  // Calculate parallax scroll position based on current lesson
  double _calculateParallaxPosition() {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 1.2;
    
    // Lesson 0 (1/5): Image starts completely below screen
    // Lesson 4 (5/5): Image is at normal position (showing full image)
    if (currentLessonIndex == 0) {
      return screenHeight; // Completely hidden below screen
    }
    
    // Progressive reveal: each step shows more of the image
    final progress = currentLessonIndex / (lessons.length - 1); // 0.0 to 1.0
    final startPosition = screenHeight; // Start below screen
    final endPosition = screenHeight - imageHeight; // End position to show full image
    
    return startPosition - (progress * (startPosition - endPosition));
  }

  // Calculate image opacity for smooth fade-in effect
  double _calculateImageOpacity() {
    if (currentLessonIndex == 0) {
      return 0.0; // Completely transparent on first lesson
    }
    
    // Gradual opacity increase with each lesson
    final progress = currentLessonIndex / (lessons.length - 1); // 0.0 to 1.0
    return (progress * 0.6).clamp(0.0, 0.6); // Max opacity of 0.6 to keep ocean background visible
  }

  @override
  void dispose() {
    _diverController.dispose();
    _progressController.dispose();
    _waveController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DivingBubbleTransition(
        child: Stack(
          children: [
            // Ocean background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF87CEEB), // Light blue at surface
                    Color(0xFF4682B4), // Medium blue
                    Color(0xFF2E4057), // Darker blue
                    Color(0xFF1A1A2E), // Deep dark blue at bottom
                  ],
                ),
              ),
            ),

            // Parallax scrolling background image
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              // Calculate position: start below screen, end at normal position
              // Lesson 0: Image hidden below screen
              // Lesson 4: Image fully visible
              top: _calculateParallaxPosition(),
              child: Opacity(
                opacity: _calculateImageOpacity(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 1.2, // Reduced height for better image fit
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/scroll_image.png'),
                      fit: BoxFit.contain, // Show full image without cropping
                      alignment: Alignment.bottomCenter, // Align to bottom so top scrolls in first
                    ),
                  ),
                ),
              ),
            ),

            // Animated wave effect at surface
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: AnimatedBuilder(
                animation: _waveAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: SurfaceWavePainter(_waveAnimation.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),

                        // Depth indicators and diver in a controlled container
            Positioned(
              left: 10,
              top: 0,
              right: MediaQuery.of(context).size.width * 0.65, // Leave even more space for content
              bottom: 0,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Use full available height with padding for safe areas
                    double fullHeight = constraints.maxHeight;
                    double topPadding = 150; // Keep content below progress indicator
                    double bottomPadding = 80; // Keep space at bottom
                    double availableHeight = fullHeight - topPadding - bottomPadding;
                  
                                                        return Container(
                     width: 280,
                     height: fullHeight,
                     child: Stack(
                       children: [
                         // Depth indicators at exact positions with padding offset
                         Positioned(
                           left: 0,
                           top: topPadding,
                           child: _buildDepthIndicator('Surface', 0, Icons.waves),
                         ),
                         Positioned(
                           left: 0,
                           top: topPadding + (availableHeight * 0.25),
                           child: _buildDepthIndicator('5m', 1, Icons.circle),
                         ),
                         Positioned(
                           left: 0,
                           top: topPadding + (availableHeight * 0.5),
                           child: _buildDepthIndicator('10m', 2, Icons.circle),
                         ),
                         Positioned(
                           left: 0,
                           top: topPadding + (availableHeight * 0.75),
                           child: _buildDepthIndicator('15m', 3, Icons.circle),
                         ),
                         Positioned(
                           left: 0,
                           top: topPadding + availableHeight - 40,
                           child: _buildDepthIndicator('20m', 4, Icons.anchor),
                         ),
                        
                                                 // Animated diver positioned exactly with depth indicators
                         AnimatedBuilder(
                           animation: _diverDepthAnimation,
                           builder: (context, child) {
                             // Calculate exact positions that match depth indicators (with padding offset)
                             double diverY;
                             switch (currentLessonIndex) {
                               case 0: // Surface
                                 diverY = topPadding;
                                 break;
                               case 1: // 5m
                                 diverY = topPadding + (availableHeight * 0.25);
                                 break;
                               case 2: // 10m
                                 diverY = topPadding + (availableHeight * 0.5);
                                 break;
                               case 3: // 15m
                                 diverY = topPadding + (availableHeight * 0.75);
                                 break;
                               case 4: // 20m
                                 diverY = topPadding + availableHeight - 40;
                                 break;
                               default:
                                 diverY = topPadding + (availableHeight * _diverDepthAnimation.value);
                             }
                             
                             return AnimatedPositioned(
                               duration: const Duration(milliseconds: 1500),
                               curve: Curves.easeInOut,
                               left: 160, // Position next to depth indicators
                               top: diverY - 20, // Center diver vertically on indicator
                               child: Transform.rotate(
                                 angle: moduleProgress * 0.2, // Slight rotation as diving deeper
                                 child: Container(
                                   width: 100,
                                   height: 100,
                                   decoration: BoxDecoration(
                                     borderRadius: BorderRadius.circular(50),
                                     boxShadow: [
                                       BoxShadow(
                                         color: Colors.cyan.withOpacity(0.3),
                                         blurRadius: 20,
                                         spreadRadius: 5,
                                       ),
                                     ],
                                   ),
                                   child: Lottie.asset(
                                     'assets/animations/Diver.json',
                                     fit: BoxFit.contain,
                                   ),
                                 ),
                               )
                                   .animate()
                                   .shimmer(duration: const Duration(seconds: 2)),
                             );
                           },
                         ),
                       ],
                     ),
                   );
                 },
                ),
              ),
            ),

            // Enhanced progress indicator at top
            SafeArea(
              child: Container(
                margin: const EdgeInsets.all(16),
                child: _buildEnhancedProgressIndicator(),
              ),
            ),

                         // Enhanced main content area
             Positioned(
               right: 16,
               left: MediaQuery.of(context).size.width * 0.35, // Start content area much further left
               top: 140,
               bottom: 16,
               child: Container(
                child: SlideTransition(
                  position: _contentSlideAnimation,
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: _buildEnhancedLessonContent(),
                  ),
                ),
              ),
            ),

            // Floating back button with ocean theme
            SafeArea(
              child: Positioned(
                top: 16,
                left: 170,
                child: _buildFloatingBackButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingBackButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withOpacity(0.8),
            Colors.blue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(delay: const Duration(milliseconds: 300))
        .shimmer(duration: const Duration(seconds: 2));
  }

  Widget _buildDepthIndicator(String depth, int lessonIndex, IconData icon) {
    bool isCurrentDepth = currentLessonIndex == lessonIndex;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentDepth 
            ? Colors.yellow.withOpacity(0.9)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentDepth 
              ? Colors.yellow
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: isCurrentDepth ? [
          BoxShadow(
            color: Colors.yellow.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isCurrentDepth 
                ? const Color(0xFF1E3A8A)
                : Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            depth,
            style: TextStyle(
              color: isCurrentDepth 
                  ? const Color(0xFF1E3A8A)
                  : Colors.white.withOpacity(0.7),
              fontSize: 11,
              fontWeight: isCurrentDepth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    )
        .animate(key: ValueKey('depth_$lessonIndex$isCurrentDepth'))
        .scale(
          delay: Duration(milliseconds: isCurrentDepth ? 0 : 200),
          duration: const Duration(milliseconds: 300),
        );
  }

  Widget _buildEnhancedProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school,
                  size: 16,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.courseTitle} • ${widget.moduleTitle}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: moduleProgress * _progressAnimation.value,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.yellow,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${currentLessonIndex + 1}/${lessons.length}',
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLessonContent() {
    if (lessons.isEmpty) return const SizedBox();
    
    final lesson = lessons[currentLessonIndex];
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced lesson title
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.withOpacity(0.9),
                      Colors.orange.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: Color(0xFF1E3A8A),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        lesson.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Lesson content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display content blocks
                      ...lesson.contentBlocks.map((block) => _buildContentBlock(block)),
                      
                      const SizedBox(height: 24),
                      
                      // Enhanced key points
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.cyan.withOpacity(0.2),
                              Colors.blue.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.cyan,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Key Points:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            ...lesson.keyPoints.asMap().entries.map((entry) => 
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(
                                            color: Color(0xFF1E3A8A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate(delay: Duration(milliseconds: entry.key * 100))
                                  .slideX(begin: 0.3, duration: const Duration(milliseconds: 400))
                                  .fadeIn(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Enhanced navigation buttons
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  if (currentLessonIndex > 0)
                    _buildNavButton(
                      onPressed: _previousLesson,
                      icon: Icons.arrow_back_ios,
                      label: 'Previous',
                      isPrimary: false,
                    )
                  else
                    const SizedBox(),
                  
                  // Next/Complete button
                  _buildNavButton(
                    onPressed: _nextLesson,
                    icon: currentLessonIndex == lessons.length - 1 
                        ? Icons.check_circle : Icons.arrow_forward_ios,
                    label: currentLessonIndex == lessons.length - 1 
                        ? 'Complete Presentation' : 'Next',
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrimary 
              ? [Colors.yellow, Colors.orange]
              : [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isPrimary 
                ? Colors.yellow.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? const Color(0xFF1E3A8A) : Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isPrimary ? const Color(0xFF1E3A8A) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .scale(delay: const Duration(milliseconds: 200))
        .shimmer(duration: const Duration(seconds: 2));
  }

  Widget _buildContentBlock(ContentBlock block) {
    switch (block.type) {
      case 'header':
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.content,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (block.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  block.subtitle!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      
      case 'paragraph':
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Text(
            block.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        );
      
      case 'image':
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      block.content,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '[Placeholder Image]',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (block.caption != null) ...[
                const SizedBox(height: 8),
                Text(
                  block.caption!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      
      case 'video':
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      block.content,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '[Video Player]',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (block.caption != null) ...[
                const SizedBox(height: 8),
                Text(
                  block.caption!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      
      case 'bullet_list':
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                block.content,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...block.items!.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      
      case 'quote':
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 24,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      block.content,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (block.subtitle != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    block.subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      
      default:
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Text(
            block.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
        );
    }
  }
}

class SurfaceWavePainter extends CustomPainter {
  final double animationValue;
  
  SurfaceWavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 12.0;
    final baseHeight = 40.0;
    
    // Create smoother wave motion with better frequency relationships
    path.moveTo(0, baseHeight);
    
    for (double x = 0; x <= size.width; x += 2) {
      // Primary wave - smooth and continuous with slower motion
      final primaryWave = sin((x / size.width * 4 * pi) + (animationValue * 2 * pi));
      
      // Secondary wave for complexity - harmonic frequency for seamless looping
      final secondaryWave = sin((x / size.width * 6 * pi) + (animationValue * -1 * pi)) * 0.7;
      
      // Tertiary wave for natural variation - very slow frequency
      final tertiaryWave = sin((x / size.width * 2 * pi) + (animationValue * 0.5 * pi)) * 0.4;
      
      // Combine waves with smooth amplitude control
      final combinedWave = primaryWave + secondaryWave + tertiaryWave;
      final y = baseHeight + (waveHeight * combinedWave);
      
      path.lineTo(x, y);
    }
    
    // Complete the path for filling
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
    
    // Add a second wave layer for depth effect
    final secondPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
      
    final secondPath = Path();
    secondPath.moveTo(0, baseHeight + 15);
    
    for (double x = 0; x <= size.width; x += 2) {
      final wave = sin((x / size.width * 3 * pi) + (animationValue * -2 * pi)) * 6;
      final y = baseHeight + 15 + wave;
      secondPath.lineTo(x, y);
    }
    
    secondPath.lineTo(size.width, 0);
    secondPath.lineTo(0, 0);
    secondPath.close();
    
    canvas.drawPath(secondPath, secondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 