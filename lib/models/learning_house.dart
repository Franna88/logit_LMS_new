class LearningHouse {
  final String id;
  final String name;
  final String description;
  final double x; // Position on map (0.0 to 1.0)
  final double y; // Position on map (0.0 to 1.0)
  final String logoPath;
  final String fullName;
  final String specialty;
  bool isUnlocked;

  LearningHouse({
    required this.id,
    required this.name,
    required this.description,
    required this.x,
    required this.y,
    required this.logoPath,
    required this.fullName,
    required this.specialty,
    this.isUnlocked = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'x': x,
      'y': y,
      'logoPath': logoPath,
      'fullName': fullName,
      'specialty': specialty,
      'isUnlocked': isUnlocked,
    };
  }

  factory LearningHouse.fromJson(Map<String, dynamic> json) {
    return LearningHouse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      logoPath: json['logoPath'],
      fullName: json['fullName'],
      specialty: json['specialty'],
      isUnlocked: json['isUnlocked'] ?? true,
    );
  }
} 