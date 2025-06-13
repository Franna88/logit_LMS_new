import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/game_state_provider.dart';
import '../../models/diving_course.dart';
import 'course_builder_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> with TickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedPOI = 'All';
  String _sortBy = 'title';
  bool _isGridView = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<GameStateProvider>(
            builder: (context, gameState, child) {
              final allCourses = gameState.getAllCourses();
              final filteredCourses = _filterAndSortCourses(allCourses, gameState);

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Modern Header
                    _buildModernHeader(allCourses.length),
                    
                    // Enhanced Search and Filter Section
                    _buildSearchAndFilters(gameState),
                    
                    // View Toggle and Sort
                    _buildViewControls(filteredCourses.length),
                    
                    // Course Content
                    Expanded(
                      child: filteredCourses.isEmpty
                          ? _buildEmptyState()
                          : _isGridView
                              ? _buildGridView(filteredCourses, gameState)
                              : _buildListView(filteredCourses, gameState),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernHeader(int totalCourses) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Course Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage and organize your diving courses',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              _buildStatCard(
                icon: Icons.school,
                label: 'Total Courses',
                value: totalCourses.toString(),
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.trending_up,
                label: 'Active',
                value: totalCourses.toString(),
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.people,
                label: 'Enrolled',
                value: '${totalCourses * 15}',
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(GameStateProvider gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search courses, topics, or descriptions...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.7)),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Difficulty',
                  value: _selectedDifficulty,
                  options: ['All', 'Beginner', 'Intermediate', 'Advanced'],
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: 'POI',
                  value: _selectedPOI,
                  options: ['All', ...gameState.pointsOfInterest.map((poi) => poi.name)],
                  onChanged: (value) {
                    setState(() {
                      _selectedPOI = value;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: 'Sort by',
                  value: _sortBy,
                  options: ['title', 'price', 'duration', 'difficulty'],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.white.withOpacity(0.7)),
          dropdownColor: const Color(0xFF1E293B),
          style: const TextStyle(color: Colors.white),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(
                option == 'title' ? 'Title' :
                option == 'price' ? 'Price' :
                option == 'duration' ? 'Duration' :
                option == 'difficulty' ? 'Difficulty' : option,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (newValue) => onChanged(newValue!),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildViewControls(int filteredCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Text(
            '$filteredCount courses',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildViewToggleButton(
                  icon: Icons.view_list,
                  isSelected: !_isGridView,
                  onTap: () => setState(() => _isGridView = false),
                ),
                _buildViewToggleButton(
                  icon: Icons.grid_view,
                  isSelected: _isGridView,
                  onTap: () => setState(() => _isGridView = true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No courses found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Create your first course to get started',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToCreateCourse,
            icon: const Icon(Icons.add),
            label: const Text('Create Course'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<DivingCourse> courses, GameStateProvider gameState) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final poiName = _findPOIForCourse(course, gameState);
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildCourseCard(course, poiName, gameState),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView(List<DivingCourse> courses, GameStateProvider gameState) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final poiName = _findPOIForCourse(course, gameState);
        
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: _buildCourseGridCard(course, poiName, gameState),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCourseCard(DivingCourse course, String poiName, GameStateProvider gameState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _editCourse(course),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(course.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.school,
                        color: _getDifficultyColor(course.difficulty),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(course.difficulty).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              course.difficulty,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getDifficultyColor(course.difficulty),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7)),
                      color: const Color(0xFF1E293B),
                      itemBuilder: (context) => [
                        _buildPopupMenuItem(Icons.edit, 'Edit', 'edit'),
                        _buildPopupMenuItem(Icons.copy, 'Duplicate', 'duplicate'),
                        _buildPopupMenuItem(Icons.delete, 'Delete', 'delete', isDestructive: true),
                      ],
                      onSelected: (value) => _handleCourseAction(value, course, gameState),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                // Topics
                if (course.topics.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: course.topics.take(3).map((topic) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          topic,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Course Info
                Row(
                  children: [
                    _buildInfoChip(Icons.location_on, poiName),
                    const SizedBox(width: 12),
                                         _buildInfoChip(Icons.attach_money, 'R${course.price.toStringAsFixed(0)}'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.timer, '${course.duration}min'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseGridCard(DivingCourse course, String poiName, GameStateProvider gameState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _editCourse(course),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(course.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school,
                        color: _getDifficultyColor(course.difficulty),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.7), size: 20),
                      color: const Color(0xFF1E293B),
                      itemBuilder: (context) => [
                        _buildPopupMenuItem(Icons.edit, 'Edit', 'edit'),
                        _buildPopupMenuItem(Icons.copy, 'Duplicate', 'duplicate'),
                        _buildPopupMenuItem(Icons.delete, 'Delete', 'delete', isDestructive: true),
                      ],
                      onSelected: (value) => _handleCourseAction(value, course, gameState),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(course.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    course.difficulty,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getDifficultyColor(course.difficulty),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                Column(
                  children: [
                    _buildGridInfoRow(Icons.location_on, poiName),
                    const SizedBox(height: 4),
                                         _buildGridInfoRow(Icons.attach_money, 'R${course.price.toStringAsFixed(0)}'),
                    const SizedBox(height: 4),
                    _buildGridInfoRow(Icons.timer, '${course.duration}min'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white.withOpacity(0.7)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(IconData icon, String text, String value, {bool isDestructive = false}) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: isDestructive ? Colors.red : Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDestructive ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateCourse,
      backgroundColor: const Color(0xFF3B82F6),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Create Course'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  List<DivingCourse> _filterAndSortCourses(List<DivingCourse> courses, GameStateProvider gameState) {
    var filtered = courses.where((course) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!course.title.toLowerCase().contains(query) &&
            !course.description.toLowerCase().contains(query) &&
            !course.topics.any((topic) => topic.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Difficulty filter
      if (_selectedDifficulty != 'All' && course.difficulty != _selectedDifficulty) {
        return false;
      }

      // POI filter
      if (_selectedPOI != 'All') {
        final poiName = _findPOIForCourse(course, gameState);
        if (poiName != _selectedPOI) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort courses
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'price':
          return a.price.compareTo(b.price);
        case 'duration':
          return a.duration.compareTo(b.duration);
        case 'difficulty':
          final difficultyOrder = {'Beginner': 0, 'Intermediate': 1, 'Advanced': 2};
          return (difficultyOrder[a.difficulty] ?? 3).compareTo(difficultyOrder[b.difficulty] ?? 3);
        case 'title':
        default:
          return a.title.compareTo(b.title);
      }
    });

    return filtered;
  }

  String _findPOIForCourse(DivingCourse course, GameStateProvider gameState) {
    for (final poi in gameState.pointsOfInterest) {
      if (poi.courses.any((c) => c.id == course.id)) {
        return poi.name;
      }
    }
    return 'Unassigned';
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF10B981);
      case 'intermediate':
        return const Color(0xFFF59E0B);
      case 'advanced':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _navigateToCreateCourse() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CourseBuilderScreen(),
      ),
    );
  }

  void _editCourse(DivingCourse course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CourseBuilderScreen(existingCourse: course),
      ),
    );
  }

  void _handleCourseAction(String action, DivingCourse course, GameStateProvider gameState) {
    switch (action) {
      case 'edit':
        _editCourse(course);
        break;
      case 'duplicate':
        _duplicateCourse(course, gameState);
        break;
      case 'delete':
        _deleteCourse(course, gameState);
        break;
    }
  }

  void _duplicateCourse(DivingCourse course, GameStateProvider gameState) {
    final duplicatedCourse = DivingCourse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${course.title} (Copy)',
      description: course.description,
      price: course.price,
      difficulty: course.difficulty,
      duration: course.duration,
      topics: List.from(course.topics),
      iconPath: course.iconPath,
    );

    // Find the POI that contains the original course
    final poiName = _findPOIForCourse(course, gameState);
    if (poiName != 'Unassigned') {
      gameState.addCourseToSpecificPOI(duplicatedCourse, poiName);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course "${duplicatedCourse.title}" created successfully!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _deleteCourse(DivingCourse course, GameStateProvider gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Course',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${course.title}"? This action cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Find and remove the course from its POI
              for (final poi in gameState.pointsOfInterest) {
                poi.courses.removeWhere((c) => c.id == course.id);
              }
              gameState.notifyListeners();
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Course "${course.title}" deleted successfully!'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 