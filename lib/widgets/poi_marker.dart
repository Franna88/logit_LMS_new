import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/poi.dart';

class POIMarker extends StatelessWidget {
  final POI poi;
  final VoidCallback onTap;

  const POIMarker({
    super.key,
    required this.poi,
    required this.onTap,
  });

  Color _getTypeColor() {
    switch (poi.type) {
      case 'island':
        return Colors.green;
      case 'reef':
        return Colors.orange;
      case 'wreck':
        return Colors.brown;
      case 'deep_water':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  String _getTypeImage() {
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

  @override
  Widget build(BuildContext context) {
    final hasNewCourses = poi.hasUnpurchasedCourses;
    final hasIncompleteCourses = poi.hasIncompleteCourses;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // POI marker
          Container(
            width: 135,
            height: 135,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main marker with POI image
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(_getTypeImage()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                
                // New course indicator
                if (hasNewCourses)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.2, 1.2),
                          duration: const Duration(milliseconds: 800),
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(1.0, 1.0),
                          duration: const Duration(milliseconds: 800),
                        ),
                  ),
                
                // Incomplete course indicator
                if (hasIncompleteCourses && !hasNewCourses)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                
                // Progress indicator ring
                if (poi.overallProgress > 0)
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: poi.overallProgress,
                      strokeWidth: 7,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        poi.overallProgress >= 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // POI name label
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              poi.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 600))
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 400),
            curve: Curves.elasticOut,
          ),
    );
  }
} 