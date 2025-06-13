import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/game_state_provider.dart';
import '../../models/diving_course.dart';
import '../../models/content_dev/module.dart';
import '../../models/content_dev/lesson.dart';
import '../../models/content_dev/assessment.dart';

class CourseModulesBuilder extends StatefulWidget {
  final DivingCourse course;
  final String selectedPOI;
  final bool isNewCourse;
  
  const CourseModulesBuilder({
    super.key,
    required this.course,
    required this.selectedPOI,
    required this.isNewCourse,
  });

  @override
  State<CourseModulesBuilder> createState() => _CourseModulesBuilderState();
}

class _CourseModulesBuilderState extends State<CourseModulesBuilder>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<CourseModule> _modules = [];
  List<Lesson> _lessons = [];
  List<Assessment> _assessments = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadExistingContent();
  }

  void _loadExistingContent() {
    // Load existing modules, lessons, and assessments for this course
    // This would typically come from a database or state management
    // For now, we'll start with empty lists for new courses
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveCourseWithContent() {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    
    if (widget.isNewCourse) {
      gameState.addCourseToSpecificPOI(widget.course, widget.selectedPOI);
    } else {
      gameState.updateCourse(widget.course, widget.selectedPOI);
    }
    
    // Save modules, lessons, and assessments
    // This would typically involve saving to a database
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course "${widget.course.title}" saved with all content!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back to dashboard
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Building: ${widget.course.title}'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Modules', icon: Icon(Icons.folder)),
            Tab(text: 'Lessons', icon: Icon(Icons.book)),
            Tab(text: 'Assessments', icon: Icon(Icons.quiz)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _saveCourseWithContent,
            child: const Text(
              'FINISH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildModulesTab(),
            _buildLessonsTab(),
            _buildAssessmentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesTab() {
    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Course Modules',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddModuleDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Module'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        
        // Modules list
        Expanded(
          child: _modules.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No modules yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add your first module to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _modules.length,
                  itemBuilder: (context, index) {
                    final module = _modules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E3A8A),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          module.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(module.description),
                            const SizedBox(height: 4),
                            Text(
                              '${module.estimatedDuration} minutes',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditModuleDialog(module, index);
                            } else if (value == 'delete') {
                              _deleteModule(index);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLessonsTab() {
    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Course Lessons',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _modules.isEmpty ? null : () => _showAddLessonDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Lesson'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        
        // Lessons list
        Expanded(
          child: _modules.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Create modules first',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'You need to create modules before adding lessons',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _lessons.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No lessons yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add lessons to your modules',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _lessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _lessons[index];
                        final module = _modules.firstWhere((m) => m.id == lesson.moduleId);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getLessonTypeColor(lesson.lessonType),
                              child: Icon(
                                _getLessonTypeIcon(lesson.lessonType),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              lesson.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Module: ${module.title}'),
                                const SizedBox(height: 4),
                                Text(
                                  '${lesson.duration} minutes • ${lesson.lessonType.name}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditLessonDialog(lesson, index);
                                } else if (value == 'delete') {
                                  _deleteLesson(index);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAssessmentsTab() {
    return Column(
      children: [
        // Header with add button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Course Assessments',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddAssessmentDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Assessment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
        
        // Assessments list
        Expanded(
          child: _assessments.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: Colors.white54,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No assessments yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add assessments to test student knowledge',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _assessments.length,
                  itemBuilder: (context, index) {
                    final assessment = _assessments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF059669),
                          child: Icon(
                            Icons.quiz,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          assessment.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(assessment.description),
                            const SizedBox(height: 4),
                            Text(
                              '${assessment.questionIds.length} questions • ${assessment.timeLimit} minutes • ${assessment.passingScore}% to pass',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditAssessmentDialog(assessment, index);
                            } else if (value == 'delete') {
                              _deleteAssessment(index);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Helper methods for lesson types
  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Colors.red;
      case LessonType.text:
        return Colors.blue;
      case LessonType.quiz:
        return Colors.green;
      case LessonType.interactive:
        return Colors.purple;
    }
  }

  IconData _getLessonTypeIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle;
      case LessonType.text:
        return Icons.article;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.interactive:
        return Icons.touch_app;
    }
  }

  // Dialog methods
  void _showAddModuleDialog() {
    _showModuleDialog();
  }

  void _showEditModuleDialog(CourseModule module, int index) {
    _showModuleDialog(module: module, index: index);
  }

  void _showModuleDialog({CourseModule? module, int? index}) {
    final titleController = TextEditingController(text: module?.title ?? '');
    final descriptionController = TextEditingController(text: module?.description ?? '');
    final durationController = TextEditingController(text: module?.estimatedDuration.toString() ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.folder,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module == null ? 'Create Module' : 'Edit Module',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module == null ? 'Add a new module to your course' : 'Update module information',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Title Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Module Title',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Icons.title, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Icons.description, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        maxLines: 3,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Duration Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: durationController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Duration (minutes)',
                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: Icon(Icons.timer, color: Color(0xFF64748B)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            final newModule = CourseModule(
                              id: module?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                              title: titleController.text,
                              description: descriptionController.text,
                              courseId: widget.course.id,
                              orderIndex: index ?? _modules.length,
                              estimatedDuration: int.tryParse(durationController.text) ?? 0,
                            );

                            setState(() {
                              if (index != null) {
                                _modules[index] = newModule;
                              } else {
                                _modules.add(newModule);
                              }
                            });

                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          module == null ? 'Create Module' : 'Update Module',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLessonDialog() {
    _showLessonDialog();
  }

  void _showEditLessonDialog(Lesson lesson, int index) {
    _showLessonDialog(lesson: lesson, index: index);
  }

  void _showLessonDialog({Lesson? lesson, int? index}) {
    final titleController = TextEditingController(text: lesson?.title ?? '');
    final durationController = TextEditingController(text: lesson?.duration.toString() ?? '');
    String selectedModuleId = lesson?.moduleId ?? _modules.first.id;
    LessonType selectedType = lesson?.lessonType ?? LessonType.text;
    List<ContentBlock> contentBlocks = List.from(lesson?.contentBlocks ?? []);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.98,
            height: MediaQuery.of(context).size.height * 0.92,
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_getLessonTypeColor(selectedType), _getLessonTypeColor(selectedType).withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getLessonTypeIcon(selectedType),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson == null ? 'Create Rich Lesson' : 'Edit Rich Lesson',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build engaging lessons with text, images, videos & more',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Row(
                    children: [
                      // Left Panel - Lesson Settings
                      Container(
                        width: 380,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            right: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lesson Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Title Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Lesson Title',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.title, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Module Selection
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: selectedModuleId,
                                  decoration: const InputDecoration(
                                    labelText: 'Module',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.folder, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  items: _modules.map((module) {
                                    return DropdownMenuItem(
                                      value: module.id,
                                      child: Text(
                                        module.title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedModuleId = value!;
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Lesson Type Selection
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonFormField<LessonType>(
                                  value: selectedType,
                                  decoration: const InputDecoration(
                                    labelText: 'Lesson Type',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.category, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  items: LessonType.values.map((type) {
                                    return DropdownMenuItem(
                                      value: type,
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getLessonTypeIcon(type),
                                            size: 20,
                                            color: _getLessonTypeColor(type),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            type.name.toUpperCase(),
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedType = value!;
                                    });
                                  },
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Duration Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: TextField(
                                  controller: durationController,
                                  decoration: const InputDecoration(
                                    labelText: 'Duration (minutes)',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.timer, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Content Blocks Section
                              const Text(
                                'Add Content Blocks',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Content Block Buttons
                              _buildContentBlockButton(
                                icon: Icons.title,
                                label: 'Header',
                                color: const Color(0xFF3B82F6),
                                onTap: () => _addContentBlock(ContentBlockType.header, contentBlocks, setState),
                              ),
                              const SizedBox(height: 8),
                              _buildContentBlockButton(
                                icon: Icons.text_fields,
                                label: 'Text',
                                color: const Color(0xFF64748B),
                                onTap: () => _addContentBlock(ContentBlockType.text, contentBlocks, setState),
                              ),
                              const SizedBox(height: 8),
                              _buildContentBlockButton(
                                icon: Icons.image,
                                label: 'Image',
                                color: const Color(0xFF10B981),
                                onTap: () => _addContentBlock(ContentBlockType.image, contentBlocks, setState),
                              ),
                              const SizedBox(height: 8),
                              _buildContentBlockButton(
                                icon: Icons.video_library,
                                label: 'Video',
                                color: const Color(0xFFEF4444),
                                onTap: () => _addContentBlock(ContentBlockType.video, contentBlocks, setState),
                              ),
                              const SizedBox(height: 8),
                              _buildContentBlockButton(
                                icon: Icons.horizontal_rule,
                                label: 'Divider',
                                color: const Color(0xFF8B5CF6),
                                onTap: () => _addContentBlock(ContentBlockType.divider, contentBlocks, setState),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Right Panel - Content Preview
                      Expanded(
                        child: Column(
                          children: [
                            // Preview Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.preview, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Lesson Content Preview',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${contentBlocks.length} blocks',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Content Blocks List
                            Expanded(
                              child: contentBlocks.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No content blocks yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add headers, text, images, or videos\nto build your lesson content',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ReorderableListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: contentBlocks.length,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final item = contentBlocks.removeAt(oldIndex);
                                          contentBlocks.insert(newIndex, item);
                                          // Update order indices
                                          for (int i = 0; i < contentBlocks.length; i++) {
                                            contentBlocks[i] = contentBlocks[i].copyWith(orderIndex: i);
                                          }
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final block = contentBlocks[index];
                                        return _buildContentBlockPreview(
                                          key: ValueKey(block.id),
                                          block: block,
                                          index: index,
                                          onEdit: () => _editContentBlock(block, index, contentBlocks, setState),
                                          onDelete: () {
                                            setState(() {
                                              contentBlocks.removeAt(index);
                                              // Update order indices
                                              for (int i = 0; i < contentBlocks.length; i++) {
                                                contentBlocks[i] = contentBlocks[i].copyWith(orderIndex: i);
                                              }
                                            });
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              final newLesson = Lesson(
                                id: lesson?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleController.text,
                                content: _generateLegacyContent(contentBlocks), // For backward compatibility
                                contentBlocks: contentBlocks,
                                moduleId: selectedModuleId,
                                orderIndex: index ?? _lessons.length,
                                duration: int.tryParse(durationController.text) ?? 0,
                                lessonType: selectedType,
                              );

                              this.setState(() {
                                if (index != null) {
                                  _lessons[index] = newLesson;
                                } else {
                                  _lessons.add(newLesson);
                                }
                              });

                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getLessonTypeColor(selectedType),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            lesson == null ? 'Create Lesson' : 'Update Lesson',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAssessmentDialog() {
    _showAssessmentDialog();
  }

  void _showEditAssessmentDialog(Assessment assessment, int index) {
    _showAssessmentDialog(assessment: assessment, index: index);
  }

  void _showAssessmentDialog({Assessment? assessment, int? index}) {
    final titleController = TextEditingController(text: assessment?.title ?? '');
    final descriptionController = TextEditingController(text: assessment?.description ?? '');
    final passingScoreController = TextEditingController(text: assessment?.passingScore.toString() ?? '70');
    final timeLimitController = TextEditingController(text: assessment?.timeLimit.toString() ?? '30');
    List<Question> questions = List.from(assessment?.questions ?? []);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.98,
            height: MediaQuery.of(context).size.height * 0.92,
            constraints: const BoxConstraints(maxWidth: 1200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assessment == null ? 'Create Assessment' : 'Edit Assessment',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build comprehensive assessments with multiple question types',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Row(
                    children: [
                      // Left Panel - Assessment Settings
                      Container(
                        width: 380,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border: Border(
                            right: BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assessment Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Title Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    labelText: 'Assessment Title',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.title, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Description Field
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: TextField(
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Description',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.description, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  maxLines: 3,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Settings Row
                              Row(
                                children: [
                                  // Passing Score
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: TextField(
                                        controller: passingScoreController,
                                        decoration: const InputDecoration(
                                          labelText: 'Passing Score (%)',
                                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                                          prefixIcon: Icon(Icons.grade, color: Color(0xFF64748B)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Time Limit
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: TextField(
                                        controller: timeLimitController,
                                        decoration: const InputDecoration(
                                          labelText: 'Time Limit (min)',
                                          labelStyle: TextStyle(color: Color(0xFF64748B)),
                                          prefixIcon: Icon(Icons.timer, color: Color(0xFF64748B)),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(16),
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Question Types Section
                              const Text(
                                'Add Questions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Question Type Buttons
                              _buildQuestionTypeButton(
                                icon: Icons.check_circle,
                                label: 'True/False',
                                description: 'Simple yes/no questions',
                                color: const Color(0xFF3B82F6),
                                onTap: () => _addQuestion(QuestionType.trueFalse, questions, setState),
                              ),
                              const SizedBox(height: 12),
                              _buildQuestionTypeButton(
                                icon: Icons.radio_button_checked,
                                label: 'Multiple Choice',
                                description: 'Single correct answer',
                                color: const Color(0xFF8B5CF6),
                                onTap: () => _addQuestion(QuestionType.multipleChoice, questions, setState),
                              ),
                              const SizedBox(height: 12),
                              _buildQuestionTypeButton(
                                icon: Icons.checklist,
                                label: 'Multiple Answer',
                                description: 'Multiple correct answers',
                                color: const Color(0xFFEF4444),
                                onTap: () => _addQuestion(QuestionType.multipleAnswer, questions, setState),
                              ),
                              const SizedBox(height: 12),
                              _buildQuestionTypeButton(
                                icon: Icons.text_fields,
                                label: 'Short Answer',
                                description: 'Text-based responses',
                                color: const Color(0xFF10B981),
                                onTap: () => _addQuestion(QuestionType.shortAnswer, questions, setState),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Right Panel - Questions Preview
                      Expanded(
                        child: Column(
                          children: [
                            // Questions Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.quiz, color: Color(0xFF64748B)),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Assessment Questions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF059669),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${questions.length} questions',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Questions List
                            Expanded(
                              child: questions.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.quiz_outlined,
                                            size: 64,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No questions yet',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add questions using the buttons on the left\nto build your assessment',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ReorderableListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: questions.length,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) {
                                            newIndex -= 1;
                                          }
                                          final item = questions.removeAt(oldIndex);
                                          questions.insert(newIndex, item);
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        final question = questions[index];
                                        return _buildQuestionPreview(
                                          key: ValueKey(question.id),
                                          question: question,
                                          index: index,
                                          onEdit: () => _editQuestion(question, index, questions, setState),
                                          onDelete: () {
                                            setState(() {
                                              questions.removeAt(index);
                                            });
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isNotEmpty) {
                              final newAssessment = Assessment(
                                id: assessment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                title: titleController.text,
                                description: descriptionController.text,
                                courseId: widget.course.id,
                                passingScore: int.tryParse(passingScoreController.text) ?? 70,
                                timeLimit: int.tryParse(timeLimitController.text) ?? 30,
                                questionIds: questions.map((q) => q.id).toList(),
                                questions: questions,
                              );

                              setState(() {
                                if (index != null) {
                                  _assessments[index] = newAssessment;
                                } else {
                                  _assessments.add(newAssessment);
                                }
                              });

                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            assessment == null ? 'Create Assessment' : 'Update Assessment',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Delete methods
  void _deleteModule(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Module'),
        content: const Text('Are you sure you want to delete this module? This will also delete all associated lessons.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final moduleId = _modules[index].id;
              setState(() {
                _modules.removeAt(index);
                _lessons.removeWhere((lesson) => lesson.moduleId == moduleId);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteLesson(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _lessons.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteAssessment(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: const Text('Are you sure you want to delete this assessment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _assessments.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Helper method to build content block buttons
  Widget _buildContentBlockButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.add,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to add content blocks
  void _addContentBlock(ContentBlockType type, List<ContentBlock> contentBlocks, StateSetter setState) {
    String defaultContent = '';
    Map<String, dynamic>? metadata;

    switch (type) {
      case ContentBlockType.header:
        defaultContent = 'New Header';
        metadata = {'level': 1}; // H1 by default
        break;
      case ContentBlockType.text:
        defaultContent = 'Enter your text content here...';
        break;
      case ContentBlockType.image:
        defaultContent = 'https://via.placeholder.com/400x200';
        metadata = {'alt': 'Image description', 'caption': ''};
        break;
      case ContentBlockType.video:
        defaultContent = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
        metadata = {'title': 'Video Title', 'autoplay': false};
        break;
      case ContentBlockType.divider:
        defaultContent = '';
        metadata = {'style': 'solid'};
        break;
    }

    _showContentBlockEditor(
      type: type,
      content: defaultContent,
      metadata: metadata,
      onSave: (content, updatedMetadata) {
        setState(() {
          contentBlocks.add(ContentBlock(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: type,
            content: content,
            metadata: updatedMetadata,
            orderIndex: contentBlocks.length,
          ));
        });
      },
    );
  }

  // Helper method to edit content blocks
  void _editContentBlock(ContentBlock block, int index, List<ContentBlock> contentBlocks, StateSetter setState) {
    _showContentBlockEditor(
      type: block.type,
      content: block.content,
      metadata: block.metadata,
      onSave: (content, metadata) {
        setState(() {
          contentBlocks[index] = block.copyWith(
            content: content,
            metadata: metadata,
          );
        });
      },
    );
  }

  // Content block editor dialog
  void _showContentBlockEditor({
    required ContentBlockType type,
    required String content,
    Map<String, dynamic>? metadata,
    required Function(String content, Map<String, dynamic>? metadata) onSave,
  }) {
    final contentController = TextEditingController(text: content);
    Map<String, dynamic> editableMetadata = Map.from(metadata ?? {});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_getContentBlockColor(type), _getContentBlockColor(type).withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getContentBlockIcon(type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit ${type.name.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getContentBlockDescription(type),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Header Level Selection (for headers only)
                        if (type == ContentBlockType.header) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonFormField<int>(
                              value: editableMetadata['level'] ?? 1,
                              decoration: const InputDecoration(
                                labelText: 'Header Level',
                                border: OutlineInputBorder(),
                              ),
                              items: [1, 2, 3, 4, 5, 6].map((level) {
                                return DropdownMenuItem(
                                  value: level,
                                  child: Row(
                                    children: [
                                      Text(
                                        'H$level',
                                        style: TextStyle(
                                          fontSize: (20 - level).toDouble(),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '- ${_getHeaderLevelDescription(level)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  editableMetadata['level'] = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // Main Content Field
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: contentController,
                            decoration: InputDecoration(
                              labelText: _getContentFieldLabel(type),
                              labelStyle: const TextStyle(color: Color(0xFF64748B)),
                              prefixIcon: Icon(_getContentBlockIcon(type), color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              hintText: _getContentFieldHint(type),
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            maxLines: type == ContentBlockType.text ? 6 : 1,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        
                        // Image-specific fields
                        if (type == ContentBlockType.image) ...[
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Alt Text',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.accessibility, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                                hintText: 'Describe the image for accessibility',
                              ),
                              onChanged: (value) {
                                editableMetadata['alt'] = value;
                              },
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Caption (Optional)',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.text_fields, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                                hintText: 'Add a caption below the image',
                              ),
                              onChanged: (value) {
                                editableMetadata['caption'] = value;
                              },
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                        
                        // Video-specific fields
                        if (type == ContentBlockType.video) ...[
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Video Title',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.title, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                                hintText: 'Enter a descriptive title for the video',
                              ),
                              onChanged: (value) {
                                editableMetadata['title'] = value;
                              },
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: CheckboxListTile(
                              title: const Text(
                                'Autoplay Video',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              subtitle: const Text(
                                'Start playing automatically when lesson loads',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              value: editableMetadata['autoplay'] ?? false,
                              onChanged: (value) {
                                setState(() {
                                  editableMetadata['autoplay'] = value ?? false;
                                });
                              },
                              activeColor: _getContentBlockColor(type),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                        
                        // Divider-specific fields
                        if (type == ContentBlockType.divider) ...[
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: editableMetadata['style'] ?? 'solid',
                              decoration: const InputDecoration(
                                labelText: 'Divider Style',
                                labelStyle: TextStyle(color: Color(0xFF64748B)),
                                prefixIcon: Icon(Icons.horizontal_rule, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              items: [
                                const DropdownMenuItem(value: 'solid', child: Text('Solid Line')),
                                const DropdownMenuItem(value: 'dashed', child: Text('Dashed Line')),
                                const DropdownMenuItem(value: 'dotted', child: Text('Dotted Line')),
                                const DropdownMenuItem(value: 'thick', child: Text('Thick Line')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  editableMetadata['style'] = value!;
                                });
                              },
                            ),
                          ),
                        ],
                        
                        // Help/Tips Section
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getContentBlockColor(type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _getContentBlockColor(type).withOpacity(0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: _getContentBlockColor(type),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tips',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _getContentBlockColor(type),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getContentBlockTips(type),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _getContentBlockColor(type).withOpacity(0.8),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (contentController.text.isNotEmpty || type == ContentBlockType.divider) {
                              onSave(contentController.text, editableMetadata);
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getContentBlockColor(type),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Content',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build content block preview
  Widget _buildContentBlockPreview({
    required Key key,
    required ContentBlock block,
    required int index,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getContentBlockColor(block.type).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getContentBlockIcon(block.type),
                  color: _getContentBlockColor(block.type),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  block.type.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getContentBlockColor(block.type),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),
          // Block Content Preview
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildContentPreview(block),
          ),
        ],
      ),
    );
  }

  // Helper method to build content preview based on type
  Widget _buildContentPreview(ContentBlock block) {
    switch (block.type) {
      case ContentBlockType.header:
        final level = block.metadata?['level'] ?? 1;
        return Text(
          block.content,
          style: TextStyle(
            fontSize: (24 - (level * 2)).toDouble(),
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        );
      case ContentBlockType.text:
        return Text(
          block.content,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        );
      case ContentBlockType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.image,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            if (block.metadata?['caption']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(
                block.metadata!['caption'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        );
      case ContentBlockType.video:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.play_circle_outline,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              block.metadata?['title'] ?? 'Video',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        );
      case ContentBlockType.divider:
        return Container(
          height: 2,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(1),
          ),
        );
    }
  }

  // Helper methods for content block styling
  IconData _getContentBlockIcon(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.header:
        return Icons.title;
      case ContentBlockType.text:
        return Icons.text_fields;
      case ContentBlockType.image:
        return Icons.image;
      case ContentBlockType.video:
        return Icons.video_library;
      case ContentBlockType.divider:
        return Icons.horizontal_rule;
    }
  }

  Color _getContentBlockColor(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.header:
        return const Color(0xFF3B82F6);
      case ContentBlockType.text:
        return const Color(0xFF64748B);
      case ContentBlockType.image:
        return const Color(0xFF10B981);
      case ContentBlockType.video:
        return const Color(0xFFEF4444);
      case ContentBlockType.divider:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getContentFieldLabel(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.header:
        return 'Header Text';
      case ContentBlockType.text:
        return 'Text Content';
      case ContentBlockType.image:
        return 'Image URL';
      case ContentBlockType.video:
        return 'Video URL';
      case ContentBlockType.divider:
        return 'Divider Style';
    }
  }

  String _getContentFieldHint(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.header:
        return 'Enter the header text';
      case ContentBlockType.text:
        return 'Enter the text content';
      case ContentBlockType.image:
        return 'Enter the image URL';
      case ContentBlockType.video:
        return 'Enter the video URL';
      case ContentBlockType.divider:
        return 'Select the divider style';
    }
  }

  String _getContentBlockDescription(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.header:
        return 'This is the text that will appear as a header';
      case ContentBlockType.text:
        return 'This is the text content of the block';
      case ContentBlockType.image:
        return 'This is the URL of the image';
      case ContentBlockType.video:
        return 'This is the URL of the video';
      case ContentBlockType.divider:
        return 'This is the style of the divider';
    }
  }

  String _getHeaderLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Main heading';
      case 2:
        return 'Subheading';
      case 3:
        return 'Sub-subheading';
      case 4:
        return 'Section heading';
      case 5:
        return 'Subsection heading';
      case 6:
        return 'Sub-subsection heading';
      default:
        return 'Heading';
    }
  }

  String _getContentBlockTips(ContentBlockType type) {
    switch (type) {
      case ContentBlockType.header:
        return 'Use headers to organize your content hierarchically. H1 for main topics, H2 for sections, H3 for subsections.';
      case ContentBlockType.text:
        return 'Write clear, engaging text. Break up long paragraphs and use simple language for better readability.';
      case ContentBlockType.image:
        return 'Use high-quality images that support your content. Always include alt text for accessibility.';
      case ContentBlockType.video:
        return 'Embed videos from YouTube, Vimeo, or other platforms. Keep videos focused and relevant to the lesson.';
      case ContentBlockType.divider:
        return 'Use dividers to visually separate different sections of your content and improve readability.';
    }
  }

  // Helper method to generate legacy content for backward compatibility
  String _generateLegacyContent(List<ContentBlock> contentBlocks) {
    if (contentBlocks.isEmpty) return '';
    
    return contentBlocks.map((block) {
      switch (block.type) {
        case ContentBlockType.header:
          final level = block.metadata?['level'] ?? 1;
          return '${'#' * level} ${block.content}';
        case ContentBlockType.text:
          return block.content;
        case ContentBlockType.image:
          return '[Image: ${block.content}]';
        case ContentBlockType.video:
          return '[Video: ${block.content}]';
        case ContentBlockType.divider:
          return '---';
      }
         }).join('\n\n');
   }

  // Helper method to build question type buttons
  Widget _buildQuestionTypeButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to add questions
  void _addQuestion(QuestionType type, List<Question> questions, StateSetter setState) {
    String questionText = '';
    List<String> options = [];
    List<int> correctAnswers = [];
    int points = 1;

    switch (type) {
      case QuestionType.trueFalse:
        questionText = 'True or False question?';
        options = ['True', 'False'];
        correctAnswers = [0]; // Default to True
        break;
      case QuestionType.multipleChoice:
        questionText = 'Multiple choice question?';
        options = ['Option A', 'Option B', 'Option C', 'Option D'];
        correctAnswers = [0]; // Default to first option
        break;
      case QuestionType.multipleAnswer:
        questionText = 'Multiple answer question?';
        options = ['Option A', 'Option B', 'Option C', 'Option D'];
        correctAnswers = [0, 1]; // Default to first two options
        break;
      case QuestionType.shortAnswer:
        questionText = 'Short answer question?';
        options = [];
        correctAnswers = [];
        break;
    }

    _showQuestionEditor(
      type: type,
      questionText: questionText,
      options: options,
      correctAnswers: correctAnswers,
      points: points,
      onSave: (text, opts, correct, pts, explanation) {
        setState(() {
          questions.add(Question(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            questionText: text,
            questionType: type,
            options: opts,
            correctAnswers: correct,
            points: pts,
            explanation: explanation,
          ));
        });
      },
    );
  }

  // Helper method to edit questions
  void _editQuestion(Question question, int index, List<Question> questions, StateSetter setState) {
    _showQuestionEditor(
      type: question.questionType,
      questionText: question.questionText,
      options: question.options,
      correctAnswers: question.correctAnswers,
      points: question.points,
      explanation: question.explanation,
      onSave: (text, options, correctAnswers, points, explanation) {
        setState(() {
          questions[index] = question.copyWith(
            questionText: text,
            options: options,
            correctAnswers: correctAnswers,
            points: points,
            explanation: explanation,
          );
        });
      },
    );
  }

  // Question editor dialog
  void _showQuestionEditor({
    required QuestionType type,
    required String questionText,
    required List<String> options,
    required List<int> correctAnswers,
    required int points,
    String? explanation,
    required Function(String text, List<String> options, List<int> correctAnswers, int points, String? explanation) onSave,
  }) {
    final questionController = TextEditingController(text: questionText);
    final pointsController = TextEditingController(text: points.toString());
    final explanationController = TextEditingController(text: explanation ?? '');
    List<TextEditingController> optionControllers = options.map((opt) => TextEditingController(text: opt)).toList();
    List<int> selectedAnswers = List.from(correctAnswers);

    // Ensure minimum options for multiple choice/answer
    if (type == QuestionType.multipleChoice || type == QuestionType.multipleAnswer) {
      while (optionControllers.length < 2) {
        optionControllers.add(TextEditingController(text: 'Option ${optionControllers.length + 1}'));
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 700),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_getQuestionTypeColor(type), _getQuestionTypeColor(type).withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getQuestionTypeIcon(type),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit ${_getQuestionTypeName(type)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getQuestionTypeDescription(type),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Question Text
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: questionController,
                            decoration: const InputDecoration(
                              labelText: 'Question Text',
                              labelStyle: TextStyle(color: Color(0xFF64748B)),
                              prefixIcon: Icon(Icons.help_outline, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Options (for multiple choice/answer and true/false)
                        if (type != QuestionType.shortAnswer) ...[
                          Row(
                            children: [
                              Text(
                                type == QuestionType.trueFalse ? 'Answer Options' : 'Answer Options',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const Spacer(),
                              if (type == QuestionType.multipleChoice || type == QuestionType.multipleAnswer)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      optionControllers.add(TextEditingController(text: 'Option ${optionControllers.length + 1}'));
                                    });
                                  },
                                  icon: const Icon(Icons.add, size: 16),
                                  label: const Text('Add Option'),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...optionControllers.asMap().entries.map((entry) {
                            int index = entry.key;
                            TextEditingController controller = entry.value;
                            bool isCorrect = selectedAnswers.contains(index);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isCorrect ? _getQuestionTypeColor(type).withOpacity(0.1) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCorrect ? _getQuestionTypeColor(type) : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Correct answer selector
                                  if (type == QuestionType.multipleChoice)
                                    Radio<int>(
                                      value: index,
                                      groupValue: selectedAnswers.isNotEmpty ? selectedAnswers.first : -1,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAnswers = [value!];
                                        });
                                      },
                                      activeColor: _getQuestionTypeColor(type),
                                    )
                                  else if (type == QuestionType.multipleAnswer)
                                    Checkbox(
                                      value: isCorrect,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            selectedAnswers.add(index);
                                          } else {
                                            selectedAnswers.remove(index);
                                          }
                                        });
                                      },
                                      activeColor: _getQuestionTypeColor(type),
                                    )
                                  else if (type == QuestionType.trueFalse)
                                    Radio<int>(
                                      value: index,
                                      groupValue: selectedAnswers.isNotEmpty ? selectedAnswers.first : -1,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedAnswers = [value!];
                                        });
                                      },
                                      activeColor: _getQuestionTypeColor(type),
                                    ),
                                  
                                  // Option text
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      decoration: InputDecoration(
                                        hintText: type == QuestionType.trueFalse 
                                            ? (index == 0 ? 'True' : 'False')
                                            : 'Enter option text',
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      enabled: type != QuestionType.trueFalse,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  
                                  // Delete option (for multiple choice/answer with more than 2 options)
                                  if ((type == QuestionType.multipleChoice || type == QuestionType.multipleAnswer) && 
                                      optionControllers.length > 2)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          optionControllers.removeAt(index);
                                          selectedAnswers.removeWhere((answer) => answer == index);
                                          // Adjust remaining answer indices
                                          selectedAnswers = selectedAnswers.map((answer) => answer > index ? answer - 1 : answer).toList();
                                        });
                                      },
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Points and Explanation
                        Row(
                          children: [
                            // Points
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: TextField(
                                  controller: pointsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Points',
                                    labelStyle: TextStyle(color: Color(0xFF64748B)),
                                    prefixIcon: Icon(Icons.star, color: Color(0xFF64748B)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Explanation
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: TextField(
                            controller: explanationController,
                            decoration: const InputDecoration(
                              labelText: 'Explanation (Optional)',
                              labelStyle: TextStyle(color: Color(0xFF64748B)),
                              prefixIcon: Icon(Icons.lightbulb_outline, color: Color(0xFF64748B)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                              hintText: 'Explain why this is the correct answer',
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (questionController.text.isNotEmpty && (selectedAnswers.isNotEmpty || type == QuestionType.shortAnswer)) {
                              onSave(
                                questionController.text,
                                optionControllers.map((c) => c.text).toList(),
                                selectedAnswers,
                                int.tryParse(pointsController.text) ?? 1,
                                explanationController.text.isNotEmpty ? explanationController.text : null,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getQuestionTypeColor(type),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save Question',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build question preview
  Widget _buildQuestionPreview({
    required Key key,
    required Question question,
    required int index,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getQuestionTypeColor(question.questionType).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getQuestionTypeIcon(question.questionType),
                  color: _getQuestionTypeColor(question.questionType),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getQuestionTypeName(question.questionType),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getQuestionTypeColor(question.questionType),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getQuestionTypeColor(question.questionType),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${question.points} pts',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: onEdit,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.drag_handle, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),
          
          // Question Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (question.options.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...question.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    bool isCorrect = question.correctAnswers.contains(index);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCorrect 
                            ? _getQuestionTypeColor(question.questionType).withOpacity(0.1)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCorrect 
                              ? _getQuestionTypeColor(question.questionType)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 16,
                            color: isCorrect 
                                ? _getQuestionTypeColor(question.questionType)
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 14,
                                color: isCorrect 
                                    ? _getQuestionTypeColor(question.questionType)
                                    : const Color(0xFF64748B),
                                fontWeight: isCorrect ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for question type styling
  IconData _getQuestionTypeIcon(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return Icons.check_circle;
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.multipleAnswer:
        return Icons.checklist;
      case QuestionType.shortAnswer:
        return Icons.text_fields;
    }
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return const Color(0xFF3B82F6);
      case QuestionType.multipleChoice:
        return const Color(0xFF8B5CF6);
      case QuestionType.multipleAnswer:
        return const Color(0xFFEF4444);
      case QuestionType.shortAnswer:
        return const Color(0xFF10B981);
    }
  }

  String _getQuestionTypeName(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return 'TRUE/FALSE';
      case QuestionType.multipleChoice:
        return 'MULTIPLE CHOICE';
      case QuestionType.multipleAnswer:
        return 'MULTIPLE ANSWER';
      case QuestionType.shortAnswer:
        return 'SHORT ANSWER';
    }
  }

  String _getQuestionTypeDescription(QuestionType type) {
    switch (type) {
      case QuestionType.trueFalse:
        return 'Students choose between true or false';
      case QuestionType.multipleChoice:
        return 'Students select one correct answer';
      case QuestionType.multipleAnswer:
        return 'Students can select multiple correct answers';
      case QuestionType.shortAnswer:
        return 'Students provide a written response';
    }
  }
 } 