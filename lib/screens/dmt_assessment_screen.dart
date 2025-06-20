import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import '../widgets/bubble_animation.dart';
import 'dmt_json_viewer_screen.dart';

class DMTAssessment {
  final String filename;
  final String id;
  final String code;
  final String description;
  final String type;
  final bool active;
  final int criteriaCount;

  DMTAssessment({
    required this.filename,
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.active,
    required this.criteriaCount,
  });

  factory DMTAssessment.fromJson(Map<String, dynamic> json) {
    return DMTAssessment(
      filename: json['filename'] ?? '',
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      active: json['active'] ?? false,
      criteriaCount: json['criteria_count'] ?? 0,
    );
  }
}

class DMTAssessmentScreen extends StatefulWidget {
  const DMTAssessmentScreen({super.key});

  @override
  State<DMTAssessmentScreen> createState() => _DMTAssessmentScreenState();
}

class _DMTAssessmentScreenState extends State<DMTAssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<DMTAssessment> dmtAssessments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _loadDMTAssessments();
    _startAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }

  Future<void> _loadDMTAssessments() async {
    try {
      final String summaryData = await rootBundle.loadString('assets/data/dmt/_summary.json');
      final Map<String, dynamic> summaryJson = json.decode(summaryData);
      
      final List<dynamic> assessmentsData = summaryJson['assessments_overview'];
      
      setState(() {
        dmtAssessments = assessmentsData
            .map((data) => DMTAssessment.fromJson(data))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading DMT assessments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }





  void _accessAssessment(DMTAssessment assessment) async {
    try {
      // Load the assessment JSON file
      final String assessmentData = await rootBundle.loadString('assets/data/dmt/${assessment.filename}');
      final Map<String, dynamic> assessmentJson = json.decode(assessmentData);
      
      // Navigate directly to JSON viewer screen
      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DMTJsonViewerScreen(
                  assessmentCode: assessment.code,
                  filename: assessment.filename,
                  assessmentData: assessmentJson,
                ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
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
      
    } catch (e) {
      _showErrorMessage('Error loading assessment: ${e.toString()}');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.teal.shade600,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background bubbles
            const Positioned.fill(
              child: BubbleAnimation(),
            ),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 20),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: MediaQuery.of(context).size.width < 600 ? 40 : 48,
                              ),
                              SizedBox(height: MediaQuery.of(context).size.width < 600 ? 12 : 16),
                              Text(
                                'DMT Assessments',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).size.width < 600 ? 6 : 8),
                              Text(
                                'Diver Medical Training - Practical Skills Assessments',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: MediaQuery.of(context).size.width < 600 ? 20 : 24),
                        
                        // Assessment list
                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : dmtAssessments.isEmpty
                                  ? Center(
                                      child: Text(
                                        'No assessments available',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                                                        : ListView.builder(
                                          itemCount: dmtAssessments.length,
                                          itemBuilder: (context, index) {
                                            final assessment = dmtAssessments[index];
                                            final isSmallScreen = MediaQuery.of(context).size.width < 600;
                                            return Container(
                                              margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () => _accessAssessment(assessment),
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: Container(
                                                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.2),
                                                  ),
                                                ),
                                                                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                                                              decoration: BoxDecoration(
                                                                color: Colors.orange.withOpacity(0.2),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              child: Icon(
                                                                Icons.assignment,
                                                                color: Colors.orange,
                                                                size: isSmallScreen ? 20 : 24,
                                                              ),
                                                            ),
                                                            SizedBox(width: isSmallScreen ? 12 : 16),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    assessment.code,
                                                                    style: TextStyle(
                                                                      fontSize: isSmallScreen ? 16 : 18,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: isSmallScreen ? 2 : 4),
                                                                  Text(
                                                                    '${assessment.criteriaCount} criteria',
                                                                    style: TextStyle(
                                                                      fontSize: isSmallScreen ? 12 : 14,
                                                                      color: Colors.white.withOpacity(0.7),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Icon(
                                                              Icons.chevron_right,
                                                              color: Colors.white.withOpacity(0.5),
                                                              size: isSmallScreen ? 24 : 28,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: isSmallScreen ? 12 : 16),
                                                        Text(
                                                          assessment.description,
                                                          style: TextStyle(
                                                            fontSize: isSmallScreen ? 13 : 14,
                                                            color: Colors.white.withOpacity(0.8),
                                                            height: 1.4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ).animate(delay: Duration(milliseconds: index * 100))
                                          .fadeIn(duration: const Duration(milliseconds: 600))
                                          .slideX(
                                            begin: 0.3,
                                            end: 0.0,
                                            duration: const Duration(milliseconds: 800),
                                            curve: Curves.easeOutCubic,
                                          );
                                      },
                                    ),
                        ),
                        
                        // Back button
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.1),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: MediaQuery.of(context).size.width < 600 ? 18 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              elevation: 0,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Back to CPD Island',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
