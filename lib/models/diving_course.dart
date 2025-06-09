class DivingCourse {
  final String id;
  final String title;
  final String description;
  final double price;
  final String difficulty;
  final int duration; // in minutes
  final List<String> topics;
  final String iconPath;
  bool isPurchased;
  bool isCompleted;
  double progress; // 0.0 to 1.0

  DivingCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.difficulty,
    required this.duration,
    required this.topics,
    required this.iconPath,
    this.isPurchased = false,
    this.isCompleted = false,
    this.progress = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'difficulty': difficulty,
      'duration': duration,
      'topics': topics,
      'iconPath': iconPath,
      'isPurchased': isPurchased,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  factory DivingCourse.fromJson(Map<String, dynamic> json) {
    return DivingCourse(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      difficulty: json['difficulty'],
      duration: json['duration'],
      topics: List<String>.from(json['topics']),
      iconPath: json['iconPath'],
      isPurchased: json['isPurchased'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }

  DivingCourse copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? difficulty,
    int? duration,
    List<String>? topics,
    String? iconPath,
    bool? isPurchased,
    bool? isCompleted,
    double? progress,
  }) {
    return DivingCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      difficulty: difficulty ?? this.difficulty,
      duration: duration ?? this.duration,
      topics: topics ?? this.topics,
      iconPath: iconPath ?? this.iconPath,
      isPurchased: isPurchased ?? this.isPurchased,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
    );
  }
} 