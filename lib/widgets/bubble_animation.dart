import 'package:flutter/material.dart';
import 'dart:math';

class BubbleAnimation extends StatefulWidget {
  final Duration duration;
  final int bubbleCount;

  const BubbleAnimation({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.bubbleCount = 20,
  });

  @override
  State<BubbleAnimation> createState() => _BubbleAnimationState();
}

class _BubbleAnimationState extends State<BubbleAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Bubble> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeBubbles();
  }

  void _initializeBubbles() {
    _controllers = [];
    _animations = [];
    _bubbles = [];

    for (int i = 0; i < widget.bubbleCount; i++) {
      // Create controller with random duration for variety
      final controller = AnimationController(
        duration: Duration(
          milliseconds: 2000 + _random.nextInt(3000), // 2-5 seconds
        ),
        vsync: this,
      );

      // Create animation that goes from bottom to top
      final animation = Tween<double>(
        begin: 1.1, // Start below screen
        end: -0.1, // End above screen
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      // Create bubble with random properties
      final bubble = Bubble(
        x: _random.nextDouble(), // Random horizontal position (0-1)
        size: 5 + _random.nextDouble() * 15, // Size between 5-20
        opacity: 0.3 + _random.nextDouble() * 0.4, // Opacity 0.3-0.7
        wobbleSpeed: 0.5 + _random.nextDouble() * 1.5, // Wobble variation
        delay: _random.nextInt(1000), // Random start delay
      );

      _controllers.add(controller);
      _animations.add(animation);
      _bubbles.add(bubble);

      // Start animation with delay
      Future.delayed(Duration(milliseconds: bubble.delay), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(widget.bubbleCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final bubble = _bubbles[index];
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                
                // Calculate position with wobble effect
                final baseX = bubble.x * screenWidth;
                final wobbleOffset = sin(_animations[index].value * 10 * bubble.wobbleSpeed) * 20;
                final x = baseX + wobbleOffset;
                final y = _animations[index].value * screenHeight;

                return Positioned(
                  left: x - bubble.size / 2,
                  top: y,
                  child: Container(
                    width: bubble.size,
                    height: bubble.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(bubble.opacity * 0.8),
                          Colors.cyan.withOpacity(bubble.opacity * 0.4),
                          Colors.blue.withOpacity(bubble.opacity * 0.2),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(bubble.opacity * 0.3),
                          blurRadius: bubble.size * 0.3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class Bubble {
  final double x;
  final double size;
  final double opacity;
  final double wobbleSpeed;
  final int delay;

  Bubble({
    required this.x,
    required this.size,
    required this.opacity,
    required this.wobbleSpeed,
    required this.delay,
  });
}

class DivingBubbleTransition extends StatefulWidget {
  final Widget child;
  final Duration bubbleDuration;

  const DivingBubbleTransition({
    super.key,
    required this.child,
    this.bubbleDuration = const Duration(seconds: 4),
  });

  @override
  State<DivingBubbleTransition> createState() => _DivingBubbleTransitionState();
}

class _DivingBubbleTransitionState extends State<DivingBubbleTransition>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late Animation<double> _bubbleOpacity;
  late AnimationController _continuousBubbleController;
  late Animation<double> _continuousBubbleOpacity;

  @override
  void initState() {
    super.initState();
    
    _bubbleController = AnimationController(
      duration: widget.bubbleDuration,
      vsync: this,
    );

    _bubbleOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    // Controller for continuous bubbles on the left
    _continuousBubbleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _continuousBubbleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _continuousBubbleController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
    ));

    // Start initial bubble animation
    _bubbleController.forward();

    // Start continuous bubbles after initial animation
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _continuousBubbleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _continuousBubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Initial full-screen bubble overlay
        AnimatedBuilder(
          animation: _bubbleOpacity,
          builder: (context, child) {
            return Opacity(
              opacity: _bubbleOpacity.value,
              child: const BubbleAnimation(
                bubbleCount: 25,
              ),
            );
          },
        ),
        // Continuous left-side bubbles
        AnimatedBuilder(
          animation: _continuousBubbleOpacity,
          builder: (context, child) {
            return Opacity(
              opacity: _continuousBubbleOpacity.value,
              child: const LeftSideBubbleAnimation(),
            );
          },
        ),
      ],
    );
  }
}

class LeftSideBubbleAnimation extends StatefulWidget {
  const LeftSideBubbleAnimation({super.key});

  @override
  State<LeftSideBubbleAnimation> createState() => _LeftSideBubbleAnimationState();
}

class _LeftSideBubbleAnimationState extends State<LeftSideBubbleAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<Bubble> _bubbles;
  final Random _random = Random();
  final int bubbleCount = 8; // Fewer bubbles for left side

  @override
  void initState() {
    super.initState();
    _initializeBubbles();
  }

  void _initializeBubbles() {
    _controllers = [];
    _animations = [];
    _bubbles = [];

    for (int i = 0; i < bubbleCount; i++) {
      final controller = AnimationController(
        duration: Duration(
          milliseconds: 3000 + _random.nextInt(4000), // 3-7 seconds for slower flow
        ),
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 1.1,
        end: -0.1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));

      // Bubbles only appear on the left 30% of screen
      final bubble = Bubble(
        x: _random.nextDouble() * 0.3, // Left 30% of screen
        size: 3 + _random.nextDouble() * 8, // Smaller bubbles (3-11px)
        opacity: 0.2 + _random.nextDouble() * 0.3, // More subtle (0.2-0.5)
        wobbleSpeed: 0.3 + _random.nextDouble() * 0.8, // Gentler wobble
        delay: _random.nextInt(2000), // Spread out start times
      );

      _controllers.add(controller);
      _animations.add(animation);
      _bubbles.add(bubble);

      // Start animation with delay
      Future.delayed(Duration(milliseconds: bubble.delay), () {
        if (mounted) {
          controller.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(bubbleCount, (index) {
            return AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                final bubble = _bubbles[index];
                final screenHeight = MediaQuery.of(context).size.height;
                final screenWidth = MediaQuery.of(context).size.width;
                
                final baseX = bubble.x * screenWidth;
                final wobbleOffset = sin(_animations[index].value * 8 * bubble.wobbleSpeed) * 10;
                final x = baseX + wobbleOffset;
                final y = _animations[index].value * screenHeight;

                return Positioned(
                  left: x - bubble.size / 2,
                  top: y,
                  child: Container(
                    width: bubble.size,
                    height: bubble.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(bubble.opacity * 0.9),
                          Colors.lightBlueAccent.withOpacity(bubble.opacity * 0.5),
                          Colors.blue.withOpacity(bubble.opacity * 0.1),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(bubble.opacity * 0.4),
                          blurRadius: bubble.size * 0.4,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
} 