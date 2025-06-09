import 'diving_course.dart';

class POI {
  final String id;
  final String name;
  final String description;
  final double x; // Position on map (0.0 to 1.0)
  final double y; // Position on map (0.0 to 1.0)
  final String type; // 'island', 'reef', 'wreck', etc.
  final List<DivingCourse> courses;
  final String backgroundImage;
  bool isUnlocked;

  POI({
    required this.id,
    required this.name,
    required this.description,
    required this.x,
    required this.y,
    required this.type,
    required this.courses,
    required this.backgroundImage,
    this.isUnlocked = true,
  });

  bool get hasAvailableCourses => courses.isNotEmpty;
  
  bool get hasUnpurchasedCourses => 
      courses.any((course) => !course.isPurchased);
  
  bool get hasIncompleteCourses => 
      courses.where((course) => course.isPurchased).any((course) => !course.isCompleted);

  int get completedCoursesCount => 
      courses.where((course) => course.isCompleted).length;

  double get overallProgress {
    if (courses.isEmpty) return 0.0;
    double totalProgress = courses.fold(0.0, (sum, course) => sum + course.progress);
    return totalProgress / courses.length;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'x': x,
      'y': y,
      'type': type,
      'courses': courses.map((course) => course.toJson()).toList(),
      'backgroundImage': backgroundImage,
      'isUnlocked': isUnlocked,
    };
  }

  factory POI.fromJson(Map<String, dynamic> json) {
    return POI(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      type: json['type'],
      courses: (json['courses'] as List)
          .map((courseJson) => DivingCourse.fromJson(courseJson))
          .toList(),
      backgroundImage: json['backgroundImage'],
      isUnlocked: json['isUnlocked'] ?? true,
    );
  }
} 