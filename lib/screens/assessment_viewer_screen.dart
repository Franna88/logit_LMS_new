import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'dart:async';
import '../widgets/bubble_animation.dart';

class Question {
  final String id;
  final String type; // 'multiple_choice', 'true_false', 'multiple_answer', 'short_answer'
  final String question;
  final List<String> options;
  final List<String> correctAnswers;
  final String explanation;

  Question({
    required this.id,
    required this.type,
    required this.question,
    this.options = const [],
    required this.correctAnswers,
    required this.explanation,
  });
}

class AssessmentViewerScreen extends StatefulWidget {
  final String assessmentTitle;
  final String moduleTitle;
  final String courseTitle;

  const AssessmentViewerScreen({
    super.key,
    required this.assessmentTitle,
    required this.moduleTitle,
    required this.courseTitle,
  });

  @override
  State<AssessmentViewerScreen> createState() => _AssessmentViewerScreenState();
}

class _AssessmentViewerScreenState extends State<AssessmentViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<Question> questions = [];
  Map<String, dynamic> userAnswers = {};
  int currentQuestionIndex = 0;
  bool isAssessmentStarted = false;
  bool isAssessmentCompleted = false;
  bool showResults = false;
  
  // Timer variables
  Timer? assessmentTimer;
  int timeRemainingSeconds = 1800; // 30 minutes
  bool isTimerWarning = false;

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
      begin: const Offset(1.0, 0.0),
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

    _generateDummyQuestions();
    _startAnimations();
  }

  void _generateDummyQuestions() {
    questions = [
      Question(
        id: 'q1',
        type: 'multiple_choice',
        question: 'What is the maximum depth for Open Water divers?',
        options: ['18 meters (60 feet)', '30 meters (100 feet)', '40 meters (130 feet)', '50 meters (165 feet)'],
        correctAnswers: ['18 meters (60 feet)'],
        explanation: 'Open Water divers are certified to dive to a maximum depth of 18 meters (60 feet). This depth limit ensures safety while building experience.',
      ),
      Question(
        id: 'q2',
        type: 'true_false',
        question: 'You should never hold your breath while ascending during a scuba dive.',
        options: ['True', 'False'],
        correctAnswers: ['True'],
        explanation: 'Never hold your breath while ascending. As you ascend, the air in your lungs expands due to decreasing pressure, which can cause serious lung injuries.',
      ),
      Question(
        id: 'q3',
        type: 'multiple_answer',
        question: 'Which of the following are signs of nitrogen narcosis? (Select all that apply)',
        options: ['Euphoria', 'Impaired judgment', 'Tunnel vision', 'Increased heart rate', 'Confusion'],
        correctAnswers: ['Euphoria', 'Impaired judgment', 'Tunnel vision', 'Confusion'],
        explanation: 'Nitrogen narcosis symptoms include euphoria, impaired judgment, tunnel vision, and confusion. Increased heart rate is not typically a direct symptom.',
      ),
      Question(
        id: 'q4',
        type: 'multiple_choice',
        question: 'What does BCD stand for in diving equipment?',
        options: ['Breathing Control Device', 'Buoyancy Control Device', 'Basic Compression Device', 'Backup Control Device'],
        correctAnswers: ['Buoyancy Control Device'],
        explanation: 'BCD stands for Buoyancy Control Device. It helps divers achieve neutral buoyancy by adding or releasing air.',
      ),
      Question(
        id: 'q5',
        type: 'short_answer',
        question: 'Explain the buddy system in diving and why it is important.',
        options: [],
        correctAnswers: ['The buddy system involves diving with a partner for safety, mutual assistance, and emergency support.'],
        explanation: 'The buddy system is fundamental to safe diving. Divers should stay close to their buddy, communicate regularly, and be prepared to assist each other in emergencies.',
      ),
      Question(
        id: 'q6',
        type: 'true_false',
        question: 'Decompression stops are required for all recreational dives.',
        options: ['True', 'False'],
        correctAnswers: ['False'],
        explanation: 'Decompression stops are not required for all recreational dives. They are only necessary when diving beyond no-decompression limits or as a safety precaution.',
      ),
      Question(
        id: 'q7',
        type: 'multiple_choice',
        question: 'What is the recommended ascent rate for recreational diving?',
        options: ['5 meters per minute', '9 meters per minute', '18 meters per minute', '30 meters per minute'],
        correctAnswers: ['9 meters per minute'],
        explanation: 'The recommended ascent rate is 9 meters (30 feet) per minute or slower. This allows your body to safely eliminate absorbed nitrogen.',
      ),
      Question(
        id: 'q8',
        type: 'multiple_answer',
        question: 'Which factors affect air consumption underwater? (Select all that apply)',
        options: ['Depth', 'Physical exertion', 'Water temperature', 'Experience level', 'Equipment weight'],
        correctAnswers: ['Depth', 'Physical exertion', 'Water temperature', 'Experience level'],
        explanation: 'Air consumption is affected by depth (pressure), physical exertion, water temperature (cold increases consumption), and experience level. Equipment weight affects buoyancy but not directly air consumption.',
      ),
    ];
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }

  void _startAssessment() {
    setState(() {
      isAssessmentStarted = true;
    });
    
    // Start timer
    assessmentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeRemainingSeconds--;
        isTimerWarning = timeRemainingSeconds <= 300; // Warning when 5 minutes left
        
        if (timeRemainingSeconds <= 0) {
          _completeAssessment();
        }
      });
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      _completeAssessment();
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void _completeAssessment() {
    assessmentTimer?.cancel();
    setState(() {
      isAssessmentCompleted = true;
      showResults = true;
    });
  }

  void _selectAnswer(String questionId, dynamic answer) {
    setState(() {
      final question = questions.firstWhere((q) => q.id == questionId);
      if (question.type == 'multiple_answer') {
        List<String> currentAnswers = List<String>.from(userAnswers[questionId] ?? []);
        if (currentAnswers.contains(answer)) {
          currentAnswers.remove(answer);
        } else {
          currentAnswers.add(answer);
        }
        userAnswers[questionId] = currentAnswers;
      } else {
        userAnswers[questionId] = answer;
      }
    });
  }

  double _calculateScore() {
    int correctAnswers = 0;
    for (Question question in questions) {
      final userAnswer = userAnswers[question.id];
      if (userAnswer != null) {
        if (question.type == 'multiple_answer') {
          List<String> userList = List<String>.from(userAnswer);
          List<String> correctList = question.correctAnswers;
          if (userList.length == correctList.length &&
              userList.every((answer) => correctList.contains(answer))) {
            correctAnswers++;
          }
        } else if (question.type == 'short_answer') {
          // For demo purposes, consider any non-empty answer as correct
          if (userAnswer.toString().trim().isNotEmpty) {
            correctAnswers++;
          }
        } else {
          if (question.correctAnswers.contains(userAnswer)) {
            correctAnswers++;
          }
        }
      }
    }
    return (correctAnswers / questions.length) * 100;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    assessmentTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
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
                    Color(0xFF87CEEB),
                    Color(0xFF4682B4),
                    Color(0xFF2E4057),
                    Color(0xFF1A1A2E),
                  ],
                ),
              ),
            ),

            // Back button
            SafeArea(
              child: Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Timer (when assessment is started) - positioned far right
            if (isAssessmentStarted && !isAssessmentCompleted)
              Positioned(
                top: 20, // Moved up to avoid overlap with progress indicator
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTimerWarning ? Colors.red.withOpacity(0.9) : Colors.blue.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(timeRemainingSeconds),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Main content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: isAssessmentStarted && !isAssessmentCompleted ? 80 : 20, // Extra top padding when timer is visible
                  bottom: 20,
                ),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildMainContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (showResults) {
      return _buildResultsScreen();
    } else if (isAssessmentStarted) {
      return _buildQuestionScreen();
    } else {
      return _buildIntroScreen();
    }
  }

  Widget _buildIntroScreen() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ClipRRect(
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
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Assessment icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.quiz,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Assessment title
                  Text(
                    widget.assessmentTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${widget.moduleTitle} • ${widget.courseTitle}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Assessment info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(Icons.quiz, 'Questions', '${questions.length}'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.timer, 'Time Limit', '30 minutes'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.check_circle, 'Passing Score', '80%'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.refresh, 'Attempts', 'Unlimited'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Instructions
                  Container(
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
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Read each question carefully before answering\n'
                          '• You can navigate between questions using the Previous/Next buttons\n'
                          '• For multiple answer questions, select all correct options\n'
                          '• Your progress is automatically saved\n'
                          '• Submit when you\'re ready or when time expires',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Start button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Start Assessment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionScreen() {
    final question = questions[currentQuestionIndex];
    
    return Column(
      children: [
        // Progress indicator
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${((currentQuestionIndex + 1) / questions.length * 100).round()}% Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 6,
              ),
            ],
          ),
        ),

        // Question content
        Expanded(
          child: ClipRRect(
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
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getQuestionTypeColor(question.type),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getQuestionTypeLabel(question.type),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Question text
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Answer options
                    Expanded(
                      child: _buildAnswerOptions(question),
                    ),

                    // Navigation buttons
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentQuestionIndex > 0)
                          ElevatedButton.icon(
                            onPressed: _previousQuestion,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        else
                          const SizedBox(),

                        ElevatedButton.icon(
                          onPressed: _nextQuestion,
                          icon: Icon(currentQuestionIndex == questions.length - 1 
                              ? Icons.check : Icons.arrow_forward),
                          label: Text(currentQuestionIndex == questions.length - 1 
                              ? 'Submit' : 'Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerOptions(Question question) {
    switch (question.type) {
      case 'multiple_choice':
      case 'true_false':
        return _buildSingleChoiceOptions(question);
      case 'multiple_answer':
        return _buildMultipleChoiceOptions(question);
      case 'short_answer':
        return _buildShortAnswerOption(question);
      default:
        return const SizedBox();
    }
  }

  Widget _buildSingleChoiceOptions(Question question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = userAnswers[question.id] == option;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _selectAnswer(question.id, option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? Colors.orange
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.orange : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultipleChoiceOptions(Question question) {
    List<String> selectedAnswers = List<String>.from(userAnswers[question.id] ?? []);
    
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = selectedAnswers.contains(option);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _selectAnswer(question.id, option),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.orange.withOpacity(0.3)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? Colors.orange
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected ? Colors.orange : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? Colors.orange : Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShortAnswerOption(Question question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: TextField(
        onChanged: (value) => _selectAnswer(question.id, value),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Type your answer here...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    final score = _calculateScore();
    final passed = score >= 80;
    
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ClipRRect(
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
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Result icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: passed 
                            ? [Colors.green, Colors.lightGreen]
                            : [Colors.red, Colors.redAccent],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (passed ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      passed ? Icons.check_circle : Icons.cancel,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Result title
                  Text(
                    passed ? 'Congratulations!' : 'Assessment Not Passed',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    passed 
                        ? 'You have successfully completed the assessment!'
                        : 'Don\'t worry, you can retake the assessment.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Score display
                  Container(
                    padding: const EdgeInsets.all(24),
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
                          'Your Score',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${score.round()}%',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: passed ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(score / 100 * questions.length).round()} out of ${questions.length} correct',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Back to Course'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Reset assessment
                            setState(() {
                              userAnswers.clear();
                              currentQuestionIndex = 0;
                              isAssessmentStarted = false;
                              isAssessmentCompleted = false;
                              showResults = false;
                              timeRemainingSeconds = 1800;
                              isTimerWarning = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retake Assessment'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getQuestionTypeColor(String type) {
    switch (type) {
      case 'multiple_choice':
        return Colors.blue;
      case 'true_false':
        return Colors.green;
      case 'multiple_answer':
        return Colors.purple;
      case 'short_answer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'true_false':
        return 'True/False';
      case 'multiple_answer':
        return 'Multiple Answer';
      case 'short_answer':
        return 'Short Answer';
      default:
        return 'Question';
    }
  }
} 