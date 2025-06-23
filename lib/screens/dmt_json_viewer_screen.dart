import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import '../widgets/bubble_animation.dart';

class DMTJsonViewerScreen extends StatefulWidget {
  final String assessmentCode;
  final String filename;
  final Map<String, dynamic> assessmentData;

  const DMTJsonViewerScreen({
    super.key,
    required this.assessmentCode,
    required this.filename,
    required this.assessmentData,
  });

  @override
  State<DMTJsonViewerScreen> createState() => _DMTJsonViewerScreenState();
}

class _DMTJsonViewerScreenState extends State<DMTJsonViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String selectedView = 'formatted';
  final List<String> viewOptions = ['formatted', 'assessment'];
  
  // Assessment data storage
  Map<int, Map<String, dynamic>> assessmentData = {};
  final Map<int, TextEditingController> commentControllers = {};
  final Map<int, TextEditingController> scoreControllers = {};
  
  // Overall assessment controllers
  late TextEditingController overallCommentsController;
  
  // Assessor login state
  bool isAssessorLoggedIn = false;
  String assessorName = '';
  String assessorUsername = '';
  
  // Assessment pagination
  int currentCriteriaIndex = 0;
  PageController pageController = PageController();
  bool showingFinalAssessment = false;

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

    // Initialize overall comments controller
    overallCommentsController = TextEditingController();

    _startAnimations();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    pageController.dispose();
    overallCommentsController.dispose();
    // Dispose all text controllers
    for (var controller in commentControllers.values) {
      controller.dispose();
    }
    for (var controller in scoreControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }



  Widget _buildFormattedView() {
    final metadata = widget.assessmentData['metadata'] as Map<String, dynamic>?;
    final assessment = widget.assessmentData['assessment'] as Map<String, dynamic>?;
    final scoreItems = widget.assessmentData['score_items'] as Map<String, dynamic>?;
    final relatedItems = scoreItems?['related'] as List<dynamic>?;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metadata Section
          if (metadata != null) ...[
            _buildSectionCard(
              'Assessment Metadata',
              Icons.info_outline,
              Colors.blue,
              [
                _buildInfoRow('Assessment ID', metadata['assessment_id'] ?? 'N/A'),
                _buildInfoRow('Assessment Code', metadata['assessment_code'] ?? 'N/A'),
                _buildInfoRow('Total Score Items', '${metadata['total_score_items'] ?? 0}'),
                _buildInfoRow('Source File', metadata['source_file'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Assessment Details Section
          if (assessment != null) ...[
            _buildSectionCard(
              'Assessment Details',
              Icons.assignment,
              Colors.orange,
              [
                _buildInfoRow('Description', assessment['description'] ?? 'N/A'),
                _buildInfoRow('Type', assessment['assessment_type'] ?? 'N/A'),
                _buildInfoRow('Norm', assessment['norm'] ?? 'N/A'),
                _buildInfoRow('Active', assessment['active'] == true ? 'Yes' : 'No'),
                _buildInfoRow('Auto Activate', assessment['auto_activate'] == true ? 'Yes' : 'No'),
                _buildInfoRow('Number of Retests', assessment['number_of_retests'] ?? 'N/A'),
                if (assessment['instruction'] != null)
                  _buildInfoRow('Instructions', assessment['instruction'], isLong: true),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Score Items Section
          if (relatedItems != null && relatedItems.isNotEmpty) ...[
            _buildSectionCard(
              'Assessment Criteria (${relatedItems.length} items)',
              Icons.checklist,
              Colors.green,
              relatedItems.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value as Map<String, dynamic>;
                return _buildCriteriaItem(index, item);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssessmentView() {
    if (!isAssessorLoggedIn) {
      return _buildAssessorLoginRequired();
    }
    
    final scoreItems = widget.assessmentData['score_items'] as Map<String, dynamic>?;
    final relatedItems = scoreItems?['related'] as List<dynamic>?;
    final assessment = widget.assessmentData['assessment'] as Map<String, dynamic>?;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;



    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Assessor Info Banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Logged in as: $assessorName ($assessorUsername)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _logoutAssessor,
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.green.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Student Information Card
          _buildSectionCard(
            'Student Information',
            Icons.person,
            Colors.blue,
            [
              _buildStudentInfoFields(),
            ],
          ),
          
          // Instructions Card
          if (assessment?['instruction'] != null) ...[
            _buildSectionCard(
              'Assessment Instructions',
              Icons.info,
              Colors.orange,
              [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    assessment!['instruction'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Assessment Criteria Section or Final Assessment
          if (showingFinalAssessment) ...[
            _buildFinalAssessmentView(relatedItems, isSmallScreen),
          ] else if (relatedItems != null && relatedItems.isNotEmpty) ...[
            _buildPaginatedAssessmentCriteria(relatedItems, isSmallScreen),
          ] else ...[
            // Show message if no criteria available
            _buildSectionCard(
              'Assessment Criteria',
              Icons.warning,
              Colors.orange,
              [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Text(
                    'No assessment criteria available for this assessment.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.white.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssessorLoginRequired() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: isSmallScreen ? 48 : 64,
              color: Colors.orange,
            ),
            SizedBox(height: isSmallScreen ? 16 : 24),
            
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'YOU CAN NOT PROCEED WITHOUT A QUALIFIED ASSESSOR LOGGING IN.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  
                  Text(
                    'Please ensure you have completed the study unit on wound assessment in order to show proficiency. Good Luck!\n\n'
                    'BRIEF: The assessor will give you clear and accurate feedback identifying any knowledge or skill gaps and the need for re-evaluation if required.\n\n'
                    'PRE-REQUISITE: This is a timed assessment. (Not facilitation)\n\n'
                    'TIME FRAME - You have 10 minutes.\n\n'
                    'PERFORMANCE LEVEL - (4) - You must perform this activity without assistance at an appropriate pace with a basic understanding of theory and practice principles.\n\n'
                    'VALIDITY - Scores are computer generated. On completion you may be required to record a maximum voice message or video following the 10 step wound assessment simulating report via Radio medical advice.\n\n'
                    'CANDIDATE DIRECTIVE: Identify the wound given to you by the assessor and perform a methodical 10 point wound assessment.',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: isSmallScreen ? 24 : 32),
            
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAssessorCodeDialog,
                icon: const Icon(Icons.login),
                label: const Text('Assessor Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 18 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: TextStyle(
                    fontSize: isSmallScreen ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  minimumSize: const Size(double.infinity, 50), // Ensure minimum touch target
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoFields() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSmallScreen) ...[
            // Stack fields vertically on small screens
            _buildInputField('Student Name', 'student_name'),
            const SizedBox(height: 16),
            _buildInputField('Student ID', 'student_id'),
            const SizedBox(height: 16),
            _buildInputField('Date', 'assessment_date', 
                initialValue: DateTime.now().toString().split(' ')[0]),
            const SizedBox(height: 16),
            _buildInputField('Location', 'location'),
          ] else ...[
            // Keep side-by-side layout on larger screens
            Row(
              children: [
                Expanded(
                  child: _buildInputField('Student Name', 'student_name'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField('Student ID', 'student_id'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField('Date', 'assessment_date', 
                      initialValue: DateTime.now().toString().split(' ')[0]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField('Location', 'location'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String key, {String? initialValue}) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: TextEditingController(text: initialValue ?? ''),
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 15 : 14,
              ),
              decoration: InputDecoration(
                hintText: 'Enter $label',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isSmallScreen ? 15 : 14,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 12,
                  horizontal: 12,
                ),
                constraints: BoxConstraints(
                  minHeight: isSmallScreen ? 50 : 44,
                ),
              ),
              onChanged: (value) {
                // Store the value in assessment data
                if (!assessmentData.containsKey(-1)) {
                  assessmentData[-1] = {};
                }
                assessmentData[-1]![key] = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveCriteriaItem(int index, Map<String, dynamic> item) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    // Initialize controllers if they don't exist
    if (!commentControllers.containsKey(index)) {
      commentControllers[index] = TextEditingController();
      scoreControllers[index] = TextEditingController();
      assessmentData[index] = {
        'score': '',
        'comments': '',
        'media': [],
        'competency': null,
      };
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
          // Criteria Header
          Container(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 10 : 12, 
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Criteria #$index',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                if (item['weight'] != null)
                  Text(
                    'Weight: ${item['weight']}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // What to Look For Button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showWhatToLookForDialog(index, item),
              icon: Icon(
                Icons.visibility,
                size: isSmallScreen ? 16 : 18,
              ),
              label: Text(
                'What to Look For',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 10,
                  horizontal: isSmallScreen ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Criteria Description
          Container(
            width: double.infinity,
            child: Text(
              item['description'] ?? 'No description',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Pass/Fail Toggle
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Competency Assessment:',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                _buildPassFailToggle(index),
              ],
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(int index, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Score:',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: scoreControllers[index],
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 15 : 14,
              ),
              decoration: InputDecoration(
                hintText: '0-100',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isSmallScreen ? 15 : 14,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 12,
                  horizontal: 12,
                ),
                constraints: BoxConstraints(
                  minHeight: isSmallScreen ? 50 : 44,
                ),
              ),
              onChanged: (value) {
                assessmentData[index]!['score'] = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(int index, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Comments:',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextField(
              controller: commentControllers[index],
              maxLines: isSmallScreen ? 3 : 2,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 15 : 14,
              ),
              decoration: InputDecoration(
                hintText: 'Assessment comments...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: isSmallScreen ? 15 : 14,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16 : 12,
                  horizontal: 12,
                ),
                constraints: BoxConstraints(
                  minHeight: isSmallScreen ? 80 : 60,
                ),
              ),
              onChanged: (value) {
                assessmentData[index]!['comments'] = value;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginatedAssessmentCriteria(List<dynamic> relatedItems, bool isSmallScreen) {
    return Column(
      children: [
        // Header with progress indicator
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(Icons.checklist, color: Colors.green, size: isSmallScreen ? 20 : 24),
                    SizedBox(width: isSmallScreen ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Assessment Criteria',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 12 : 16),
              
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Criteria ${currentCriteriaIndex + 1} of ${relatedItems.length}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                      vertical: isSmallScreen ? 4 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${((currentCriteriaIndex + 1) / relatedItems.length * 100).round()}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              // Progress bar
              Container(
                width: double.infinity,
                height: isSmallScreen ? 6 : 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (currentCriteriaIndex + 1) / relatedItems.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              // Quick navigation dots
              Container(
                width: double.infinity,
                child: relatedItems.length <= (isSmallScreen ? 15 : 20)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: relatedItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final isCompleted = assessmentData.containsKey(index + 1) && 
                              assessmentData[index + 1]!['competency'] != null;
                          final isCurrent = index == currentCriteriaIndex;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentCriteriaIndex = index;
                              });
                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 1.5 : 2),
                              width: isSmallScreen ? 6 : 8,
                              height: isSmallScreen ? 6 : 8,
                              decoration: BoxDecoration(
                                color: isCurrent 
                                    ? Colors.orange
                                    : isCompleted 
                                        ? Colors.green
                                        : Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isSmallScreen ? 3 : 4,
                        runSpacing: isSmallScreen ? 3 : 4,
                        children: relatedItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final isCompleted = assessmentData.containsKey(index + 1) && 
                              assessmentData[index + 1]!['competency'] != null;
                          final isCurrent = index == currentCriteriaIndex;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentCriteriaIndex = index;
                              });
                              pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: isSmallScreen ? 6 : 8,
                              height: isSmallScreen ? 6 : 8,
                              decoration: BoxDecoration(
                                color: isCurrent 
                                    ? Colors.orange
                                    : isCompleted 
                                        ? Colors.green
                                        : Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
        
        // Criteria content area
        Container(
          height: isSmallScreen ? 300 : 350,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentCriteriaIndex = index;
                });
              },
              itemCount: relatedItems.length,
              itemBuilder: (context, index) {
                final item = relatedItems[index] as Map<String, dynamic>;
                return _buildInteractiveCriteriaItem(index + 1, item);
              },
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Navigation buttons
        _buildNavigationButtons(relatedItems.length, relatedItems, isSmallScreen),
        

      ],
    );
  }

  Widget _buildNavigationButtons(int totalItems, List<dynamic> relatedItems, bool isSmallScreen) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentCriteriaIndex > 0 
                  ? () {
                      setState(() {
                        currentCriteriaIndex--;
                      });
                      pageController.animateToPage(
                        currentCriteriaIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: Icon(Icons.arrow_back, size: isSmallScreen ? 20 : 18),
              label: Text(
                'Previous',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentCriteriaIndex > 0 
                    ? Colors.blue.withOpacity(0.8)
                    : Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 12 : 16),
          
          // Next/Complete button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentCriteriaIndex < totalItems - 1
                  ? () {
                      setState(() {
                        currentCriteriaIndex++;
                      });
                      pageController.animateToPage(
                        currentCriteriaIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : _areAllCriteriaCompleted(relatedItems)
                      ? () {
                          setState(() {
                            showingFinalAssessment = true;
                          });
                        }
                      : null,
              icon: Icon(
                currentCriteriaIndex == totalItems - 1 && _areAllCriteriaCompleted(relatedItems)
                    ? Icons.check_circle
                    : Icons.arrow_forward,
                size: isSmallScreen ? 20 : 18,
              ),
              label: Text(
                currentCriteriaIndex == totalItems - 1 && _areAllCriteriaCompleted(relatedItems)
                    ? 'Complete Assessment'
                    : 'Next',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: currentCriteriaIndex < totalItems - 1
                    ? Colors.green.withOpacity(0.8)
                    : _areAllCriteriaCompleted(relatedItems)
                        ? Colors.orange.withOpacity(0.8)
                        : Colors.grey.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassFailToggle(int index) {
    final currentValue = assessmentData[index]?['competency'];
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: isSmallScreen ? 10 : 12,
        runSpacing: isSmallScreen ? 10 : 12,
        alignment: WrapAlignment.center,
        children: [
          _buildToggleButton(
            'Competent',
            currentValue == 'competent',
            Colors.green,
            () {
              setState(() {
                assessmentData[index]!['competency'] = 'competent';
              });
            },
          ),
          _buildToggleButton(
            'Not Yet Competent',
            currentValue == 'not_yet_competent',
            Colors.orange,
            () {
              setState(() {
                assessmentData[index]!['competency'] = 'not_yet_competent';
              });
            },
          ),
          _buildToggleButton(
            'Skill Gap',
            currentValue == 'skill_gap',
            Colors.orange,
            () {
              setState(() {
                assessmentData[index]!['competency'] = 'skill_gap';
              });
            },
          ),
          _buildToggleButton(
            'Knowledge Gap',
            currentValue == 'knowledge_gap',
            Colors.red,
            () {
              setState(() {
                assessmentData[index]!['competency'] = 'knowledge_gap';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, Color color, VoidCallback onTap) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minWidth: isSmallScreen ? 120 : 100,
          minHeight: isSmallScreen ? 56 : 48,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 14, 
          vertical: isSmallScreen ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : color,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaUploadSection(int index) {
    final mediaList = assessmentData[index]!['media'] as List<dynamic>;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evidence & Media:',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                _buildMediaUploadButtons(index),
              ],
            ),
          ),
          
          if (mediaList.isNotEmpty) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            Container(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mediaList.asMap().entries.map((entry) {
                  final mediaIndex = entry.key;
                  final media = entry.value as Map<String, dynamic>;
                  return _buildMediaChip(index, mediaIndex, media);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaUploadButtons(int index) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    if (isSmallScreen) {
      // Stack vertically on small screens for better touch targets
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMediaButton(
                  Icons.camera_alt,
                  'Photo',
                  () => _simulateMediaUpload(index, 'photo'),
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMediaButton(
                  Icons.video_camera_back,
                  'Video',
                  () => _simulateMediaUpload(index, 'video'),
                  isFullWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMediaButton(
            Icons.attach_file,
            'File',
            () => _simulateMediaUpload(index, 'file'),
            isFullWidth: true,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          _buildMediaButton(
            Icons.camera_alt,
            'Photo',
            () => _simulateMediaUpload(index, 'photo'),
          ),
          const SizedBox(width: 8),
          _buildMediaButton(
            Icons.video_camera_back,
            'Video',
            () => _simulateMediaUpload(index, 'video'),
          ),
          const SizedBox(width: 8),
          _buildMediaButton(
            Icons.attach_file,
            'File',
            () => _simulateMediaUpload(index, 'file'),
          ),
        ],
      );
    }
  }

  Widget _buildMediaButton(IconData icon, String label, VoidCallback onTap, {bool isFullWidth = false}) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 8, 
          vertical: isSmallScreen ? 12 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.orange.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon, 
              size: isSmallScreen ? 18 : 14, 
              color: Colors.orange,
            ),
            SizedBox(width: isSmallScreen ? 8 : 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 12,
                color: Colors.orange.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaChip(int criteriaIndex, int mediaIndex, Map<String, dynamic> media) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.blue.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getMediaIcon(media['type']),
            size: 14,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            media['name'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.withOpacity(0.9),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeMedia(criteriaIndex, mediaIndex),
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMediaIcon(String? type) {
    switch (type) {
      case 'photo':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'file':
        return Icons.insert_drive_file;
      default:
        return Icons.attach_file;
    }
  }

  void _simulateMediaUpload(int criteriaIndex, String type) {
    // In a real app, this would open camera/gallery/file picker
    final media = {
      'type': type,
      'name': '${type}_${DateTime.now().millisecondsSinceEpoch}.${type == 'photo' ? 'jpg' : type == 'video' ? 'mp4' : 'pdf'}',
      'timestamp': DateTime.now().toIso8601String(),
      'size': '2.5 MB', // Simulated
    };
    
    setState(() {
      (assessmentData[criteriaIndex]!['media'] as List<dynamic>).add(media);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.toUpperCase()} uploaded successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeMedia(int criteriaIndex, int mediaIndex) {
    setState(() {
      (assessmentData[criteriaIndex]!['media'] as List<dynamic>).removeAt(mediaIndex);
    });
  }

  Widget _buildSubmitSection() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final scoreItems = widget.assessmentData['score_items'] as Map<String, dynamic>?;
    final relatedItems = scoreItems?['related'] as List<dynamic>?;
    
    // Calculate final score based on competency assessments
    double finalScore = _calculateFinalScore(relatedItems);
    bool passed = finalScore >= 75.0;
    
    return Column(
      children: [
        // Final Score Section
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.grade, color: Colors.orange, size: isSmallScreen ? 20 : 24),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'Final Assessment Score',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                decoration: BoxDecoration(
                  color: passed ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: passed ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${finalScore.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 36,
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Text(
                      passed ? 'PASSED' : 'FAILED',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color: passed ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 4 : 6),
                    Text(
                      'Minimum Required: 75%',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Overall Comments Section
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
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
                  Icon(Icons.comment, color: Colors.blue, size: isSmallScreen ? 20 : 24),
                  SizedBox(width: isSmallScreen ? 8 : 12),
                  Text(
                    'Overall Assessment Comments',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              TextField(
                controller: _getOverallCommentsController(),
                maxLines: isSmallScreen ? 4 : 3,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 15 : 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Provide overall assessment feedback, areas for improvement, and recommendations...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: isSmallScreen ? 15 : 14,
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 16 : 12,
                    horizontal: 12,
                  ),
                ),
                onChanged: (value) {
                  if (!assessmentData.containsKey(-1)) {
                    assessmentData[-1] = {};
                  }
                  assessmentData[-1]!['overall_comments'] = value;
                },
              ),
            ],
          ),
        ),
        
        // Evidence & Media Section
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
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
                   Icon(Icons.attach_file, color: Colors.blue, size: isSmallScreen ? 20 : 24),
                   SizedBox(width: isSmallScreen ? 8 : 12),
                   Text(
                     'Assessment Evidence & Media',
                     style: TextStyle(
                       fontSize: isSmallScreen ? 16 : 18,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                     ),
                   ),
                 ],
               ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              _buildOverallMediaUploadSection(),
            ],
          ),
        ),
        
        // Submit Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Assessment Complete',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'Review all sections and submit the assessment',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 16 : 20),
              MediaQuery.of(context).size.width < 600
                  ? Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saveAssessment,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Draft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitAssessment,
                            icon: const Icon(Icons.send),
                            label: const Text('Submit Assessment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveAssessment,
                            icon: const Icon(Icons.save),
                            label: const Text('Save Draft'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitAssessment,
                            icon: const Icon(Icons.send),
                            label: const Text('Submit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveAssessment() {
    // In a real app, this would save to local storage or send to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assessment saved as draft'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitAssessment() {
    // Validate that all criteria have been assessed
    final scoreItems = widget.assessmentData['score_items'] as Map<String, dynamic>?;
    final relatedItems = scoreItems?['related'] as List<dynamic>?;
    
    if (relatedItems != null) {
      for (int i = 1; i <= relatedItems.length; i++) {
        if (!assessmentData.containsKey(i) || assessmentData[i]!['competency'] == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please complete competency assessment for Criteria #$i'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }
      
      // Calculate final score based on competency
      final finalScore = _calculateFinalScore(relatedItems);
      final passed = finalScore >= 75.0;
      
      // Show confirmation dialog with score information
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.blue.shade900,
          title: const Text(
            'Submit Assessment',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assessment Summary:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Final Score: ${finalScore.toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Minimum Required: 75%',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: passed ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  passed ? 'PASSED' : 'FAILED',
                  style: TextStyle(
                    color: passed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to submit this assessment? This action cannot be undone.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performSubmit(finalScore, passed);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    }
  }

  void _performSubmit(double averageScore, bool passed) {
    // In a real app, this would send the assessment data to backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          passed 
            ? 'Assessment submitted successfully! Score: ${averageScore.toStringAsFixed(1)}% - PASSED'
            : 'Assessment submitted. Score: ${averageScore.toStringAsFixed(1)}% - FAILED (Minimum 75% required)'
        ),
        backgroundColor: passed ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    
    // Navigate back after submission
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _logoutAssessor() {
    setState(() {
      isAssessorLoggedIn = false;
      assessorName = '';
      assessorUsername = '';
      // Clear all assessment data
      assessmentData.clear();
      // Dispose and clear controllers
      for (var controller in commentControllers.values) {
        controller.dispose();
      }
      for (var controller in scoreControllers.values) {
        controller.dispose();
      }
      commentControllers.clear();
      scoreControllers.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assessor logged out'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAssessorCodeDialog() {
    final TextEditingController codeController = TextEditingController();
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900.withOpacity(0.95),
                Colors.blue.shade700.withOpacity(0.95),
                Colors.teal.shade600.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Assessor Code Required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.assessmentCode,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Code input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter 6-digit Assessor Code:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '------',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 24,
                          letterSpacing: 8,
                        ),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _validateAssessorCode(codeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        ),
    );
  }

  void _validateAssessorCode(String code) {
    if (code.length != 6) {
      _showErrorMessage('Please enter a 6-digit code');
      return;
    }
    
    // For demo purposes, accept any 6-digit code
    // In production, you would validate against a backend
    Navigator.of(context).pop(); // Close the dialog
    _showAssessorLoginDialog();
  }

  void _showAssessorLoginDialog() {
    final TextEditingController usernameController = TextEditingController(text: 'assessor.demo');
    final TextEditingController passwordController = TextEditingController(text: 'demo123');
    final TextEditingController firstNameController = TextEditingController(text: 'John');
    final TextEditingController lastNameController = TextEditingController(text: 'Smith');
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 400,
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900.withOpacity(0.95),
                Colors.blue.shade700.withOpacity(0.95),
                Colors.teal.shade600.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Assessor Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Access ${widget.assessmentCode}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Name
                      Text(
                        'First Name:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: firstNameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Last Name
                      Text(
                        'Last Name:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: lastNameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Username
                      Text(
                        'Username:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: usernameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password
                      Text(
                        'Password:',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Demo note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo mode - fields are pre-filled for testing',
                          style: TextStyle(
                            color: Colors.orange.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _performAssessorLogin(
                          usernameController.text,
                          passwordController.text,
                          firstNameController.text,
                          lastNameController.text,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        ),
    );
  }

  void _performAssessorLogin(String username, String password, String firstName, String lastName) {
    // No actual authentication - just validate fields are not empty
    if (username.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _showErrorMessage('Please fill in all fields');
      return;
    }
    
    setState(() {
      isAssessorLoggedIn = true;
      assessorName = '$firstName $lastName';
      assessorUsername = username;
    });
    
    Navigator.of(context).pop(); // Close the login dialog
    _showSuccessMessage('Welcome, $firstName $lastName!');
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

  void _showWhatToLookForDialog(int criteriaIndex, Map<String, dynamic> item) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade900.withOpacity(0.95),
                Colors.blue.shade700.withOpacity(0.95),
                Colors.teal.shade600.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.visibility,
                        color: Colors.orange,
                        size: isSmallScreen ? 28 : 32,
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Text(
                        'What to Look For',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 18 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Text(
                        'Criteria #$criteriaIndex Assessment Guide',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Criteria Description
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: Colors.blue,
                            size: isSmallScreen ? 16 : 18,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            'Criteria Description',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        item['description'] ?? 'No description available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallScreen ? 13 : 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // Assessment Guidelines
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.checklist,
                            color: Colors.green,
                            size: isSmallScreen ? 16 : 18,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            'Assessment Guidelines',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      ..._buildAssessmentGuidelines(criteriaIndex, item, isSmallScreen),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 12 : 16),
                
                // Scoring Guide
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                        children: [
                          Icon(
                            Icons.grade,
                            color: Colors.orange,
                            size: isSmallScreen ? 16 : 18,
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Text(
                            'Scoring Guide',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      ..._buildScoringGuide(isSmallScreen),
                    ],
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 16 : 20),
                
                // Close button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontSize: isSmallScreen ? 16 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        ),
    );
  }

  List<Widget> _buildAssessmentGuidelines(int criteriaIndex, Map<String, dynamic> item, bool isSmallScreen) {
    // Generate specific guidelines based on criteria type and description
    final description = item['description']?.toString().toLowerCase() ?? '';
    List<String> guidelines = [];
    
    // Determine guidelines based on keywords in the description
    if (description.contains('wound') || description.contains('injury')) {
      guidelines = [
        '• Observe the wound location, size, and depth',
        '• Check for signs of infection (redness, swelling, warmth)',
        '• Assess bleeding control and clotting',
        '• Evaluate pain response and patient comfort',
        '• Document any foreign objects or debris',
        '• Check circulation around the wound area',
      ];
    } else if (description.contains('airway') || description.contains('breathing')) {
      guidelines = [
        '• Check airway patency and obstruction',
        '• Observe breathing rate and rhythm',
        '• Listen for abnormal breathing sounds',
        '• Assess chest rise and fall symmetry',
        '• Check oxygen saturation if available',
        '• Monitor for signs of respiratory distress',
      ];
    } else if (description.contains('circulation') || description.contains('pulse')) {
      guidelines = [
        '• Check pulse rate, rhythm, and strength',
        '• Assess capillary refill time',
        '• Look for signs of shock or blood loss',
        '• Check skin color and temperature',
        '• Monitor blood pressure if possible',
        '• Assess peripheral circulation',
      ];
    } else if (description.contains('neurological') || description.contains('consciousness')) {
      guidelines = [
        '• Assess level of consciousness (AVPU scale)',
        '• Check pupil response and size',
        '• Test basic motor function',
        '• Evaluate speech and comprehension',
        '• Look for signs of head injury',
        '• Monitor for changes in mental status',
      ];
    } else {
      // Generic guidelines for any medical assessment
      guidelines = [
        '• Follow systematic assessment approach',
        '• Maintain patient safety throughout',
        '• Document findings accurately',
        '• Communicate clearly with patient',
        '• Use appropriate medical equipment',
        '• Apply relevant medical protocols',
      ];
    }
    
    return guidelines.map((guideline) => Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      child: Text(
        guideline,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: isSmallScreen ? 12 : 13,
          height: 1.4,
        ),
      ),
    )).toList();
  }

  List<Widget> _buildScoringGuide(bool isSmallScreen) {
    final scoringCriteria = [
      {'range': '90-100', 'description': 'Excellent - All steps performed correctly and efficiently (PASS)', 'color': Colors.green},
      {'range': '80-89', 'description': 'Good - Most steps performed correctly with minor issues (PASS)', 'color': Colors.lightGreen},
      {'range': '75-79', 'description': 'Satisfactory - Adequate performance, minimum passing grade (PASS)', 'color': Colors.orange},
      {'range': '60-74', 'description': 'Below Standard - Significant issues requiring improvement (FAIL)', 'color': Colors.deepOrange},
      {'range': '0-59', 'description': 'Unsatisfactory - Major deficiencies, requires retraining (FAIL)', 'color': Colors.red},
    ];
    
    return scoringCriteria.map((criteria) => Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
      decoration: BoxDecoration(
        color: (criteria['color'] as Color).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (criteria['color'] as Color).withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: criteria['color'] as Color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              criteria['range'] as String,
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 12),
          Expanded(
            child: Text(
              criteria['description'] as String,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 11 : 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }



  Widget _buildSectionCard(String title, IconData icon, Color color, List<Widget> children) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Section content
          if (children.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: isLong
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCriteriaItem(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['description'] ?? 'No description',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (item['weight'] != null || item['sort_code'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (item['weight'] != null) ...[
                  Text(
                    'Weight: ${item['weight']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                if (item['sort_code'] != null)
                  Text(
                    'Sort: ${item['sort_code']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double _calculateFinalScore(List<dynamic>? relatedItems) {
    if (relatedItems == null || relatedItems.isEmpty) return 0.0;
    
    int competentCount = 0;
    int totalCount = 0;
    
    for (int i = 1; i <= relatedItems.length; i++) {
      if (assessmentData.containsKey(i)) {
        totalCount++;
        final competency = assessmentData[i]!['competency'];
        if (competency == 'competent') {
          competentCount++;
        }
      }
    }
    
    if (totalCount == 0) return 0.0;
    return (competentCount / totalCount) * 100.0;
  }
  
  bool _areAllCriteriaCompleted(List<dynamic>? relatedItems) {
    if (relatedItems == null || relatedItems.isEmpty) return false;
    
    for (int i = 1; i <= relatedItems.length; i++) {
      if (!assessmentData.containsKey(i) || assessmentData[i]!['competency'] == null) {
        return false;
      }
    }
    return true;
  }
  
  Widget _buildFinalAssessmentView(List<dynamic>? relatedItems, bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        children: [
          // Back to Criteria Button
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  showingFinalAssessment = false;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Criteria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Final Assessment Title
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
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
                  Icons.assignment_turned_in,
                  color: Colors.green,
                  size: isSmallScreen ? 32 : 40,
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
                Text(
                  'Final Assessment',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                Text(
                  'Complete your overall assessment and submit',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Final Assessment Sections
          _buildSubmitSection(),
        ],
      ),
    );
  }
  
  TextEditingController _getOverallCommentsController() {
    return overallCommentsController;
  }
  
  Widget _buildOverallMediaUploadSection() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    // Initialize overall media list if it doesn't exist
    if (!assessmentData.containsKey(-1)) {
      assessmentData[-1] = {};
    }
    if (!assessmentData[-1]!.containsKey('overall_media')) {
      assessmentData[-1]!['overall_media'] = <dynamic>[];
    }
    
    final mediaList = assessmentData[-1]!['overall_media'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverallMediaUploadButtons(),
        if (mediaList.isNotEmpty) ...[
          SizedBox(height: isSmallScreen ? 12 : 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mediaList.asMap().entries.map((entry) {
              final mediaIndex = entry.key;
              final media = entry.value as Map<String, dynamic>;
              return _buildOverallMediaChip(mediaIndex, media);
            }).toList(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildOverallMediaUploadButtons() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    if (isSmallScreen) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildOverallMediaButton(
                  Icons.camera_alt,
                  'Photo',
                  () => _simulateOverallMediaUpload('photo'),
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOverallMediaButton(
                  Icons.video_camera_back,
                  'Video',
                  () => _simulateOverallMediaUpload('video'),
                  isFullWidth: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildOverallMediaButton(
            Icons.attach_file,
            'File',
            () => _simulateOverallMediaUpload('file'),
            isFullWidth: true,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          _buildOverallMediaButton(
            Icons.camera_alt,
            'Photo',
            () => _simulateOverallMediaUpload('photo'),
          ),
          const SizedBox(width: 8),
          _buildOverallMediaButton(
            Icons.video_camera_back,
            'Video',
            () => _simulateOverallMediaUpload('video'),
          ),
          const SizedBox(width: 8),
          _buildOverallMediaButton(
            Icons.attach_file,
            'File',
            () => _simulateOverallMediaUpload('file'),
          ),
        ],
      );
    }
  }
  
  Widget _buildOverallMediaButton(IconData icon, String label, VoidCallback onTap, {bool isFullWidth = false}) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 8, 
          vertical: isSmallScreen ? 12 : 4,
        ),
                 decoration: BoxDecoration(
           color: Colors.blue,
           borderRadius: BorderRadius.circular(8),
           border: Border.all(
             color: Colors.blue,
           ),
         ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
                         Icon(
               icon, 
               size: isSmallScreen ? 18 : 14, 
               color: Colors.white,
             ),
             SizedBox(width: isSmallScreen ? 8 : 4),
             Text(
               label,
               style: TextStyle(
                 fontSize: isSmallScreen ? 14 : 12,
                 color: Colors.white,
                 fontWeight: FontWeight.w500,
               ),
             ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOverallMediaChip(int mediaIndex, Map<String, dynamic> media) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
         color: Colors.blue.withOpacity(0.2),
         borderRadius: BorderRadius.circular(6),
         border: Border.all(
           color: Colors.blue.withOpacity(0.5),
         ),
       ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
                     Icon(
             _getMediaIcon(media['type']),
             size: 14,
             color: Colors.blue,
           ),
           const SizedBox(width: 4),
           Text(
             media['name'] ?? 'Unknown',
             style: TextStyle(
               fontSize: 12,
               color: Colors.blue.withOpacity(0.9),
             ),
           ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeOverallMedia(mediaIndex),
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  void _simulateOverallMediaUpload(String type) {
    final media = {
      'type': type,
      'name': '${type}_${DateTime.now().millisecondsSinceEpoch}.${type == 'photo' ? 'jpg' : type == 'video' ? 'mp4' : 'pdf'}',
      'timestamp': DateTime.now().toIso8601String(),
      'size': '2.5 MB',
    };
    
    setState(() {
      (assessmentData[-1]!['overall_media'] as List<dynamic>).add(media);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.toUpperCase()} uploaded successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _removeOverallMedia(int mediaIndex) {
    setState(() {
      (assessmentData[-1]!['overall_media'] as List<dynamic>).removeAt(mediaIndex);
    });
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
            // Main content
            SafeArea(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16 : 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: const Size(44, 44), // Minimum touch target
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.assessmentCode,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width < 600 ? 18 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        widget.filename,
                                        style: TextStyle(
                                          fontSize: MediaQuery.of(context).size.width < 600 ? 12 : 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: MediaQuery.of(context).size.width < 600 ? 16 : 20),
                            
                            // View toggle
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: viewOptions.map((option) {
                                  final isSelected = selectedView == option;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => selectedView = option),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: MediaQuery.of(context).size.width < 600 ? 14 : 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? Colors.orange 
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          option == 'formatted' ? 'View' : 'Assess',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected 
                                                ? Colors.white 
                                                : Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Content
                      Expanded(
                        child: selectedView == 'formatted'
                            ? _buildFormattedView()
                            : _buildAssessmentView(),
                      ),
                    ],
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