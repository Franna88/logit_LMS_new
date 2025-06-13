class CourseModule {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final int orderIndex;
  final int estimatedDuration; // in minutes
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.orderIndex,
    required this.estimatedDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'orderIndex': orderIndex,
      'estimatedDuration': estimatedDuration,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['courseId'],
      orderIndex: json['orderIndex'],
      estimatedDuration: json['estimatedDuration'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  CourseModule copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    int? orderIndex,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      orderIndex: orderIndex ?? this.orderIndex,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
} 