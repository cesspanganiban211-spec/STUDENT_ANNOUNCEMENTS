import 'package:flutter/material.dart';

void main() {
  runApp(const StudentAnnouncementsApp());
}

class StudentAnnouncementsApp extends StatelessWidget {
  const StudentAnnouncementsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Announcements',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ==================== DATA MODEL ====================

class Announcement {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime datePosted;
  final String postedBy;
  final bool isUrgent;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.datePosted,
    required this.postedBy,
    this.isUrgent = false,
  });
}

// ==================== HELPER FUNCTIONS ====================

String _formatDate(DateTime date) {
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final month = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  final year = date.year;
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$month $day, $year - $hour:$minute $period';
}

String _formatDateLong(DateTime date) {
  final days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];
  final months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final day = days[date.weekday - 1];
  final month = months[date.month - 1];
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$day, $month ${date.day}, ${date.year} - $hour:$minute $period';
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'event':
      return Colors.purple;
    case 'exam':
      return Colors.red;
    case 'assignment':
      return Colors.orange;
    case 'holiday':
      return Colors.green;
    case 'general':
    default:
      return Colors.blue;
  }
}

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'event':
      return Icons.event;
    case 'exam':
      return Icons.quiz;
    case 'assignment':
      return Icons.assignment;
    case 'holiday':
      return Icons.beach_access;
    case 'general':
    default:
      return Icons.campaign;
  }
}

// ==================== HOME SCREEN ====================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Midterm Examination Schedule',
      description:
          'The midterm examinations will begin on October 15th. Please check the detailed schedule on the student portal. All students are required to bring their student ID cards.',
      category: 'Exam',
      datePosted: DateTime.now().subtract(const Duration(hours: 2)),
      postedBy: 'Academic Office',
      isUrgent: true,
    ),
    Announcement(
      id: '2',
      title: 'Annual Science Fair 2026',
      description:
          'We are excited to announce the Annual Science Fair on November 5th. Students from all grades are invited to participate. Registration is now open.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(hours: 5)),
      postedBy: 'Science Department',
    ),
    Announcement(
      id: '3',
      title: 'Library Hours Extended',
      description:
          'The school library will now be open until 8 PM on weekdays to support students with their studies and research projects.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(days: 1)),
      postedBy: 'Library Staff',
    ),
    Announcement(
      id: '4',
      title: 'Math Assignment Due Date',
      description:
          'Reminder: The calculus assignment (Chapter 5) is due this Friday. Submit your work through the online portal before 11:59 PM.',
      category: 'Assignment',
      datePosted: DateTime.now().subtract(const Duration(days: 2)),
      postedBy: 'Prof. Johnson',
    ),
    Announcement(
      id: '5',
      title: 'Winter Break Schedule',
      description:
          'Winter break will start from December 20th and classes will resume on January 5th. Wishing everyone a safe and happy holiday!',
      category: 'Holiday',
      datePosted: DateTime.now().subtract(const Duration(days: 3)),
      postedBy: 'Administration',
    ),
    Announcement(
      id: '6',
      title: 'Student Council Elections - Vote Now!',
      description:
          'Annual Student Council elections are open until Friday, October 10th at 5 PM. Cast your vote through the student portal. Candidates for President, Vice President, and Treasurer will present their platforms at the Town Hall meeting on Wednesday, October 8th, 3:00 PM at the Main Auditorium.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(hours: 8)),
      postedBy: 'Student Affairs Office',
      isUrgent: true,
    ),
    Announcement(
      id: '7',
      title: 'Midterm Grades Released',
      description:
          'Midterm grades for all courses are now available on the student portal. Please review your grades and schedule office hours with your professors if you have concerns. The deadline to appeal grades is October 20th.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(hours: 12)),
      postedBy: 'Registrar\'s Office',
    ),
    Announcement(
      id: '8',
      title: 'Chemistry Lab Safety Training',
      description:
          'Mandatory safety training for all students enrolled in Chemistry 201 and 201L. Sessions will be held on October 6th and 7th, 10:00 AM - 12:00 PM in Science Building Room 302. Attendance is required to continue lab work. Bring your student ID and lab coat.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      postedBy: 'Chemistry Department',
      isUrgent: true,
    ),
    Announcement(
      id: '9',
      title: 'English Essay Submission Deadline',
      description:
          'Reminder: The final draft of your argumentative essay (minimum 1,500 words) is due this Thursday, October 9th, by 11:59 PM via the online submission portal. Late submissions will receive a 10% penalty per day. Cite sources in MLA format.',
      category: 'Assignment',
      datePosted: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      postedBy: 'Prof. Maria Santos',
    ),
    Announcement(
      id: '10',
      title: 'Campus Wi-Fi Maintenance',
      description:
          'The campus Wi-Fi network will be undergoing scheduled maintenance on Saturday, October 11th, from 2:00 AM to 6:00 AM. Internet access will be unavailable during this time. Plan accordingly for any online assignments or research.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(days: 2)),
      postedBy: 'IT Services',
    ),
    Announcement(
      id: '11',
      title: 'Basketball Tryouts - Varsity Team',
      description:
          'Tryouts for the Varsity Basketball team will be held on October 14th and 15th, 4:00 PM - 6:30 PM at the Main Gymnasium. All students with a valid physical exam form are eligible to try out. Wear appropriate athletic gear.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
      postedBy: 'Athletics Department',
    ),
    Announcement(
      id: '12',
      title: 'Tuition Payment Deadline - 2nd Installment',
      description:
          'The second installment of tuition fees for the Fall semester is due on October 15th. Payments can be made online through the student portal, at the Cashier\'s Office (Mon-Fri, 8 AM - 4 PM), or via bank transfer. Late payments will incur a 5% surcharge.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      postedBy: 'Finance Office',
      isUrgent: true,
    ),
    Announcement(
      id: '13',
      title: 'Halloween Costume Contest',
      description:
          'Get spooky! The annual Halloween Costume Contest will be held on October 31st at 6:00 PM in the Student Center. Prizes for Best Group Costume, Most Creative, and Scariest Costume. Registration is free - sign up at the Student Affairs Office by October 28th.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 4)),
      postedBy: 'Student Activities Board',
    ),
    Announcement(
      id: '14',
      title: 'Physics Quiz 3 - Coverage and Review',
      description:
          'Physics Quiz 3 will cover Chapters 7-9 (Thermodynamics and Heat Transfer). The quiz is scheduled for Tuesday, October 14th, during your regular class period. A review session will be held on Monday, October 13th, 3:00 PM in Room 204.',
      category: 'Exam',
      datePosted: DateTime.now().subtract(const Duration(days: 4, hours: 5)),
      postedBy: 'Dr. Robert Chen',
    ),
    Announcement(
      id: '15',
      title: 'Lost and Found - Student ID Cards',
      description:
          'Multiple student ID cards have been found near the Main Library and the Cafeteria. If you have lost your ID, please visit the Student Affairs Office (Room 101, Admin Building) with a valid government-issued ID to claim it. Unclaimed IDs will be deactivated after 30 days.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(days: 5)),
      postedBy: 'Student Affairs Office',
    ),
    Announcement(
      id: '16',
      title: 'Art Exhibition: "Perspectives"',
      description:
          'The Fine Arts Department presents "Perspectives," an exhibition featuring works by senior students. Opening reception on October 18th, 5:00 PM at the Campus Gallery. The exhibition runs until November 2nd. Refreshments will be served. Free admission for all students.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 5, hours: 3)),
      postedBy: 'Fine Arts Department',
    ),
    Announcement(
      id: '17',
      title: 'Math Tutoring Sessions - Free',
      description:
          'Free peer tutoring for Algebra, Calculus, and Statistics is available every Monday and Wednesday, 4:00 PM - 6:00 PM in the Math Learning Center (Room 112, Science Building). No registration needed - just drop in with your questions and materials.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(days: 6)),
      postedBy: 'Math Department',
    ),
    Announcement(
      id: '18',
      title: 'Final Project Group Formation',
      description:
          'Reminder for CS 301 students: Final project groups of 3-4 members must be formed and registered on the course portal by October 12th. Project proposals are due October 22nd. See the course syllabus for project guidelines and requirements.',
      category: 'Assignment',
      datePosted: DateTime.now().subtract(const Duration(days: 6, hours: 7)),
      postedBy: 'Prof. James Wilson',
    ),
    Announcement(
      id: '19',
      title: 'All Saints\' Day - No Classes',
      description:
          'There will be no classes on Monday, November 3rd in observance of All Saints\' Day. Offices will also be closed. Classes will resume on Tuesday, November 4th. Make sure to complete any pending assignments before the holiday.',
      category: 'Holiday',
      datePosted: DateTime.now().subtract(const Duration(days: 7)),
      postedBy: 'Administration',
    ),
    Announcement(
      id: '20',
      title: 'Blood Donation Drive',
      description:
          'The Red Cross, in partnership with our school, will hold a Blood Donation Drive on October 22nd, 9:00 AM - 3:00 PM at the School Clinic. Donors must be at least 18 years old, weigh at least 50kg, and bring a valid ID. Refreshments provided for all donors. Save a life - donate blood!',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 7, hours: 4)),
      postedBy: 'School Clinic & Red Cross',
    ),
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Event',
    'Exam',
    'Assignment',
    'Holiday',
    'General',
  ];

  List<Announcement> get _filteredAnnouncements {
    if (_selectedFilter == 'All') return _announcements;
    return _announcements.where((a) => a.category == _selectedFilter).toList();
  }

  void _navigateToCreateAnnouncement() async {
    final result = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(builder: (context) => const CreateAnnouncementScreen()),
    );
    if (result != null) {
      setState(() {
        _announcements.insert(0, result);
      });
    }
  }

  void _navigateToDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Announcements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _filteredAnnouncements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: _filteredAnnouncements.length,
                      itemBuilder: (context, index) {
                        final announcement = _filteredAnnouncements[index];
                        return _AnnouncementCard(
                          announcement: announcement,
                          onTap: () => _navigateToDetail(announcement),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateAnnouncement,
        icon: const Icon(Icons.add),
        label: const Text('New Announcement'),
      ),
    );
  }
}

// ==================== ANNOUNCEMENT CARD WIDGET ====================

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onTap;

  const _AnnouncementCard({required this.announcement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(announcement.category);
    final categoryIcon = _getCategoryIcon(announcement.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: categoryColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon, size: 14, color: categoryColor),
                        const SizedBox(width: 4),
                        Text(
                          announcement.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: categoryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (announcement.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                announcement.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                announcement.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    announcement.postedBy,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(announcement.datePosted),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== CREATE ANNOUNCEMENT SCREEN ====================

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postedByController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isUrgent = false;

  final List<String> _categories = ['General', 'Event', 'Exam', 'Assignment', 'Holiday'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _postedByController.dispose();
    super.dispose();
  }

  void _submitAnnouncement() {
    if (_formKey.currentState!.validate()) {
      final announcement = Announcement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        datePosted: DateTime.now(),
        postedBy: _postedByController.text.trim(),
        isUrgent: _isUrgent,
      );
      Navigator.pop(context, announcement);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Announcement created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter announcement title',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a title';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter announcement details',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postedByController,
                decoration: const InputDecoration(
                  labelText: 'Posted By',
                  hintText: 'Enter your name or department',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter the author name';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text('Mark as Urgent'),
                  subtitle: const Text('Urgent announcements will be highlighted'),
                  value: _isUrgent,
                  onChanged: (value) => setState(() => _isUrgent = value),
                  secondary: Icon(
                    Icons.priority_high,
                    color: _isUrgent ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitAnnouncement,
                  icon: const Icon(Icons.send),
                  label: const Text('Publish Announcement', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ANNOUNCEMENT DETAIL SCREEN ====================

class AnnouncementDetailScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(announcement.category);
    final categoryIcon = _getCategoryIcon(announcement.category);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(categoryIcon, color: categoryColor, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                announcement.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            if (announcement.isUrgent) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.priority_high, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'URGENT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    announcement.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline, size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text('Posted by ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                              Text(
                                announcement.postedBy,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatDateLong(announcement.datePosted),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    announcement.description,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Shared successfully!')),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved to bookmarks!')),
                            );
                          },
                          icon: const Icon(Icons.bookmark_border),
                          label: const Text('Save'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
