import 'package:flutter/material.dart';
import '../../models/content_dev/assessment.dart';

class AssessmentCreationScreen extends StatefulWidget {
  const AssessmentCreationScreen({super.key});

  @override
  State<AssessmentCreationScreen> createState() => _AssessmentCreationScreenState();
}

class _AssessmentCreationScreenState extends State<AssessmentCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Creation'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF06B6D4),
            ],
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                                         Icon(
                       Icons.quiz,
                       size: 64,
                       color: Color(0xFF1E3A8A),
                     ),
                    SizedBox(height: 16),
                    Text(
                      'Assessment Creation',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create and manage course assessments and quizzes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                                         Text(
                       'Coming Soon!',
                       style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.w500,
                         color: Color(0xFF3B82F6),
                       ),
                     ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 