import 'package:flutter/material.dart';
import 'dart:math';

class WavePainter extends CustomPainter {
  final double animationValue;
  
  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20.0;
    final waveLength = size.width / 3;

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height * 0.7 + 
          waveHeight * 
          (sin((x / waveLength * 2 * 3.14159) + (animationValue * 2 * 3.14159)) +
           sin((x / (waveLength * 0.7) * 2 * 3.14159) + (animationValue * 3 * 3.14159)) * 0.5);
      
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 