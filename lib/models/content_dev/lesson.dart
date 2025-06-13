enum LessonType {
  video,
  text,
  quiz,
  interactive,
}

enum ContentBlockType {
  header,
  text,
  image,
  video,
  divider,
}

class ContentBlock {
  final String id;
  final ContentBlockType type;
  final String content;
  final Map<String, dynamic>? metadata;
  final int orderIndex;

  ContentBlock({
    required this.id,
    required this.type,
    required this.content,
    this.metadata,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'metadata': metadata,
      'orderIndex': orderIndex,
    };
  }

  factory ContentBlock.fromJson(Map<String, dynamic> json) {
    return ContentBlock(
      id: json['id'],
      type: ContentBlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContentBlockType.text,
      ),
      content: json['content'],
      metadata: json['metadata'],
      orderIndex: json['orderIndex'],
    );
  }

  ContentBlock copyWith({
    String? id,
    ContentBlockType? type,
    String? content,
    Map<String, dynamic>? metadata,
    int? orderIndex,
  }) {
    return ContentBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String content; // Keep for backward compatibility
  final List<ContentBlock> contentBlocks; // New rich content system
  final String moduleId;
  final int orderIndex;
  final int duration; // in minutes
  final LessonType lessonType;
  final String? videoUrl;
  final String? resourceUrl;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    List<ContentBlock>? contentBlocks,
    required this.moduleId,
    required this.orderIndex,
    required this.duration,
    required this.lessonType,
    this.videoUrl,
    this.resourceUrl,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : contentBlocks = contentBlocks ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentBlocks': contentBlocks.map((block) => block.toJson()).toList(),
      'moduleId': moduleId,
      'orderIndex': orderIndex,
      'duration': duration,
      'lessonType': lessonType.name,
      'videoUrl': videoUrl,
      'resourceUrl': resourceUrl,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      contentBlocks: json['contentBlocks'] != null
          ? (json['contentBlocks'] as List)
              .map((block) => ContentBlock.fromJson(block))
              .toList()
          : [],
      moduleId: json['moduleId'],
      orderIndex: json['orderIndex'],
      duration: json['duration'],
      lessonType: LessonType.values.firstWhere(
        (e) => e.name == json['lessonType'],
        orElse: () => LessonType.text,
      ),
      videoUrl: json['videoUrl'],
      resourceUrl: json['resourceUrl'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? content,
    List<ContentBlock>? contentBlocks,
    String? moduleId,
    int? orderIndex,
    int? duration,
    LessonType? lessonType,
    String? videoUrl,
    String? resourceUrl,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      moduleId: moduleId ?? this.moduleId,
      orderIndex: orderIndex ?? this.orderIndex,
      duration: duration ?? this.duration,
      lessonType: lessonType ?? this.lessonType,
      videoUrl: videoUrl ?? this.videoUrl,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
} 