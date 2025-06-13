import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/game_state_provider.dart';
import '../../models/poi.dart';
import '../../models/diving_course.dart';

class POIAssignmentScreen extends StatefulWidget {
  const POIAssignmentScreen({super.key});

  @override
  State<POIAssignmentScreen> createState() => _POIAssignmentScreenState();
}

class _POIAssignmentScreenState extends State<POIAssignmentScreen> {
  String? _selectedPOI;
  List<String> _selectedCourses = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POI Course Assignment'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
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
        child: Consumer<GameStateProvider>(
          builder: (context, gameState, child) {
            final pois = gameState.pois;
            final courses = gameState.getAllCourses();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // POI Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Point of Interest',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedPOI,
                            decoration: const InputDecoration(
                              labelText: 'POI Location',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            items: pois.map((poi) {
                              return DropdownMenuItem(
                                value: poi.id,
                                child: Row(
                                  children: [
                                                                         Icon(
                                       _getPOIIcon(poi.type),
                                       size: 20,
                                       color: const Color(0xFF1E3A8A),
                                     ),
                                    const SizedBox(width: 8),
                                                                         Expanded(child: Text(poi.name)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPOI = value;
                                _selectedCourses.clear();
                                                                 if (value != null) {
                                   final poi = pois.firstWhere((p) => p.id == value);
                                   _selectedCourses = poi.courses.map((c) => c.id).toList();
                                 }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Course Selection
                  if (_selectedPOI != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assign Courses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Select courses to assign to this POI:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 12),
                            ...courses.map((course) {
                              final isSelected = _selectedCourses.contains(course.id);
                              return CheckboxListTile(
                                title: Text(course.title),
                                subtitle: Text(
                                  '${course.difficulty} • R${course.price.toStringAsFixed(2)}',
                                ),
                                secondary: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getDifficultyColor(course.difficulty),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedCourses.add(course.id);
                                    } else {
                                      _selectedCourses.remove(course.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedCourses.isNotEmpty ? _saveAssignment : null,
                                                 style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFF06B6D4),
                           foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Assignment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Current Assignments
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Assignments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: pois.length,
                                itemBuilder: (context, index) {
                                  final poi = pois[index];
                                                                   final poiCourses = poi.courses;

                                 return ExpansionTile(
                                   leading: Icon(
                                     _getPOIIcon(poi.type),
                                     color: const Color(0xFF1E3A8A),
                                   ),
                                   title: Text(
                                     poi.name,
                                     style: const TextStyle(fontWeight: FontWeight.bold),
                                   ),
                                    subtitle: Text('${poiCourses.length} courses assigned'),
                                    children: poiCourses.map((course) {
                                      return ListTile(
                                        title: Text(course.title),
                                        subtitle: Text(
                                          '${course.difficulty} • R${course.price.toStringAsFixed(2)}',
                                        ),
                                        leading: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _getDifficultyColor(course.difficulty),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () => _removeCourseFromPOI(poi.id, course.id),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveAssignment() {
    if (_selectedPOI != null) {
      Provider.of<GameStateProvider>(context, listen: false)
          .updatePOICourses(_selectedPOI!, _selectedCourses);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course assignment saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectedPOI = null;
        _selectedCourses.clear();
      });
    }
  }

  void _removeCourseFromPOI(String poiId, String courseId) {
    final gameState = Provider.of<GameStateProvider>(context, listen: false);
    final poi = gameState.pois.firstWhere((p) => p.id == poiId);
    final updatedCourses = poi.courses.map((c) => c.id).toList();
    updatedCourses.remove(courseId);

    gameState.updatePOICourses(poiId, updatedCourses);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course removed from POI successfully!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  IconData _getPOIIcon(String type) {
    switch (type.toLowerCase()) {
      case 'island':
        return Icons.terrain;
      case 'reef':
        return Icons.waves;
      case 'wreck':
        return Icons.directions_boat;
      case 'cave':
        return Icons.location_city;
      case 'deep':
        return Icons.arrow_downward;
      default:
        return Icons.location_on;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 