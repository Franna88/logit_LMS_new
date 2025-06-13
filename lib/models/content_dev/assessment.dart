enum QuestionType {
  trueFalse,
  multipleChoice,
  multipleAnswer,
  shortAnswer,
}

class Assessment {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final int passingScore; // percentage
  final int timeLimit; // in minutes
  final List<String> questionIds;
  final List<Question> questions; // Direct questions list for easier management
  final DateTime createdAt;
  final DateTime updatedAt;

  Assessment({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.passingScore,
    required this.timeLimit,
    required this.questionIds,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : questions = questions ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'courseId': courseId,
      'passingScore': passingScore,
      'timeLimit': timeLimit,
      'questionIds': questionIds,
      'questions': questions.map((q) => q.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['courseId'],
      passingScore: json['passingScore'],
      timeLimit: json['timeLimit'],
      questionIds: List<String>.from(json['questionIds']),
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => Question.fromJson(q))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Assessment copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    int? passingScore,
    int? timeLimit,
    List<String>? questionIds,
    List<Question>? questions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Assessment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      passingScore: passingScore ?? this.passingScore,
      timeLimit: timeLimit ?? this.timeLimit,
      questionIds: questionIds ?? this.questionIds,
      questions: questions ?? this.questions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class Question {
  final String id;
  final String questionText;
  final QuestionType questionType;
  final List<String> options;
  final List<int> correctAnswers; // indices for multiple choice/answer, 0/1 for true/false
  final int points;
  final String? explanation;
  final bool isRequired;

  Question({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswers,
    required this.points,
    this.explanation,
    this.isRequired = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'questionType': questionType.name,
      'options': options,
      'correctAnswers': correctAnswers,
      'points': points,
      'explanation': explanation,
      'isRequired': isRequired,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'],
      questionType: QuestionType.values.firstWhere(
        (e) => e.name == json['questionType'],
        orElse: () => QuestionType.multipleChoice,
      ),
      options: List<String>.from(json['options']),
      correctAnswers: List<int>.from(json['correctAnswers']),
      points: json['points'],
      explanation: json['explanation'],
      isRequired: json['isRequired'] ?? true,
    );
  }

  Question copyWith({
    String? id,
    String? questionText,
    QuestionType? questionType,
    List<String>? options,
    List<int>? correctAnswers,
    int? points,
    String? explanation,
    bool? isRequired,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      questionType: questionType ?? this.questionType,
      options: options ?? this.options,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      points: points ?? this.points,
      explanation: explanation ?? this.explanation,
      isRequired: isRequired ?? this.isRequired,
    );
  }
} 