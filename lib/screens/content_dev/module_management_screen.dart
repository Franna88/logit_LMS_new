import 'package:flutter/material.dart';
import '../../models/content_dev/module.dart';
import '../../models/content_dev/lesson.dart';

class ModuleManagementScreen extends StatefulWidget {
  const ModuleManagementScreen({super.key});

  @override
  State<ModuleManagementScreen> createState() => _ModuleManagementScreenState();
}

class _ModuleManagementScreenState extends State<ModuleManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<CourseModule> _modules = [];
  List<Lesson> _lessons = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSampleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    _modules = [
      CourseModule(
        id: '1',
        title: 'Equipment Basics',
        description: 'Introduction to diving equipment',
        courseId: '1',
        orderIndex: 0,
        estimatedDuration: 45,
      ),
      CourseModule(
        id: '2',
        title: 'Safety Procedures',
        description: 'Essential safety protocols',
        courseId: '1',
        orderIndex: 1,
        estimatedDuration: 60,
      ),
    ];

    _lessons = [
      Lesson(
        id: '1',
        title: 'Mask and Snorkel',
        content: 'Learn about mask selection and proper fitting...',
        moduleId: '1',
        orderIndex: 0,
        duration: 15,
        lessonType: LessonType.video,
      ),
      Lesson(
        id: '2',
        title: 'Regulator System',
        content: 'Understanding your breathing apparatus...',
        moduleId: '1',
        orderIndex: 1,
        duration: 20,
        lessonType: LessonType.text,
      ),
    ];
  }

  void _showModuleDialog([CourseModule? module]) {
    final titleController = TextEditingController(text: module?.title ?? '');
    final descriptionController = TextEditingController(text: module?.description ?? '');
    final durationController = TextEditingController(text: module?.estimatedDuration.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(module == null ? 'Create Module' : 'Edit Module'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Module Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newModule = CourseModule(
                id: module?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                description: descriptionController.text,
                courseId: module?.courseId ?? '1',
                orderIndex: module?.orderIndex ?? _modules.length,
                estimatedDuration: int.tryParse(durationController.text) ?? 30,
              );

              setState(() {
                if (module == null) {
                  _modules.add(newModule);
                } else {
                  final index = _modules.indexWhere((m) => m.id == module.id);
                  if (index != -1) {
                    _modules[index] = newModule;
                  }
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Module ${module == null ? 'created' : 'updated'} successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(module == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showLessonDialog([Lesson? lesson]) {
    final titleController = TextEditingController(text: lesson?.title ?? '');
    final contentController = TextEditingController(text: lesson?.content ?? '');
    final durationController = TextEditingController(text: lesson?.duration.toString() ?? '');
    LessonType selectedType = lesson?.lessonType ?? LessonType.text;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lesson == null ? 'Create Lesson' : 'Edit Lesson'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Lesson Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Lesson Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<LessonType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Lesson Type',
                  border: OutlineInputBorder(),
                ),
                items: LessonType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedType = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newLesson = Lesson(
                id: lesson?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                content: contentController.text,
                moduleId: lesson?.moduleId ?? (_modules.isNotEmpty ? _modules.first.id : '1'),
                orderIndex: lesson?.orderIndex ?? _lessons.length,
                duration: int.tryParse(durationController.text) ?? 15,
                lessonType: selectedType,
              );

              setState(() {
                if (lesson == null) {
                  _lessons.add(newLesson);
                } else {
                  final index = _lessons.indexWhere((l) => l.id == lesson.id);
                  if (index != -1) {
                    _lessons[index] = newLesson;
                  }
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lesson ${lesson == null ? 'created' : 'updated'} successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(lesson == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Module & Lesson Management'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Modules', icon: Icon(Icons.library_books)),
            Tab(text: 'Lessons', icon: Icon(Icons.class_)),
          ],
        ),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showModuleDialog();
          } else {
            _showLessonDialog();
          }
        },
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildModulesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                  _showModuleDialog(module);
                } else if (value == 'delete') {
                  setState(() {
                    _modules.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Module deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        final lessonTypeIcon = _getLessonTypeIcon(lesson.lessonType);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getLessonTypeColor(lesson.lessonType),
              child: Icon(
                lessonTypeIcon,
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
                Text(
                  lesson.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${lesson.duration} min',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLessonTypeColor(lesson.lessonType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        lesson.lessonType.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getLessonTypeColor(lesson.lessonType),
                        ),
                      ),
                    ),
                  ],
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
                  _showLessonDialog(lesson);
                } else if (value == 'delete') {
                  setState(() {
                    _lessons.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lesson deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
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

  Color _getLessonTypeColor(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Colors.red;
      case LessonType.text:
        return Colors.blue;
      case LessonType.quiz:
        return Colors.orange;
      case LessonType.interactive:
        return Colors.purple;
    }
  }
} 