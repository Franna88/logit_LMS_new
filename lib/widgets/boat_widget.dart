import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';

class BoatWidget extends StatelessWidget {
  final bool isMoving;
  final AnimationController waveAnimation;

  const BoatWidget({
    super.key,
    required this.isMoving,
    required this.waveAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            sin(waveAnimation.value * 2 * 3.14159) * 3,
          ),
          child: Transform.rotate(
            angle: sin(waveAnimation.value * 2 * 3.14159) * 0.1,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/ship.png'),
                  fit: BoxFit.contain,
                ),
              ),
            )
                .animate(target: isMoving ? 1 : 0)
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: const Duration(milliseconds: 300),
                )
                .then()
                .shimmer(
                  duration: const Duration(milliseconds: 1000),
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
          ),
        );
      },
    );
  }
}

class BoatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final boatPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;

    final sailPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final mastPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw boat hull
    final hullPath = Path();
    hullPath.moveTo(size.width * 0.1, size.height * 0.7);
    hullPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.9,
      size.width * 0.9, size.height * 0.7,
    );
    hullPath.lineTo(size.width * 0.8, size.height * 0.6);
    hullPath.lineTo(size.width * 0.2, size.height * 0.6);
    hullPath.close();
    canvas.drawPath(hullPath, boatPaint);

    // Draw mast
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.1),
      mastPaint,
    );

    // Draw sail
    final sailPath = Path();
    sailPath.moveTo(size.width * 0.5, size.height * 0.1);
    sailPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.25,
      size.width * 0.5, size.height * 0.5,
    );
    sailPath.close();
    canvas.drawPath(sailPath, sailPaint);

    // Add some detail lines on the sail
    final detailPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.1 + (size.height * 0.4 * i / 4)),
        Offset(size.width * (0.5 + 0.25 * i / 4), size.height * (0.1 + 0.4 * i / 4)),
        detailPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 