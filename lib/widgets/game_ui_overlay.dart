import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_state_provider.dart';

class GameUIOverlay extends StatelessWidget {
  const GameUIOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<GameStateProvider>(
        builder: (context, gameState, child) {
          return Stack(
            children: [
              // Top bar with money and progress
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildTopBar(gameState),
              ),
              
              // Bottom instruction text
              Positioned(
                bottom: 32,
                left: 16,
                right: 16,
                child: _buildInstructionText(gameState),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(GameStateProvider gameState) {
    final completedCourses = gameState.pois
        .expand((poi) => poi.courses)
        .where((course) => course.isCompleted)
        .length;
    
    final totalCourses = gameState.pois
        .expand((poi) => poi.courses)
        .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Money display
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'R${gameState.playerMoney.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Progress display
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Courses',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$completedCourses / $totalCourses',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: -1,
          end: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        )
        .fadeIn(duration: const Duration(milliseconds: 400));
  }

  Widget _buildInstructionText(GameStateProvider gameState) {
    String instructionText;
    
    if (gameState.isBoatMoving) {
      instructionText = "🚢 Sailing to destination... Please wait for arrival";
    } else if (gameState.selectedPOI != null) {
      instructionText = "⚓ Arrived at ${gameState.selectedPOI!.name}! Tap anywhere to explore courses.";
    } else {
      instructionText = "🗺️ Tap on an island to sail there and discover diving courses!";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (gameState.isBoatMoving)
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(right: 12),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          Flexible(
            child: Text(
              instructionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
        )
        .fadeIn(duration: const Duration(milliseconds: 400));
  }
} 