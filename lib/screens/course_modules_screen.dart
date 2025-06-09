import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../models/diving_course.dart';
import '../models/poi.dart';
import '../widgets/bubble_animation.dart';
import 'module_lesson_screen.dart';

class CourseModule {
  final String id;
  final String title;
  final String description;
  final int duration; // in minutes
  final bool isCompleted;
  final bool isLocked;
  final List<String> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    this.isCompleted = false,
    this.isLocked = false,
    this.lessons = const [],
  });
}

class CourseModulesScreen extends StatefulWidget {
  final POI poi;
  final DivingCourse? course;

  const CourseModulesScreen({
    super.key,
    required this.poi,
    this.course,
  });

  @override
  State<CourseModulesScreen> createState() => _CourseModulesScreenState();
}

class _CourseModulesScreenState extends State<CourseModulesScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  List<CourseModule> modules = [];
  DivingCourse? selectedCourse;
  Map<String, bool> expandedModules = {};
  
  // Filter state
  String selectedFilter = 'All Courses';
  final List<String> filterOptions = [
    'All Courses',
    'Available to Buy',
    'Purchased', 
    'Completed',
    'In Progress',
    'Beginner Level',
    'Intermediate Level', 
    'Advanced Level'
  ];

  @override
  void initState() {
    super.initState();
    
    // Select the first course by default if available
    if (widget.poi.courses.isNotEmpty) {
      selectedCourse = widget.poi.courses.first;
    }
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _generateDummyModules();
    _startAnimations();
  }

  void _generateDummyModules() {
    if (selectedCourse == null) return;
    
    switch (selectedCourse!.id) {
      case 'open_water':
        modules = [
          CourseModule(
            id: 'theory_basics',
            title: 'Diving Theory Basics',
            description: 'Learn fundamental diving principles and physics',
            duration: 45,
            lessons: ['Pressure & Depth', 'Gas Laws', 'Buoyancy Principles', 'Nitrogen Absorption'],
          ),
          CourseModule(
            id: 'equipment',
            title: 'Equipment Overview',
            description: 'Understanding your diving gear and safety equipment',
            duration: 30,
            lessons: ['Mask & Fins', 'Regulator System', 'BCD Operation', 'Wetsuit Selection'],
          ),
          CourseModule(
            id: 'pool_training',
            title: 'Pool Training',
            description: 'Practice basic skills in a controlled environment',
            duration: 60,
            lessons: ['Breathing Underwater', 'Clearing Mask', 'Emergency Ascent', 'Buddy System'],
          ),
          CourseModule(
            id: 'open_water_dives',
            title: 'Open Water Certification',
            description: 'Complete your certification dives in real conditions',
            duration: 120,
            lessons: ['Pre-dive Safety Check', 'Descent Techniques', 'Underwater Navigation', 'Emergency Procedures'],
            isLocked: true,
          ),
        ];
        break;
      case 'marine_biology':
        modules = [
          CourseModule(
            id: 'marine_ecosystems',
            title: 'Marine Ecosystems',
            description: 'Understanding underwater habitats and food chains',
            duration: 35,
            lessons: ['Coral Reefs', 'Kelp Forests', 'Deep Sea Habitats', 'Tropical Waters'],
          ),
          CourseModule(
            id: 'species_identification',
            title: 'Species Identification',
            description: 'Learn to identify common marine life',
            duration: 40,
            lessons: ['Fish Species', 'Invertebrates', 'Marine Mammals', 'Coral Types'],
          ),
          CourseModule(
            id: 'behavior_observation',
            title: 'Marine Behavior',
            description: 'Study marine animal behavior and interactions',
            duration: 30,
            lessons: ['Feeding Patterns', 'Mating Behavior', 'Territorial Displays', 'Symbiotic Relationships'],
          ),
        ];
        break;
      case 'wreck_diving':
        modules = [
          CourseModule(
            id: 'wreck_history',
            title: 'Maritime History',
            description: 'Learn about famous shipwrecks and their stories',
            duration: 30,
            lessons: ['Titanic & Famous Wrecks', 'WWII Naval History', 'Merchant Vessels', 'Archaeological Sites'],
          ),
          CourseModule(
            id: 'penetration_techniques',
            title: 'Wreck Penetration',
            description: 'Safe entry and navigation inside wrecks',
            duration: 50,
            lessons: ['Entry Planning', 'Line Following', 'Air Management', 'Emergency Exit Routes'],
          ),
          CourseModule(
            id: 'photography',
            title: 'Wreck Photography',
            description: 'Capture the beauty of underwater archaeology',
            duration: 40,
            lessons: ['Lighting Techniques', 'Composition', 'Equipment Setup', 'Post-Processing'],
            isLocked: true,
          ),
        ];
        break;
      case 'deep_diving':
        modules = [
          CourseModule(
            id: 'depth_physiology',
            title: 'Deep Water Physiology',
            description: 'Understanding how depth affects the human body',
            duration: 40,
            lessons: ['Nitrogen Narcosis', 'Oxygen Toxicity', 'Decompression Theory', 'Gas Management'],
          ),
          CourseModule(
            id: 'safety_procedures',
            title: 'Safety Protocols',
            description: 'Advanced safety procedures for deep diving',
            duration: 35,
            lessons: ['Dive Planning', 'Emergency Ascent', 'Decompression Stops', 'Rescue Techniques'],
          ),
          CourseModule(
            id: 'deep_exploration',
            title: 'Deep Water Exploration',
            description: 'Practical deep diving experience',
            duration: 90,
            lessons: ['Deep Descent Techniques', 'Bottom Time Management', 'Advanced Navigation', 'Equipment Checks'],
            isLocked: true,
          ),
        ];
        break;
      case 'cave_diving':
        modules = [
          CourseModule(
            id: 'cave_environment',
            title: 'Cave Environment',
            description: 'Understanding the unique challenges of cave diving',
            duration: 45,
            lessons: ['Cave Formation', 'Water Conditions', 'Hazard Recognition', 'Environmental Protection'],
          ),
          CourseModule(
            id: 'line_techniques',
            title: 'Guideline Techniques',
            description: 'Master the use of guidelines for safe navigation',
            duration: 40,
            lessons: ['Line Laying', 'Line Following', 'Tie-offs', 'Emergency Procedures'],
          ),
          CourseModule(
            id: 'advanced_penetration',
            title: 'Advanced Cave Penetration',
            description: 'Complex cave diving scenarios and techniques',
            duration: 60,
            lessons: ['Restrictions Navigation', 'Silt Management', 'Lost Line Procedures', 'Team Communication'],
            isLocked: true,
          ),
        ];
        break;
      case 'scientific_diving':
        modules = [
          CourseModule(
            id: 'research_methods',
            title: 'Research Methodology',
            description: 'Scientific approaches to underwater research',
            duration: 50,
            lessons: ['Data Collection', 'Sampling Techniques', 'Documentation', 'Research Ethics'],
          ),
          CourseModule(
            id: 'equipment_operation',
            title: 'Scientific Equipment',
            description: 'Operating specialized research equipment underwater',
            duration: 45,
            lessons: ['Underwater Cameras', 'Sampling Tools', 'Measurement Devices', 'Data Loggers'],
          ),
          CourseModule(
            id: 'field_work',
            title: 'Field Research Project',
            description: 'Conduct real scientific research underwater',
            duration: 120,
            lessons: ['Project Planning', 'Data Collection', 'Analysis', 'Report Writing'],
            isLocked: true,
          ),
        ];
        break;
      case 'kelp_forest_diving':
        modules = [
          CourseModule(
            id: 'kelp_navigation',
            title: 'Kelp Forest Navigation',
            description: 'Navigate safely through dense kelp forests',
            duration: 30,
            lessons: ['Entry Techniques', 'Kelp Avoidance', 'Emergency Procedures', 'Current Management'],
          ),
          CourseModule(
            id: 'marine_life',
            title: 'Kelp Forest Ecology',
            description: 'Discover the rich ecosystem of kelp forests',
            duration: 40,
            lessons: ['Kelp Species', 'Fish Communities', 'Invertebrate Life', 'Predator-Prey Relationships'],
          ),
          CourseModule(
            id: 'conservation',
            title: 'Marine Conservation',
            description: 'Learn about protecting kelp forest ecosystems',
            duration: 25,
            lessons: ['Threats to Kelp Forests', 'Conservation Efforts', 'Sustainable Diving', 'Citizen Science'],
          ),
        ];
        break;
      case 'technical_wreck':
        modules = [
          CourseModule(
            id: 'mixed_gas',
            title: 'Mixed Gas Diving',
            description: 'Advanced gas mixtures for deep wreck penetration',
            duration: 60,
            lessons: ['Trimix Theory', 'Gas Planning', 'Equipment Setup', 'Emergency Procedures'],
          ),
          CourseModule(
            id: 'decompression',
            title: 'Advanced Decompression',
            description: 'Complex decompression procedures for technical dives',
            duration: 55,
            lessons: ['Decompression Software', 'Multi-level Stops', 'Accelerated Decompression', 'Emergency Protocols'],
          ),
          CourseModule(
            id: 'penetration_advanced',
            title: 'Advanced Penetration',
            description: 'Complex wreck penetration techniques',
            duration: 75,
            lessons: ['Multi-level Penetration', 'Team Procedures', 'Equipment Management', 'Emergency Exit'],
            isLocked: true,
          ),
        ];
        break;
      case 'military_history':
        modules = [
          CourseModule(
            id: 'naval_warfare',
            title: 'Naval Warfare History',
            description: 'Understanding military naval operations',
            duration: 35,
            lessons: ['WWII Pacific Theater', 'Atlantic Battles', 'Submarine Warfare', 'Naval Technology'],
          ),
          CourseModule(
            id: 'wreck_identification',
            title: 'Military Wreck Identification',
            description: 'Identifying military vessels and aircraft',
            duration: 40,
            lessons: ['Ship Classifications', 'Aircraft Types', 'Armament Recognition', 'Historical Context'],
          ),
        ];
        break;
      case 'underwater_photography':
        modules = [
          CourseModule(
            id: 'camera_basics',
            title: 'Underwater Camera Basics',
            description: 'Learn underwater camera operation and settings',
            duration: 40,
            lessons: ['Camera Housing', 'White Balance', 'Focus Modes', 'Basic Settings'],
          ),
          CourseModule(
            id: 'lighting_techniques',
            title: 'Underwater Lighting',
            description: 'Master underwater lighting and strobe techniques',
            duration: 50,
            lessons: ['Natural Light', 'Strobe Positioning', 'Color Correction', 'Shadow Management'],
          ),
          CourseModule(
            id: 'composition_skills',
            title: 'Composition & Framing',
            description: 'Develop artistic eye for underwater photography',
            duration: 35,
            lessons: ['Rule of Thirds', 'Leading Lines', 'Negative Space', 'Subject Isolation'],
          ),
        ];
        break;
      case 'macro_photography':
        modules = [
          CourseModule(
            id: 'macro_equipment',
            title: 'Macro Equipment Setup',
            description: 'Specialized equipment for macro photography',
            duration: 30,
            lessons: ['Macro Lenses', 'Extension Tubes', 'Diopters', 'Support Systems'],
          ),
          CourseModule(
            id: 'close_up_techniques',
            title: 'Close-up Techniques',
            description: 'Advanced techniques for small subject photography',
            duration: 45,
            lessons: ['Focus Stacking', 'Magnification Ratios', 'Depth of Field', 'Subject Approach'],
          ),
        ];
        break;
      case 'digital_imaging':
        modules = [
          CourseModule(
            id: 'digital_sensors',
            title: 'Digital Sensor Technology',
            description: 'Understanding modern digital imaging sensors',
            duration: 40,
            lessons: ['Sensor Types', 'Resolution', 'Dynamic Range', 'ISO Performance'],
          ),
          CourseModule(
            id: 'post_processing',
            title: 'Digital Post-Processing',
            description: 'Edit and enhance underwater images',
            duration: 60,
            lessons: ['RAW Processing', 'Color Correction', 'Contrast Enhancement', 'Noise Reduction'],
          ),
          CourseModule(
            id: 'video_recording',
            title: 'Underwater Videography',
            description: 'Record and edit underwater video content',
            duration: 50,
            lessons: ['Video Settings', 'Stabilization', 'Movement Techniques', 'Editing Basics'],
          ),
        ];
        break;
      case 'advanced_wreck':
        modules = [
          CourseModule(
            id: 'technical_penetration',
            title: 'Technical Penetration Skills',
            description: 'Advanced wreck penetration techniques',
            duration: 80,
            lessons: ['Complex Navigation', 'Multi-level Penetration', 'Emergency Procedures', 'Team Coordination'],
          ),
          CourseModule(
            id: 'gas_management',
            title: 'Advanced Gas Management',
            description: 'Gas planning for complex wreck dives',
            duration: 60,
            lessons: ['Rule of Thirds', 'Contingency Planning', 'Emergency Gas', 'Team Protocols'],
          ),
        ];
        break;
      case 'wreck_archaeology':
        modules = [
          CourseModule(
            id: 'archaeological_methods',
            title: 'Archaeological Documentation',
            description: 'Scientific methods for wreck documentation',
            duration: 50,
            lessons: ['Site Mapping', 'Artifact Recording', 'Photography', 'Data Management'],
          ),
          CourseModule(
            id: 'preservation',
            title: 'Preservation Techniques',
            description: 'Protect and preserve underwater heritage',
            duration: 45,
            lessons: ['Conservation Ethics', 'Site Protection', 'Legal Framework', 'Best Practices'],
          ),
        ];
        break;
      case 'treasure_hunting':
        modules = [
          CourseModule(
            id: 'detection_methods',
            title: 'Metal Detection & Search',
            description: 'Advanced search and detection techniques',
            duration: 60,
            lessons: ['Metal Detector Operation', 'Search Patterns', 'Target Identification', 'Recovery Methods'],
          ),
          CourseModule(
            id: 'legal_aspects',
            title: 'Legal & Ethical Considerations',
            description: 'Laws and ethics of treasure hunting',
            duration: 40,
            lessons: ['Maritime Law', 'Salvage Rights', 'Permits', 'Ethical Guidelines'],
          ),
        ];
        break;
      case 'technical_diving':
        modules = [
          CourseModule(
            id: 'mixed_gas_theory',
            title: 'Mixed Gas Theory',
            description: 'Understanding gas mixtures for technical diving',
            duration: 70,
            lessons: ['Nitrox Theory', 'Trimix Basics', 'Gas Properties', 'Toxicity Limits'],
          ),
          CourseModule(
            id: 'decompression_theory',
            title: 'Decompression Theory',
            description: 'Advanced decompression planning and execution',
            duration: 80,
            lessons: ['Decompression Models', 'Stop Schedules', 'Gradient Factors', 'Emergency Procedures'],
          ),
        ];
        break;
      case 'trimix_diving':
        modules = [
          CourseModule(
            id: 'gas_blending',
            title: 'Gas Blending Techniques',
            description: 'Learn to mix trimix gases safely',
            duration: 60,
            lessons: ['Mixing Calculations', 'Equipment Setup', 'Safety Procedures', 'Quality Control'],
          ),
          CourseModule(
            id: 'deep_exploration',
            title: 'Deep Exploration Techniques',
            description: 'Advanced techniques for extreme depth diving',
            duration: 100,
            lessons: ['Deep Descent', 'Narcosis Management', 'Emergency Ascent', 'Team Procedures'],
          ),
        ];
        break;
      case 'search_recovery':
        modules = [
          CourseModule(
            id: 'search_patterns',
            title: 'Professional Search Patterns',
            description: 'Systematic search techniques for recovery operations',
            duration: 50,
            lessons: ['Grid Patterns', 'Circular Search', 'Compass Navigation', 'Team Coordination'],
          ),
          CourseModule(
            id: 'recovery_methods',
            title: 'Object Recovery Techniques',
            description: 'Safe and effective recovery procedures',
            duration: 60,
            lessons: ['Lift Calculations', 'Rigging Techniques', 'Safety Protocols', 'Equipment Operation'],
          ),
        ];
        break;
      case 'lift_bag':
        modules = [
          CourseModule(
            id: 'lift_calculations',
            title: 'Lift Bag Calculations',
            description: 'Mathematical principles of underwater lifting',
            duration: 35,
            lessons: ['Buoyancy Calculations', 'Weight Assessment', 'Safety Margins', 'Load Limits'],
          ),
          CourseModule(
            id: 'deployment_techniques',
            title: 'Lift Bag Deployment',
            description: 'Proper deployment and control of lift bags',
            duration: 45,
            lessons: ['Attachment Methods', 'Controlled Ascent', 'Emergency Procedures', 'Surface Operations'],
          ),
        ];
        break;
      case 'evidence_recovery':
        modules = [
          CourseModule(
            id: 'chain_custody',
            title: 'Chain of Custody Procedures',
            description: 'Legal procedures for evidence handling',
            duration: 40,
            lessons: ['Documentation Requirements', 'Evidence Packaging', 'Transportation', 'Court Testimony'],
          ),
          CourseModule(
            id: 'underwater_photography_evidence',
            title: 'Evidence Photography',
            description: 'Specialized photography for legal evidence',
            duration: 50,
            lessons: ['Photo Standards', 'Scale References', 'Lighting Requirements', 'Digital Integrity'],
          ),
        ];
        break;
      case 'cavern_diving':
        modules = [
          CourseModule(
            id: 'light_zone',
            title: 'Light Zone Exploration',
            description: 'Safe exploration within the light zone',
            duration: 40,
            lessons: ['Light Zone Limits', 'Natural Navigation', 'Emergency Exit', 'Equipment Requirements'],
          ),
          CourseModule(
            id: 'basic_overhead',
            title: 'Basic Overhead Environment',
            description: 'Introduction to overhead diving environments',
            duration: 35,
            lessons: ['Overhead Hazards', 'Exit Awareness', 'Air Management', 'Team Communication'],
          ),
        ];
        break;
      case 'cave_rescue':
        modules = [
          CourseModule(
            id: 'rescue_planning',
            title: 'Cave Rescue Planning',
            description: 'Plan and execute cave rescue operations',
            duration: 80,
            lessons: ['Incident Assessment', 'Resource Management', 'Risk Analysis', 'Operational Planning'],
          ),
          CourseModule(
            id: 'victim_recovery',
            title: 'Victim Recovery Techniques',
            description: 'Specialized techniques for cave victim recovery',
            duration: 90,
            lessons: ['Patient Assessment', 'Evacuation Methods', 'Medical Considerations', 'Team Coordination'],
          ),
        ];
        break;
      case 'cave_survey':
        modules = [
          CourseModule(
            id: 'survey_techniques',
            title: 'Cave Survey Methods',
            description: 'Professional cave surveying and mapping',
            duration: 60,
            lessons: ['Survey Instruments', 'Measurement Techniques', 'Data Recording', 'Quality Control'],
          ),
          CourseModule(
            id: 'mapping_software',
            title: 'Digital Cave Mapping',
            description: 'Use software to create detailed cave maps',
            duration: 50,
            lessons: ['Survey Software', 'Data Input', '3D Modeling', 'Map Production'],
          ),
        ];
        break;
      case 'thermal_vent_biology':
        modules = [
          CourseModule(
            id: 'extremophiles',
            title: 'Extremophile Organisms',
            description: 'Study life forms that thrive in extreme conditions',
            duration: 45,
            lessons: ['Bacterial Communities', 'Archaea', 'Adaptation Mechanisms', 'Evolutionary Biology'],
          ),
          CourseModule(
            id: 'chemosynthesis',
            title: 'Chemosynthetic Processes',
            description: 'Understand energy production without sunlight',
            duration: 40,
            lessons: ['Chemical Energy', 'Metabolic Pathways', 'Primary Production', 'Food Web Dynamics'],
          ),
        ];
        break;
      case 'geological_survey':
        modules = [
          CourseModule(
            id: 'rock_identification',
            title: 'Underwater Rock Identification',
            description: 'Identify and classify underwater rock formations',
            duration: 50,
            lessons: ['Rock Types', 'Formation Processes', 'Mineral Identification', 'Geological History'],
          ),
          CourseModule(
            id: 'sample_collection',
            title: 'Geological Sample Collection',
            description: 'Proper techniques for collecting geological samples',
            duration: 40,
            lessons: ['Sampling Methods', 'Preservation Techniques', 'Data Recording', 'Laboratory Analysis'],
          ),
        ];
        break;
      case 'deep_sea_research':
        modules = [
          CourseModule(
            id: 'research_equipment',
            title: 'Deep Sea Research Equipment',
            description: 'Advanced equipment for deep sea exploration',
            duration: 70,
            lessons: ['ROV Operation', 'Pressure Vessels', 'Sampling Tools', 'Communication Systems'],
          ),
          CourseModule(
            id: 'data_analysis',
            title: 'Scientific Data Analysis',
            description: 'Analyze and interpret deep sea research data',
            duration: 60,
            lessons: ['Statistical Methods', 'Data Visualization', 'Report Writing', 'Peer Review'],
          ),
        ];
        break;
      case 'environmental_monitoring':
        modules = [
          CourseModule(
            id: 'water_quality',
            title: 'Water Quality Assessment',
            description: 'Monitor and assess underwater water quality',
            duration: 40,
            lessons: ['Chemical Parameters', 'Biological Indicators', 'Pollution Sources', 'Impact Assessment'],
          ),
          CourseModule(
            id: 'monitoring_equipment',
            title: 'Environmental Monitoring Equipment',
            description: 'Use specialized equipment for environmental monitoring',
            duration: 35,
            lessons: ['Sensor Technology', 'Data Loggers', 'Calibration', 'Maintenance Procedures'],
          ),
        ];
        break;
      case 'submarine_penetration':
        modules = [
          CourseModule(
            id: 'submarine_layout',
            title: 'Submarine Layout & Systems',
            description: 'Understanding submarine internal structure',
            duration: 60,
            lessons: ['Compartment Layout', 'Access Routes', 'Emergency Systems', 'Historical Variations'],
          ),
          CourseModule(
            id: 'penetration_safety',
            title: 'Submarine Penetration Safety',
            description: 'Advanced safety protocols for submarine exploration',
            duration: 70,
            lessons: ['Structural Integrity', 'Hazard Recognition', 'Emergency Procedures', 'Equipment Requirements'],
          ),
        ];
        break;
      case 'naval_archaeology':
        modules = [
          CourseModule(
            id: 'historical_research',
            title: 'Naval Historical Research',
            description: 'Research methods for naval archaeology',
            duration: 45,
            lessons: ['Archival Research', 'Historical Documents', 'Ship Identification', 'Timeline Construction'],
          ),
          CourseModule(
            id: 'site_mapping',
            title: 'Archaeological Site Mapping',
            description: 'Create detailed maps of naval archaeological sites',
            duration: 55,
            lessons: ['Mapping Techniques', 'GPS Integration', 'Photogrammetry', 'Digital Documentation'],
          ),
        ];
        break;
      case 'war_history':
        modules = [
          CourseModule(
            id: 'pacific_battles',
            title: 'Pacific Theater Naval Battles',
            description: 'Study major naval engagements in the Pacific',
            duration: 30,
            lessons: ['Pearl Harbor', 'Midway', 'Leyte Gulf', 'Guadalcanal Campaign'],
          ),
          CourseModule(
            id: 'ship_identification',
            title: 'WWII Ship Identification',
            description: 'Identify different classes of WWII naval vessels',
            duration: 25,
            lessons: ['Destroyer Classes', 'Cruiser Types', 'Battleship Designs', 'Aircraft Carriers'],
          ),
        ];
        break;
      case 'commercial_diving':
        modules = [
          CourseModule(
            id: 'industrial_operations',
            title: 'Industrial Diving Operations',
            description: 'Commercial diving for industrial applications',
            duration: 100,
            lessons: ['Welding Underwater', 'Inspection Techniques', 'Maintenance Procedures', 'Safety Standards'],
          ),
          CourseModule(
            id: 'surface_supply',
            title: 'Surface Supply Systems',
            description: 'Operation of surface-supplied diving equipment',
            duration: 80,
            lessons: ['Compressor Systems', 'Umbilical Management', 'Communications', 'Emergency Procedures'],
          ),
        ];
        break;
      case 'sidemount':
        modules = [
          CourseModule(
            id: 'equipment_config',
            title: 'Sidemount Equipment Configuration',
            description: 'Proper setup and configuration of sidemount gear',
            duration: 50,
            lessons: ['Harness Setup', 'Tank Positioning', 'Regulator Configuration', 'Buoyancy Management'],
          ),
          CourseModule(
            id: 'skills_development',
            title: 'Sidemount Skills Development',
            description: 'Master essential sidemount diving skills',
            duration: 60,
            lessons: ['Tank Handling', 'Trim Control', 'Gas Switching', 'Emergency Procedures'],
          ),
        ];
        break;
      default:
        modules = [
          CourseModule(
            id: 'intro',
            title: 'Course Introduction',
            description: 'Welcome to your diving course',
            duration: 20,
            lessons: ['Overview', 'Safety Guidelines', 'Course Objectives', 'Assessment Criteria'],
          ),
          CourseModule(
            id: 'fundamentals',
            title: 'Diving Fundamentals',
            description: 'Basic diving knowledge and skills',
            duration: 45,
            lessons: ['Breathing Techniques', 'Equipment Basics', 'Safety Procedures', 'Environmental Awareness'],
          ),
        ];
    }
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
  }

  String _getBackgroundImage() {
    if (selectedCourse == null) return 'assets/images/coral_diving.jpg';
    
    switch (selectedCourse!.difficulty.toLowerCase()) {
      case 'beginner':
        return 'assets/images/coral_diving.jpg';
      case 'intermediate':
        return 'assets/images/coral_diving.jpg';
      case 'advanced':
        return 'assets/images/cave_diving.jpg';
      default:
        if (selectedCourse!.id.contains('wreck')) {
          return 'assets/images/ship_wreck.jpg';
        }
        return 'assets/images/coral_diving.jpg';
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DivingBubbleTransition(
        child: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getBackgroundImage()),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),

            // Back button
            SafeArea(
              child: Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),

            // Main content with slide animation
            SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Row(
                  children: [
                    // Left side - Course List (40% width)
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildCoursesList(),
                        ),
                      ),
                    ),
                    
                    // Right side - Course Modules (60% width)
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildModulesList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DivingCourse> _getFilteredCourses() {
    final courses = widget.poi.courses;
    
    switch (selectedFilter) {
      case 'All Courses':
        return courses;
      case 'Available to Buy':
        return courses.where((course) => !course.isPurchased).toList();
      case 'Purchased':
        return courses.where((course) => course.isPurchased).toList();
      case 'Completed':
        return courses.where((course) => course.isCompleted).toList();
      case 'In Progress':
        return courses.where((course) => course.isPurchased && !course.isCompleted && course.progress > 0).toList();
      case 'Beginner Level':
        return courses.where((course) => course.difficulty.toLowerCase() == 'beginner').toList();
      case 'Intermediate Level':
        return courses.where((course) => course.difficulty.toLowerCase() == 'intermediate').toList();
      case 'Advanced Level':
        return courses.where((course) => course.difficulty.toLowerCase() == 'advanced').toList();
      default:
        return courses;
    }
  }

  int _getFilterCount(String filter) {
    final courses = widget.poi.courses;
    
    switch (filter) {
      case 'All Courses':
        return courses.length;
      case 'Available to Buy':
        return courses.where((course) => !course.isPurchased).length;
      case 'Purchased':
        return courses.where((course) => course.isPurchased).length;
      case 'Completed':
        return courses.where((course) => course.isCompleted).length;
      case 'In Progress':
        return courses.where((course) => course.isPurchased && !course.isCompleted && course.progress > 0).length;
      case 'Beginner Level':
        return courses.where((course) => course.difficulty.toLowerCase() == 'beginner').length;
      case 'Intermediate Level':
        return courses.where((course) => course.difficulty.toLowerCase() == 'intermediate').length;
      case 'Advanced Level':
        return courses.where((course) => course.difficulty.toLowerCase() == 'advanced').length;
      default:
        return 0;
    }
  }

  Widget _buildCoursesList() {
    final filteredCourses = _getFilteredCourses();
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Courses',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${filteredCourses.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Filter Options
              Container(
                height: 40,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    return true;
                  },
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            for (int index = 0; index < filterOptions.length; index++) ...[
                              _buildFilterChip(filterOptions[index]),
                              if (index < filterOptions.length - 1) const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Courses List
              Expanded(
                child: filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No courses found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try a different filter',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          return _buildCourseCard(filteredCourses[index], index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(DivingCourse course, int index) {
    final isSelected = selectedCourse?.id == course.id;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCourse = course;
            _generateDummyModules();
            expandedModules.clear(); // Reset expanded modules when switching courses
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.blue.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? Colors.blue.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Status Badge Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(course),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                course.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Progress bar for purchased courses
              if (course.isPurchased && course.progress > 0) ...[
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: course.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: course.isCompleted ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(course.difficulty).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      course.difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!course.isPurchased)
                    Text(
                      'R${course.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.yellow : Colors.white.withOpacity(0.8),
                      ),
                    )
                  else if (course.progress > 0 && !course.isCompleted)
                    Text(
                      '${(course.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(
          begin: -0.3,
          end: 0,
          duration: const Duration(milliseconds: 400),
        );
  }

  Widget _buildStatusBadge(DivingCourse course) {
    if (course.isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, size: 10, color: Colors.white),
            SizedBox(width: 2),
            Text(
              'Completed',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    } else if (course.isPurchased) {
      if (course.progress > 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.play_circle, size: 10, color: Colors.white),
              SizedBox(width: 2),
              Text(
                'In Progress',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.download_done, size: 10, color: Colors.white),
              SizedBox(width: 2),
              Text(
                'Owned',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shopping_cart, size: 10, color: Colors.white),
            SizedBox(width: 2),
            Text(
              'Available',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildModulesList() {
    if (selectedCourse == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'Select a course to view modules',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course header with Lottie animation
              Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Lottie animation
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Lottie.asset(
                        'assets/animations/Diver.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Course info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedCourse!.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedCourse!.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Modules title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Course Modules',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Modules list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    return _buildModuleCard(modules[index], index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(CourseModule module, int index) {
    final isExpanded = expandedModules[module.id] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(module.isLocked ? 0.05 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          children: [
            // Module header
            GestureDetector(
              onTap: module.isLocked ? null : () {
                setState(() {
                  expandedModules[module.id] = !isExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Module icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: module.isLocked 
                            ? Colors.grey.withOpacity(0.3)
                            : module.isCompleted 
                                ? Colors.green.withOpacity(0.8)
                                : const Color(0xFF3B82F6).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        module.isLocked 
                            ? Icons.lock
                            : module.isCompleted 
                                ? Icons.check
                                : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Module details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: module.isLocked 
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: module.isLocked 
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Duration and expand icon
                    Column(
                      children: [
                        Text(
                          '${module.duration} min',
                          style: TextStyle(
                            fontSize: 10,
                            color: module.isLocked 
                                ? Colors.white.withOpacity(0.3)
                                : Colors.white.withOpacity(0.6),
                          ),
                        ),
                        if (!module.isLocked && module.lessons.isNotEmpty)
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Lessons dropdown
            if (isExpanded && module.lessons.isNotEmpty)
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: module.lessons.map((lesson) => 
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lesson,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                                                     GestureDetector(
                             onTap: () => _startLesson(module, lesson),
                             child: Icon(
                               Icons.play_circle_outline,
                               color: Colors.white.withOpacity(0.6),
                               size: 16,
                             ),
                           ),
                        ],
                      ),
                    ),
                  ).toList(),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideX(
          begin: 0.3,
          end: 0,
          duration: const Duration(milliseconds: 400),
        );
  }

  void _startLesson(CourseModule module, String lesson) {
    if (selectedCourse == null) return;
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ModuleLessonScreen(
              moduleId: module.id,
              moduleTitle: module.title,
              courseTitle: selectedCourse!.title,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
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
        return Colors.blue;
    }
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    final count = _getFilterCount(filter);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.blue.withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.blue.withOpacity(0.8)
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Colors.white.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 