import 'dart:math' as math;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(StudentAnnouncementsApp(home: initialScreen()));
}

/// Deep links for the web build — `?screen=board`, `?screen=events`,
/// `?screen=detail` or `?screen=compose` open that screen directly, which is
/// handy for sharing a link and for grabbing screenshots of each screen.
Widget? initialScreen() {
  switch (Uri.base.queryParameters['screen']) {
    case 'events':
      // The diary itself — app bar, summary strip and bottom navigation.
      return const HomeScreen(initialTab: 1);
    case 'detail':
      return AnnouncementDetailScreen(
        announcement: Announcement(
          id: 'demo',
          title: 'Midterm Examination Schedule',
          description:
              'The midterm examinations will begin on October 15th. Please check the detailed schedule on the student portal. All students are required to bring their student ID cards.',
          category: 'Exam',
          datePosted: DateTime(2026, 10, 8, 9, 30),
          postedBy: 'Academic Office',
          isUrgent: true,
          eventDate: DateTime(2026, 10, 15, 8, 0),
          venue: 'Exam Hall, Main Building',
          expiresAt: DateTime(2026, 10, 16, 8, 0),
        ),
        onChanged: (_) {},
        onDeleted: () {},
      );
    case 'compose':
      return const CreateAnnouncementScreen();
    default:
      return null;
  }
}

// ==================== THEME / PALETTE ====================

abstract final class Palette {
  // Midnight-navy board: gradient top -> bottom (corkLight -> cork -> corkDark).
  static const Color cork = Color(0xFF12263F);
  static const Color corkDark = Color(0xFF0A1729);
  static const Color corkLight = Color(0xFF1D3B61);
  static const Color paper = Color(0xFFFCF6E7);
  static const Color ink = Color(0xFF2C2620);
  static const Color inkSoft = Color(0xFF7B6F61);
  static const Color walnut = Color(0xFF070F1C);
  static const Color stamp = Color(0xFFC1402C);
  static const Color gold = Color(0xFFE2A33B);
}

class StudentAnnouncementsApp extends StatelessWidget {
  const StudentAnnouncementsApp({super.key, this.home});

  /// Lets tests and previews jump straight to a screen with the app's theme.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHCC Student Announcements',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.stamp,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Palette.cork,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Palette.walnut,
          foregroundColor: Palette.paper,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Palette.walnut,
          contentTextStyle: TextStyle(color: Palette.paper, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.55),
          labelStyle: const TextStyle(color: Palette.inkSoft),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Palette.ink.withValues(alpha: 0.25)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Palette.ink.withValues(alpha: 0.25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Palette.stamp, width: 2),
          ),
        ),
      ),
      home: home ?? const HomeScreen(),
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

  /// When the announcement happens or is due (optional).
  final DateTime? eventDate;

  /// Where it happens — "Main Gymnasium", "Room 204"... (optional).
  final String? venue;

  /// Temporary notes take themselves off the board once this passes.
  final DateTime? expiresAt;

  /// Bookmarked by the student; survives restarts.
  final bool isSaved;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.datePosted,
    required this.postedBy,
    this.isUrgent = false,
    this.eventDate,
    this.venue,
    this.expiresAt,
    this.isSaved = false,
  });

  /// True when the note was pinned with a take-down time.
  bool get isTemporary => expiresAt != null;

  /// True once a temporary note's take-down time has passed.
  bool isExpired([DateTime? now]) {
    final expiry = expiresAt;
    return expiry != null && expiry.isBefore(now ?? DateTime.now());
  }

  Announcement copyWith({
    String? title,
    String? description,
    String? category,
    DateTime? datePosted,
    String? postedBy,
    bool? isUrgent,
    bool? isSaved,
    DateTime? eventDate,
    String? venue,
    DateTime? expiresAt,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      datePosted: datePosted ?? this.datePosted,
      postedBy: postedBy ?? this.postedBy,
      isUrgent: isUrgent ?? this.isUrgent,
      eventDate: eventDate ?? this.eventDate,
      venue: venue ?? this.venue,
      expiresAt: expiresAt ?? this.expiresAt,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'datePosted': datePosted.toIso8601String(),
        'postedBy': postedBy,
        'isUrgent': isUrgent,
        'eventDate': eventDate?.toIso8601String(),
        'venue': venue,
        'expiresAt': expiresAt?.toIso8601String(),
        'isSaved': isSaved,
      };

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final event = json['eventDate'] as String?;
    final expiry = json['expiresAt'] as String?;
    return Announcement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      datePosted: DateTime.parse(json['datePosted'] as String),
      postedBy: json['postedBy'] as String,
      isUrgent: json['isUrgent'] as bool? ?? false,
      eventDate: event == null ? null : DateTime.parse(event),
      venue: json['venue'] as String?,
      expiresAt: expiry == null ? null : DateTime.parse(expiry),
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
}

// ==================== HELPERS ====================

({Color color, IconData icon}) categoryStyle(String category) {
  switch (category.toLowerCase()) {
    case 'event':
      return (color: const Color(0xFF7E5A9B), icon: Icons.event);
    case 'exam':
      return (color: const Color(0xFFB8412F), icon: Icons.quiz);
    case 'assignment':
      return (color: const Color(0xFFD0872B), icon: Icons.assignment);
    case 'holiday':
      return (color: const Color(0xFF4E8A5B), icon: Icons.beach_access);
    case 'general':
    default:
      return (color: const Color(0xFF2E7C8C), icon: Icons.campaign);
  }
}

Color categoryColor(String category) => categoryStyle(category).color;

/// Each note gets a tiny, deterministic tilt so the board looks hand-pinned.
double tiltFor(String id) {
  final slot = (id.hashCode % 7).abs() - 3; // -3..3
  return slot * 0.0055; // about +/- 0.95 degrees
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$month $day, ${date.year} - $hour:$minute $period';
}

String formatDateLong(DateTime date) {
  const days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final day = days[date.weekday - 1];
  final month = months[date.month - 1];
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$day, $month ${date.day}, ${date.year} - $hour:$minute $period';
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(date);
}

/// Short, date-only stamp: "Oct 15, 2026".
String shortDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

/// A date [days] away from today, at a given clock time (for sample data).
DateTime daysFromNow(int days, {int hour = 9, int minute = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days, hour, minute);
}

/// How far away [when] is, counted by calendar days: label + day count.
({int days, String label}) whenInfo(DateTime when) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(when.year, when.month, when.day);
  final days = target.difference(today).inDays;

  final String label;
  if (days == 0) {
    label = when.hour == 0 && when.minute == 0
        ? 'Today'
        : 'Today \u00b7 ${_clock(when)}';
  } else if (days == 1) {
    label = 'Tomorrow \u00b7 ${_clock(when)}';
  } else if (days == -1) {
    label = 'Yesterday';
  } else if (days > 1) {
    label = 'In $days days';
  } else {
    label = '${-days} days ago';
  }
  return (days: days, label: label);
}

String _clock(DateTime date) {
  final hour =
      date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

/// Countdown pill colours: overdue = grey, soon = red, this week = amber.
Color whenColor(int days) {
  if (days < 0) return Palette.inkSoft;
  if (days <= 2) return Palette.stamp;
  if (days <= 7) return const Color(0xFFD0872B);
  return const Color(0xFF4E8A5B);
}

/// Calendar-chip pieces for a date: month stamp, day number, weekday stamp.
({String month, String day, String weekday}) eventChip(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return (
    month: months[date.month - 1],
    day: date.day.toString(),
    weekday: days[date.weekday - 1],
  );
}

String boardDate(DateTime date) {
  const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${days[date.weekday % 7]}, ${months[date.month - 1]} ${date.day}';
}

// ==================== PAINTERS ====================

/// Hand-scattered cork texture for the board background.
class CorkboardPainter extends CustomPainter {
  const CorkboardPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    // Deep navy wash, lit from the top of the board.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Palette.corkLight, Palette.cork, Palette.corkDark],
          stops: [0, 0.5, 1],
        ).createShader(bounds),
    );

    final random = math.Random(20261008);
    final dark = Paint()
      ..color = Palette.corkDark.withValues(alpha: 0.55)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;
    final light = Paint()
      ..color = Palette.corkLight.withValues(alpha: 0.55)
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    const speckles = 1100;
    for (var i = 0; i < speckles; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final angle = random.nextDouble() * math.pi;
      final length = 3 + random.nextDouble() * 7;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + math.cos(angle) * length, y + math.sin(angle) * length),
        random.nextBool() ? dark : light,
      );
    }

    // Soft vignette so the middle of the board feels lit.
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.black.withValues(alpha: 0.22),
        ],
        stops: const [0.45, 1],
      ).createShader(bounds);
    canvas.drawRect(bounds, vignette);
  }

  @override
  bool shouldRepaint(covariant CorkboardPainter oldDelegate) => false;
}

/// Little triangle bunting hanging under the app bar.
class BuntingPainter extends CustomPainter {
  const BuntingPainter();

  static const List<Color> _flagColors = [
    Color(0xFFE4572E),
    Color(0xFFF3A712),
    Color(0xFF43AA8B),
    Color(0xFF5B8DEF),
    Color(0xFFB15CE6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const p0 = Offset(0, 3);
    final p1 = Offset(size.width / 2, 17);
    final p2 = Offset(size.width, 3);

    canvas.drawPath(
      Path()
        ..moveTo(p0.dx, p0.dy)
        ..quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const flagCount = 14;
    final fill = Paint();
    for (var i = 0; i < flagCount; i++) {
      final t = (i + 0.5) / flagCount;
      final a = (1 - t) * (1 - t);
      final b = 2 * (1 - t) * t;
      final c = t * t;
      final point = Offset(
        a * p0.dx + b * p1.dx + c * p2.dx,
        a * p0.dy + b * p1.dy + c * p2.dy,
      );
      final tangent = Offset(
        2 * (1 - t) * (p1.dx - p0.dx) + 2 * t * (p2.dx - p1.dx),
        2 * (1 - t) * (p1.dy - p0.dy) + 2 * t * (p2.dy - p1.dy),
      );
      final normal = Offset(-tangent.dy, tangent.dx) / tangent.distance;
      final left = point + normal * 8;
      final right = point - normal * 8;
      final bottom = point + const Offset(0, 17);

      final flag = Path()
        ..moveTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..lineTo(bottom.dx, bottom.dy)
        ..close();
      fill.color = _flagColors[i % _flagColors.length];
      canvas.drawPath(flag, fill);
    }
  }

  @override
  bool shouldRepaint(covariant BuntingPainter oldDelegate) => false;
}

/// Wavy, hand-drawn underline used on the detail sheet.
class SquigglePainter extends CustomPainter {
  const SquigglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height / 2);
    var x = 0.0;
    var up = true;
    while (x < size.width) {
      final next = math.min(size.width, x + 14);
      path.quadraticBezierTo(
        x + 7,
        up ? 0 : size.height,
        next,
        size.height / 2,
      );
      x = next;
      up = !up;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant SquigglePainter old) => old.color != color;
}

/// Paper note silhouette with a torn bottom edge (shadow follows the shape).
class DeckleClipper extends CustomClipper<Path> {
  const DeckleClipper({this.depth = 8, this.step = 16});

  final double depth;
  final double step;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height);

    var x = size.width;
    var up = true;
    while (x > 0) {
      final next = math.max(0.0, x - step);
      path.lineTo(next, up ? size.height - depth : size.height);
      up = !up;
      x = next;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant DeckleClipper oldClip) => false;
}

// ==================== SHARED BITS ====================

/// The strip of coloured tape that doubles as the category label.
Widget categoryTape(String category, {double angle = -0.03}) {
  final style = categoryStyle(category);
  return Transform.rotate(
    angle: angle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Rubber-stamped "urgent" mark, slightly askew.
Widget urgentStamp({double angle = -0.11, double fontSize = 12}) {
  return Transform.rotate(
    angle: angle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: Palette.stamp, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: Palette.stamp.withValues(alpha: 0.07),
      ),
      child: Text(
        'URGENT',
        style: TextStyle(
          color: Palette.stamp,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
      ),
    ),
  );
}

/// The take-down choices offered for a temporary note.
const List<String> temporarySpans = [
  'After the event',
  'In 24 hours',
  'In 3 days',
  'In 7 days',
  'In 30 days',
];

/// When a temporary note pinned with [span] takes itself down.
///
/// "After the event" hangs around for a day after [event]; the other spans
/// are counted from [now] — the moment the note is pinned.
DateTime expiryFor(String span, {DateTime? event, DateTime? now}) {
  final from = now ?? DateTime.now();
  switch (span) {
    case 'In 24 hours':
      return from.add(const Duration(hours: 24));
    case 'In 3 days':
      return from.add(const Duration(days: 3));
    case 'In 7 days':
      return from.add(const Duration(days: 7));
    case 'In 30 days':
      return from.add(const Duration(days: 30));
    default:
      return (event ?? from).add(const Duration(days: 1));
  }
}

/// Finds the span that best matches an existing expiry (used when editing).
String spanForExpiry(DateTime expiresAt, {DateTime? event, DateTime? now}) {
  // Without an event date there is nothing to hang "After the event" on.
  final candidates = event == null
      ? temporarySpans.where((span) => span != temporarySpans.first).toList()
      : temporarySpans;

  var best = candidates.first;
  var bestGap = -1;
  for (final span in candidates) {
    final gap =
        expiryFor(span, event: event, now: now).difference(expiresAt).abs();
    if (bestGap < 0 || gap.inSeconds < bestGap) {
      best = span;
      bestGap = gap.inSeconds;
    }
  }
  return best;
}

/// Amber "takes itself down" tag, shown wherever a temporary note appears.
class ExpiryPill extends StatelessWidget {
  const ExpiryPill({super.key, required this.expiresAt});

  final DateTime expiresAt;

  @override
  Widget build(BuildContext context) {
    final info = whenInfo(expiresAt);
    final color = info.days <= 1 ? Palette.stamp : const Color(0xFFD0872B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hourglass_top, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            'TAKES ITSELF DOWN \u00b7 ${info.label}',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HOME SCREEN ====================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialTab = 0});

  /// Which bottom tab to open on — `?screen=events` jumps straight to the
  /// diary (handy for sharing a link and for screenshots).
  final int initialTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _loadNotes();
  }

  /// Reloads the board after a restart (falls back to the seeded board).
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('notes');
      if (raw == null) return;
      final stored = (jsonDecode(raw) as List)
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
      // Temporary notes that ran out are wiped for good.
      final alive = stored.where((a) => !a.isExpired()).toList();
      if (mounted) setState(() => _announcements = alive);
      if (alive.length != stored.length) _persistNotes();
    } catch (_) {
      // Storage unavailable (tests, web without storage) - keep the seeds.
    }
  }

  Future<void> _persistNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'notes',
        jsonEncode(_announcements.map((a) => a.toJson()).toList()),
      );
    } catch (_) {
      // Nothing we can do about a failed write; the app keeps working.
    }
  }

  List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'Midterm Examination Schedule',
      description:
          'The midterm examinations will begin on October 15th. Please check the detailed schedule on the student portal. All students are required to bring their student ID cards.',
      category: 'Exam',
      datePosted: DateTime.now().subtract(const Duration(hours: 2)),
      postedBy: 'Academic Office',
      isUrgent: true,
      eventDate: daysFromNow(5, hour: 8),
    ),
    Announcement(
      id: '2',
      title: 'Annual Science Fair 2026',
      description:
          'We are excited to announce the Annual Science Fair on November 5th. Students from all grades are invited to participate. Registration is now open.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(hours: 5)),
      postedBy: 'Science Department',
      venue: 'CHCC Gymnasium',
      eventDate: daysFromNow(12, hour: 8),
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
      eventDate: daysFromNow(2, hour: 23, minute: 59),
    ),
    Announcement(
      id: '5',
      title: 'Winter Break Schedule',
      description:
          'Winter break will start from December 20th and classes will resume on January 5th. Wishing everyone a safe and happy holiday!',
      category: 'Holiday',
      datePosted: DateTime.now().subtract(const Duration(days: 3)),
      postedBy: 'Administration',
      eventDate: daysFromNow(30, hour: 8),
    ),
    Announcement(
      id: '6',
      title: 'Student Council Elections - Vote Now!',
      description:
          'Annual Student Council elections are open until Friday, October 10th at 5 PM. Cast your vote through the student portal. Candidates for President, Vice President, and Treasurer will present their platforms at the Town Hall meeting on Wednesday, October 8th, 3:00 PM at the Main Auditorium.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(hours: 8)),
      postedBy: 'Student Affairs Office',
      venue: 'Main Auditorium',
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
      eventDate: DateTime(2026, 10, 20),
    ),
    Announcement(
      id: '8',
      title: 'Chemistry Lab Safety Training',
      description:
          'Mandatory safety training for all students enrolled in Chemistry 201 and 201L. Sessions will be held on October 6th and 7th, 10:00 AM - 12:00 PM in Science Building Room 302. Attendance is required to continue lab work. Bring your student ID and lab coat.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      postedBy: 'Chemistry Department',
      venue: 'Science Building, Room 302',
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
      venue: 'Main Gymnasium',
      eventDate: DateTime(2026, 10, 14, 16),
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
      eventDate: DateTime(2026, 10, 15),
    ),
    Announcement(
      id: '13',
      title: 'Halloween Costume Contest',
      description:
          'Get spooky! The annual Halloween Costume Contest will be held on October 31st at 6:00 PM in the Student Center. Prizes for Best Group Costume, Most Creative, and Scariest Costume. Registration is free - sign up at the Student Affairs Office by October 28th.',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 4)),
      postedBy: 'Student Activities Board',
      venue: 'Student Center',
      eventDate: DateTime(2026, 10, 31, 18),
      // Temporary note: a day after the contest, it takes itself down.
      expiresAt: DateTime(2026, 11, 1, 18),
    ),
    Announcement(
      id: '14',
      title: 'Physics Quiz 3 - Coverage and Review',
      description:
          'Physics Quiz 3 will cover Chapters 7-9 (Thermodynamics and Heat Transfer). The quiz is scheduled for Tuesday, October 14th, during your regular class period. A review session will be held on Monday, October 13th, 3:00 PM in Room 204.',
      category: 'Exam',
      datePosted: DateTime.now().subtract(const Duration(days: 4, hours: 5)),
      postedBy: 'Dr. Robert Chen',
      venue: 'Room 204',
      eventDate: DateTime(2026, 10, 14, 8),
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
      venue: 'Campus Gallery',
      eventDate: DateTime(2026, 10, 18, 17),
    ),
    Announcement(
      id: '17',
      title: 'Math Tutoring Sessions - Free',
      description:
          'Free peer tutoring for Algebra, Calculus, and Statistics is available every Monday and Wednesday, 4:00 PM - 6:00 PM in the Math Learning Center (Room 112, Science Building). No registration needed - just drop in with your questions and materials.',
      category: 'General',
      datePosted: DateTime.now().subtract(const Duration(days: 6)),
      postedBy: 'Math Department',
      venue: 'Math Learning Center, Room 112',
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
      eventDate: DateTime(2026, 11, 3),
    ),
    Announcement(
      id: '20',
      title: 'Blood Donation Drive',
      description:
          'The Red Cross, in partnership with our school, will hold a Blood Donation Drive on October 22nd, 9:00 AM - 3:00 PM at the School Clinic. Donors must be at least 18 years old, weigh at least 50kg, and bring a valid ID. Refreshments provided for all donors. Save a life - donate blood!',
      category: 'Event',
      datePosted: DateTime.now().subtract(const Duration(days: 7, hours: 4)),
      postedBy: 'School Clinic & Red Cross',
      venue: 'School Clinic',
      eventDate: DateTime(2026, 10, 22, 9),
    ),
  ];

  String _selectedFilter = 'All';
  String _query = '';
  bool _searching = false;
  bool _savedOnly = false;

  /// Which bottom tab is showing: 0 = the board, 1 = the events page.
  int _tab = 0;

  final List<String> _filters = const [
    'All',
    'Event',
    'Exam',
    'Assignment',
    'Holiday',
    'General',
  ];

  /// Notes still standing — temporary ones are dropped once their take-down
  /// time passes, so the board never shows a stale temporary note.
  List<Announcement> get _active =>
      _announcements.where((a) => !a.isExpired()).toList();

  int get _savedCount => _active.where((a) => a.isSaved).length;

  String get _emptyMessage {
    if (_query.trim().isNotEmpty) {
      return 'No notes match "${_query.trim()}"';
    }
    if (_savedOnly) return 'Nothing saved yet \u2014 tap Save on a note first.';
    return 'No "$_selectedFilter" notes on the board right now.';
  }

  List<Announcement> get _filteredAnnouncements {
    Iterable<Announcement> list = _active;
    if (_selectedFilter != 'All') {
      list = list.where((a) => a.category == _selectedFilter);
    }
    if (_savedOnly) list = list.where((a) => a.isSaved);
    final query = _query.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where(
        (a) =>
            a.title.toLowerCase().contains(query) ||
            a.description.toLowerCase().contains(query) ||
            a.postedBy.toLowerCase().contains(query),
      );
    }
    return list.toList();
  }

  /// Asks first, then unpins with a snack bar that can undo the removal.
  Future<bool> _confirmDelete(Announcement announcement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.paper,
        title: const Text('Unpin this note?'),
        content: Text(
          '"${announcement.title}" will be taken off the board.',
          style: const TextStyle(color: Palette.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Unpin',
              style: TextStyle(
                color: Palette.stamp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _deleteAnnouncement(Announcement announcement) {
    final index = _announcements.indexWhere((a) => a.id == announcement.id);
    if (index == -1) return;
    setState(() => _announcements.removeAt(index));
    _persistNotes();

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Unpinned "${announcement.title}"'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: const Color(0xFFF3A712),
            onPressed: () {
              if (!mounted) return;
              setState(() {
                _announcements.insert(
                  index > _announcements.length ? _announcements.length : index,
                  announcement,
                );
              });
              _persistNotes();
            },
          ),
        ),
      );
  }

  void _updateAnnouncement(Announcement updated) {
    final index = _announcements.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    setState(() => _announcements[index] = updated);
    _persistNotes();
  }

  void _navigateToCreateAnnouncement(
      {Announcement? initial, String? presetCategory}) async {
    final result = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAnnouncementScreen(
          initial: initial,
          presetCategory: presetCategory,
        ),
      ),
    );
    if (result == null) return;
    if (initial == null) {
      setState(() => _announcements.insert(0, result));
    } else {
      final index = _announcements.indexWhere((a) => a.id == result.id);
      if (index != -1) setState(() => _announcements[index] = result);
    }
    _persistNotes();
  }

  void _navigateToDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(
          announcement: announcement,
          onChanged: _updateAnnouncement,
          onDeleted: () => _deleteAnnouncement(announcement),
        ),
      ),
    );
  }

  Color _filterColor(String filter) =>
      filter == 'All' ? Palette.gold : categoryColor(filter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.cork,
      appBar: AppBar(
        // The official seal of Concepcion Holy Cross College, Inc.
        leading: Center(
          child: Container(
            key: const ValueKey('chcc-crest'),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Palette.paper, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/chcc_seal.jpg',
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CONCEPCION HOLY CROSS COLLEGE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: Palette.paper.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'STUDENT ANNOUNCEMENTS',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.4,
                color: Palette.paper,
              ),
            ),
            const SizedBox(height: 4),
            // Painted swash under the wordmark.
            Container(
              height: 3,
              width: 82,
              decoration: BoxDecoration(
                color: Palette.gold,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_active.length} notes pinned \u00b7 $_savedCount saved \u00b7 ${boardDate(DateTime.now())}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: Palette.paper.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
        actions: _tab == 0
            ? [
                IconButton(
                  tooltip:
                      _savedOnly ? 'Show every note' : 'Show saved notes only',
                  onPressed: () => setState(() => _savedOnly = !_savedOnly),
                  icon: Icon(
                    _savedOnly ? Icons.bookmark : Icons.bookmark_border,
                    color: _savedOnly ? const Color(0xFFF3A712) : Palette.paper,
                  ),
                ),
                IconButton(
                  tooltip: _searching ? 'Close search' : 'Search notes',
                  onPressed: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) _query = '';
                  }),
                  icon: Icon(_searching ? Icons.close : Icons.search),
                ),
              ]
            : null,
      ),
      body: _tab == 0
          ? Stack(
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: CorkboardPainter()),
                ),
                Column(
                  children: [
                    // Bunting hanging off the top of the board.
                    const SizedBox(
                      height: 40,
                      child: CustomPaint(
                        size: Size(double.infinity, 40),
                        painter: BuntingPainter(),
                      ),
                    ),
                    // Search slips down from the app bar.
                    if (_searching)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
                        child: TextField(
                          autofocus: true,
                          onChanged: (value) => setState(() => _query = value),
                          style:
                              const TextStyle(color: Palette.ink, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search title, details or who posted it',
                            prefixIcon: const Icon(Icons.search,
                                color: Palette.inkSoft),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Palette.inkSoft),
                                    onPressed: () =>
                                        setState(() => _query = ''),
                                  ),
                            filled: true,
                            fillColor: Palette.paper,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Palette.ink.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Washi-tape filter tabs.
                    SizedBox(
                      height: 58,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        children: [
                          for (var i = 0; i < _filters.length; i++)
                            _TapeTab(
                              key: ValueKey(_filters[i]),
                              label: _filters[i],
                              color: _filterColor(_filters[i]),
                              selected: _selectedFilter == _filters[i],
                              angle: i.isEven ? -0.035 : 0.03,
                              onTap: () =>
                                  setState(() => _selectedFilter = _filters[i]),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _filteredAnnouncements.isEmpty
                          ? _EmptyBoard(message: _emptyMessage)
                          : RefreshIndicator(
                              color: Palette.stamp,
                              backgroundColor: Palette.paper,
                              onRefresh: () async {
                                setState(() {});
                              },
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 96),
                                itemCount: _filteredAnnouncements.length,
                                itemBuilder: (context, index) {
                                  final announcement =
                                      _filteredAnnouncements[index];
                                  return Dismissible(
                                    key: ValueKey(announcement.id),
                                    direction: DismissDirection.endToStart,
                                    confirmDismiss: (_) =>
                                        _confirmDelete(announcement),
                                    onDismissed: (_) =>
                                        _deleteAnnouncement(announcement),
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 34),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 9),
                                      decoration: BoxDecoration(
                                        color: Palette.stamp,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.delete_outline,
                                              color: Colors.white),
                                          SizedBox(height: 4),
                                          Text(
                                            'UNPIN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: _AnnouncementCard(
                                      key: ValueKey(
                                          '${_selectedFilter}_${announcement.id}'),
                                      announcement: announcement,
                                      index: index,
                                      onTap: () =>
                                          _navigateToDetail(announcement),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            )
          : EventsScreen(
              announcements: _active,
              onChanged: _updateAnnouncement,
              onDeleted: _deleteAnnouncement,
            ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateAnnouncement,
              backgroundColor: Palette.stamp,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: const Icon(Icons.push_pin_outlined),
              label: const Text(
                'Pin a note',
                style:
                    TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () =>
                  _navigateToCreateAnnouncement(presetCategory: 'Event'),
              backgroundColor: Palette.stamp,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: const Icon(Icons.event_available),
              label: const Text(
                'Add an event',
                style:
                    TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.4),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (index) => setState(() => _tab = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Palette.walnut,
        selectedItemColor: Palette.gold,
        unselectedItemColor: Palette.paper.withValues(alpha: 0.62),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
        ],
      ),
    );
  }
}

// ==================== TAPE TAB ====================

class _TapeTab extends StatelessWidget {
  const _TapeTab({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.angle,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final double angle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tapeColor = selected ? color : color.withValues(alpha: 0.78);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Transform.rotate(
        angle: angle,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: tapeColor,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: selected ? 0.28 : 0.14),
                    blurRadius: selected ? 5 : 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 1.4,
                  color: selected ? Colors.white : Palette.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleStrip extends StatelessWidget {
  const _ScheduleStrip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final info = whenInfo(date);
    final color = whenColor(info.days);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              formatDate(date),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Palette.ink,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              info.label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== EMPTY STATE ====================

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.02,
        child: Container(
          width: 240,
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          decoration: BoxDecoration(
            color: Palette.paper.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/chcc_seal.jpg',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nothing pinned here',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Palette.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Palette.inkSoft),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== ANNOUNCEMENT CARD (A PINNED NOTE) ====================

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    super.key,
    required this.announcement,
    required this.index,
    this.onTap,
  });

  final Announcement announcement;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(announcement.category);

    // Staggered entrance: each note drops onto the board a beat after the last.
    final delay = (index * 0.09).clamp(0.0, 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Interval(delay, 1, curve: Curves.easeOutCubic),
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - t)),
            child: child,
          ),
        ),
        child: Transform.rotate(
          angle: tiltFor(announcement.id),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PhysicalShape(
                clipper: const DeckleClipper(),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.45),
                color: Palette.paper,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    highlightColor: style.color.withValues(alpha: 0.12),
                    splashColor: style.color.withValues(alpha: 0.2),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (announcement.isUrgent ||
                              announcement.isSaved) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (announcement.isSaved) ...[
                                  const Icon(
                                    Icons.bookmark,
                                    size: 18,
                                    color: Color(0xFFF3A712),
                                  ),
                                  if (announcement.isUrgent)
                                    const SizedBox(width: 10),
                                ],
                                if (announcement.isUrgent) urgentStamp(),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                          Text(
                            announcement.title,
                            style: const TextStyle(
                              fontSize: 19,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: Palette.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            announcement.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Palette.inkSoft,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (announcement.venue != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 15,
                                  color: Palette.inkSoft,
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    announcement.venue!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Palette.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (announcement.eventDate != null) ...[
                            const SizedBox(height: 14),
                            _ScheduleStrip(date: announcement.eventDate!),
                          ],
                          if (announcement.isTemporary) ...[
                            const SizedBox(height: 10),
                            ExpiryPill(expiresAt: announcement.expiresAt!),
                          ],
                          const SizedBox(height: 16),
                          Container(
                              height: 1,
                              color: Palette.ink.withValues(alpha: 0.12)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Palette.inkSoft,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  announcement.postedBy,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Palette.ink,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.watch_later_outlined,
                                size: 14,
                                color: Palette.inkSoft,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                timeAgo(announcement.datePosted),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Palette.inkSoft,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Posted on ${formatDate(announcement.datePosted)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Palette.inkSoft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Category tape holding the note to the board.
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Center(child: categoryTape(announcement.category)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== UPCOMING EVENTS SCREEN ====================

/// The campus diary: every dated note, soonest first, with its venue.
class EventsScreen extends StatefulWidget {
  const EventsScreen({
    super.key,
    required this.announcements,
    required this.onChanged,
    required this.onDeleted,
  });

  /// The whole board — this page picks out the dated notes.
  final List<Announcement> announcements;

  /// Keeps the board in sync with edits made from a note's sheet.
  final ValueChanged<Announcement> onChanged;

  /// Takes a note off the board.
  final void Function(Announcement announcement) onDeleted;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  /// false = what is coming up, true = what has already happened.
  bool _showPast = false;

  /// Dated notes only, split by side of today and sorted by date.
  List<Announcement> get _events {
    final now = DateTime.now();
    final dated = widget.announcements
        .where((a) => a.eventDate != null && !a.isExpired());

    final list = _showPast
        ? dated.where((a) => a.eventDate!.isBefore(now))
        : dated.where((a) => !a.eventDate!.isBefore(now));

    return list.toList()
      ..sort((a, b) => _showPast
          ? b.eventDate!.compareTo(a.eventDate!)
          : a.eventDate!.compareTo(b.eventDate!));
  }

  void _open(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(
          announcement: announcement,
          onChanged: widget.onChanged,
          onDeleted: () => widget.onDeleted(announcement),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    final now = DateTime.now();
    final week = now.add(const Duration(days: 7));
    final dated = widget.announcements
        .where((a) => a.eventDate != null && !a.isExpired());

    final upcoming = dated.where((a) => a.eventDate!.isAfter(now)).length;
    final soon = dated
        .where((a) => a.eventDate!.isAfter(now) && !a.eventDate!.isAfter(week))
        .length;
    final temporary = widget.announcements
        .where((a) => a.isTemporary && !a.isExpired())
        .length;
    final past = dated.where((a) => a.eventDate!.isBefore(now)).length;

    return Stack(
      children: [
        const Positioned.fill(
          child: CustomPaint(painter: CorkboardPainter()),
        ),
        Column(
          children: [
            // At-a-glance summary of the whole diary.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'UPCOMING',
                      value: upcoming,
                      color: Palette.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatBox(
                      label: '7 DAYS',
                      value: soon,
                      color: const Color(0xFFD0872B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatBox(
                      label: 'TEMPORARY',
                      value: temporary,
                      color: const Color(0xFF7E5A9B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatBox(
                      label: 'PAST',
                      value: past,
                      color: const Color(0xFF4E8A5B),
                    ),
                  ),
                ],
              ),
            ),
            // Tape tabs, same cut as the board's category tabs.
            SizedBox(
              height: 58,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _TapeTab(
                    key: const ValueKey('events-upcoming'),
                    label: 'Upcoming',
                    color: Palette.gold,
                    selected: !_showPast,
                    angle: -0.035,
                    onTap: () => setState(() => _showPast = false),
                  ),
                  _TapeTab(
                    key: const ValueKey('events-past'),
                    label: 'Past',
                    color: const Color(0xFF7E5A9B),
                    selected: _showPast,
                    angle: 0.03,
                    onTap: () => setState(() => _showPast = true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 6),
              child: Text(
                _showPast
                    ? '${events.length} already happened \u00b7 latest first'
                    : '${events.length} coming up \u00b7 soonest first',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: Palette.paper.withValues(alpha: 0.75),
                ),
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? _EmptyBoard(
                      message: _showPast
                          ? 'Nothing has happened on the diary yet.'
                          : 'No upcoming events — pin one with the button below.')
                  : RefreshIndicator(
                      color: Palette.stamp,
                      backgroundColor: Palette.paper,
                      onRefresh: () async => setState(() {}),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 96),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final announcement = events[index];
                          return _EventCard(
                            key: ValueKey('event_${announcement.id}'),
                            announcement: announcement,
                            index: index,
                            onTap: () => _open(announcement),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One number on the diary's at-a-glance summary strip.
class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      decoration: BoxDecoration(
        color: Palette.walnut.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: Palette.paper.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dated note as a diary card: calendar chip, venue, date strip.
class _EventCard extends StatelessWidget {
  const _EventCard({
    super.key,
    required this.announcement,
    required this.index,
    required this.onTap,
  });

  final Announcement announcement;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyle(announcement.category);
    final when = announcement.eventDate!;
    final chip = eventChip(when);

    // Same staggered drop-in as the board's notes.
    final delay = (index * 0.09).clamp(0.0, 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 650),
        curve: Interval(delay, 1, curve: Curves.easeOutCubic),
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 26 * (1 - t)),
            child: child,
          ),
        ),
        child: PhysicalShape(
          clipper: const DeckleClipper(),
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.45),
          color: Palette.paper,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              highlightColor: style.color.withValues(alpha: 0.12),
              splashColor: style.color.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar chip: month, day, weekday.
                        Container(
                          width: 58,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: style.color,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                chip.month,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              Text(
                                chip.day,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                chip.weekday,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.25,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.ink,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 15,
                                    color: Palette.inkSoft,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      announcement.venue ??
                                          'Venue to be announced',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Palette.inkSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Palette.inkSoft,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ScheduleStrip(date: when),
                    if (announcement.isTemporary) ...[
                      const SizedBox(height: 10),
                      ExpiryPill(expiresAt: announcement.expiresAt!),
                    ],
                    const SizedBox(height: 14),
                    Container(
                        height: 1, color: Palette.ink.withValues(alpha: 0.12)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Palette.inkSoft,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            announcement.postedBy,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Palette.ink,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeAgo(announcement.datePosted),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Palette.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== CREATE ANNOUNCEMENT SCREEN ====================

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({
    super.key,
    this.initial,
    this.presetCategory,
  });

  /// When set, the form opens pre-filled so the note can be edited.
  final Announcement? initial;

  /// Category to start with — the events page passes "Event".
  final String? presetCategory;

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _postedByController = TextEditingController();
  final _venueController = TextEditingController();
  String _selectedCategory = 'General';
  bool _isUrgent = false;
  DateTime? _eventDate;
  TimeOfDay _eventTime = const TimeOfDay(hour: 9, minute: 0);

  /// Temporary notes take themselves down; [_tempSpan] says when.
  bool _temporary = false;
  String _tempSpan = temporarySpans.first;

  final List<String> _categories = const [
    'General',
    'Event',
    'Exam',
    'Assignment',
    'Holiday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.presetCategory ?? 'General';
    final note = widget.initial;
    if (note == null) return;
    _titleController.text = note.title;
    _descriptionController.text = note.description;
    _postedByController.text = note.postedBy;
    _venueController.text = note.venue ?? '';
    _selectedCategory = note.category;
    _isUrgent = note.isUrgent;
    _temporary = note.isTemporary;
    if (note.isTemporary) {
      _tempSpan = spanForExpiry(
        note.expiresAt!,
        event: note.eventDate,
        now: note.datePosted,
      );
    }
    final event = note.eventDate;
    if (event != null) {
      _eventDate = DateTime(event.year, event.month, event.day);
      _eventTime = TimeOfDay(hour: event.hour, minute: event.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _postedByController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  /// The date and time picked above, as one stamp (or null).
  DateTime? _eventDateTime() => _eventDate == null
      ? null
      : DateTime(
          _eventDate!.year,
          _eventDate!.month,
          _eventDate!.day,
          _eventTime.hour,
          _eventTime.minute,
        );

  /// When this note should take itself down, or null to keep it for good.
  DateTime? _buildExpiry() => _temporary
      ? expiryFor(_tempSpan, event: _eventDateTime(), now: DateTime.now())
      : null;

  /// Plain-English preview of when the note would take itself down.
  String _temporaryNote() {
    final event = _eventDateTime();
    if (_tempSpan == temporarySpans.first && event == null) {
      return 'Pick a date above so it can go down after the event.';
    }
    return 'Takes itself down ${formatDate(expiryFor(_tempSpan, event: event))}';
  }

  Future<void> _pickEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _eventDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _pickEventTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _eventTime,
    );
    if (picked != null) {
      setState(() => _eventTime = picked);
    }
  }

  void _submitAnnouncement() {
    if (!_formKey.currentState!.validate()) return;

    final venue = _venueController.text.trim();
    final event = _eventDateTime();

    // "After the event" needs an event to hang on.
    if (_temporary && _tempSpan == temporarySpans.first && event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pick a date above \u2014 or choose how long the note should live.',
          ),
        ),
      );
      return;
    }

    final existing = widget.initial;
    final announcement = Announcement(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      datePosted: existing?.datePosted ?? DateTime.now(),
      postedBy: _postedByController.text.trim(),
      isUrgent: _isUrgent,
      isSaved: existing?.isSaved ?? false,
      eventDate: event,
      venue: venue.isEmpty ? null : venue,
      expiresAt: _buildExpiry(),
    );
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, announcement);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'Your note is pinned to the board!'
              : 'Changes saved!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.cork,
      appBar: AppBar(
        title: Text(widget.initial == null ? 'PIN A NEW NOTE' : 'EDIT NOTE'),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
              child: CustomPaint(painter: CorkboardPainter())),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                PhysicalShape(
                  clipper: const DeckleClipper(),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.45),
                  color: Palette.paper,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 30, 22, 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.initial == null
                                ? 'Fresh off the press'
                                : 'Touching up an existing note',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: Palette.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                              hintText: 'What is this about?',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategory = value!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              hintText: 'Write the details of your note',
                              prefixIcon: Icon(Icons.description),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a description';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _postedByController,
                            decoration: const InputDecoration(
                              labelText: 'Posted By',
                              hintText: 'Your name or department',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the author name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _venueController,
                            decoration: const InputDecoration(
                              labelText: 'Venue',
                              hintText: 'Main Gymnasium, Room 204...',
                              prefixIcon: Icon(Icons.place_outlined),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'WHEN DOES IT HAPPEN?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: Palette.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Optional \u2014 leave it empty for notices with no date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickEventDate,
                                  icon: const Icon(Icons.calendar_today,
                                      size: 15),
                                  label: Text(
                                    _eventDate == null
                                        ? 'Pick a date'
                                        : shortDate(_eventDate!),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Palette.ink,
                                    side: BorderSide(
                                      color: Palette.ink.withValues(alpha: 0.3),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickEventTime,
                                  icon: const Icon(Icons.schedule, size: 15),
                                  label: Text(_eventTime.format(context)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Palette.ink,
                                    side: BorderSide(
                                      color: Palette.ink.withValues(alpha: 0.3),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_eventDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_available,
                                      size: 16, color: Palette.stamp),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${shortDate(_eventDate!)} \u00b7 ${_eventTime.format(context)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Palette.ink,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.close, size: 18),
                                    color: Palette.inkSoft,
                                    tooltip: 'Clear date',
                                    onPressed: () =>
                                        setState(() => _eventDate = null),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 18),
                          const Text(
                            'TEMPORARY NOTE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: Palette.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Optional \u2014 it takes itself down when the time is up',
                            style: TextStyle(
                              fontSize: 12,
                              color: Palette.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: _temporary
                                  ? const Color(0xFFD0872B)
                                      .withValues(alpha: 0.08)
                                  : Palette.ink.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _temporary
                                    ? const Color(0xFFD0872B)
                                        .withValues(alpha: 0.5)
                                    : Palette.ink.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: const Text(
                                  'Take it down automatically',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Palette.ink,
                                  ),
                                ),
                                subtitle: const Text(
                                  'The note clears itself off the board',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Palette.inkSoft,
                                  ),
                                ),
                                value: _temporary,
                                activeThumbColor: const Color(0xFFD0872B),
                                onChanged: (value) =>
                                    setState(() => _temporary = value),
                              ),
                            ),
                          ),
                          if (_temporary) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final span in temporarySpans)
                                  ChoiceChip(
                                    label: Text(span),
                                    selected: _tempSpan == span,
                                    selectedColor:
                                        Palette.stamp.withValues(alpha: 0.16),
                                    labelStyle: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: _tempSpan == span
                                          ? Palette.stamp
                                          : Palette.ink,
                                    ),
                                    side: BorderSide(
                                      color: _tempSpan == span
                                          ? Palette.stamp
                                          : Palette.ink.withValues(alpha: 0.25),
                                    ),
                                    onSelected: (_) =>
                                        setState(() => _tempSpan = span),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.hourglass_top,
                                  size: 15,
                                  color: Color(0xFFD0872B),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _temporaryNote(),
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Palette.ink,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: _isUrgent
                                  ? Palette.stamp.withValues(alpha: 0.08)
                                  : Palette.ink.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isUrgent
                                    ? Palette.stamp.withValues(alpha: 0.5)
                                    : Palette.ink.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Material(
                              type: MaterialType.transparency,
                              child: SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                title: const Text(
                                  'Stamp it as urgent',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Palette.ink,
                                  ),
                                ),
                                subtitle: const Text(
                                  'Adds a red stamp so nobody misses it',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Palette.inkSoft,
                                  ),
                                ),
                                value: _isUrgent,
                                activeThumbColor: Palette.stamp,
                                onChanged: (value) =>
                                    setState(() => _isUrgent = value),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _submitAnnouncement,
                              icon: const Icon(Icons.push_pin_outlined),
                              label: Text(
                                widget.initial == null
                                    ? 'Pin it to the board'
                                    : 'Save changes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Palette.stamp,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shadowColor:
                                    Palette.stamp.withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: categoryTape(_selectedCategory, angle: 0.04),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ANNOUNCEMENT DETAIL SCREEN ====================

class AnnouncementDetailScreen extends StatefulWidget {
  const AnnouncementDetailScreen({
    super.key,
    required this.announcement,
    required this.onChanged,
    required this.onDeleted,
  });

  final Announcement announcement;

  /// Keeps the board (and storage) in sync with edits/saves made here.
  final ValueChanged<Announcement> onChanged;

  /// Takes the note off the board.
  final VoidCallback onDeleted;

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  late Announcement _current = widget.announcement;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.paper,
        title: const Text('Unpin this note?'),
        content: Text(
          '"${_current.title}" will be taken off the board.',
          style: const TextStyle(color: Palette.inkSoft),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Unpin',
              style: TextStyle(
                color: Palette.stamp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    widget.onDeleted();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _edit() async {
    final updated = await Navigator.push<Announcement>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateAnnouncementScreen(initial: _current),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() => _current = updated);
    widget.onChanged(updated);
  }

  void _toggleSave() {
    setState(() => _current = _current.copyWith(isSaved: !_current.isSaved));
    widget.onChanged(_current);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _current.isSaved
                ? 'Tucked into your pocket!'
                : 'Taken out of your pocket',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final announcement = _current;
    final style = categoryStyle(announcement.category);

    return Scaffold(
      backgroundColor: Palette.cork,
      appBar: AppBar(
        title: const Text('THE NOTE'),
        actions: [
          IconButton(
            tooltip: _current.isSaved ? 'Remove from saved' : 'Save note',
            onPressed: _toggleSave,
            icon: Icon(
              _current.isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _current.isSaved ? const Color(0xFFF3A712) : Palette.paper,
            ),
          ),
          IconButton(
            tooltip: 'Edit note',
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete note',
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: CorkboardPainter()),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                PhysicalShape(
                  clipper: const DeckleClipper(),
                  elevation: 10,
                  shadowColor: Colors.black.withValues(alpha: 0.5),
                  color: Palette.paper,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            categoryTape(announcement.category, angle: 0),
                            const Spacer(),
                            if (announcement.isUrgent)
                              urgentStamp(fontSize: 11),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: Palette.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 10,
                          width: double.infinity,
                          child: CustomPaint(
                            size: const Size(double.infinity, 10),
                            painter: SquigglePainter(color: style.color),
                          ),
                        ),
                        const SizedBox(height: 22),
                        if (announcement.eventDate != null) ...[
                          const Text(
                            'HAPPENS ON',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                              color: Palette.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ScheduleStrip(date: announcement.eventDate!),
                          const SizedBox(height: 16),
                        ],
                        if (announcement.venue != null) ...[
                          const SizedBox(height: 14),
                          _MetaRow(
                            icon: Icons.place_outlined,
                            label: 'VENUE',
                            value: announcement.venue!,
                          ),
                        ],
                        if (announcement.isTemporary) ...[
                          const SizedBox(height: 14),
                          ExpiryPill(expiresAt: announcement.expiresAt!),
                        ],
                        _MetaRow(
                          icon: Icons.person_outline,
                          label: 'PINNED BY',
                          value: announcement.postedBy,
                        ),
                        const SizedBox(height: 14),
                        _MetaRow(
                          icon: Icons.watch_later_outlined,
                          label: 'POSTED',
                          value: formatDateLong(announcement.datePosted),
                        ),
                        const SizedBox(height: 22),
                        Container(
                            height: 1,
                            color: Palette.ink.withValues(alpha: 0.12)),
                        const SizedBox(height: 18),
                        const Text(
                          'THE FULL NOTE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: Palette.inkSoft,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          announcement.description,
                          style: const TextStyle(
                            fontSize: 16.5,
                            height: 1.7,
                            color: Palette.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (announcement.isUrgent)
                  Positioned(
                    top: -10,
                    right: 24,
                    child: Transform.rotate(
                      angle: 0.06,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.stamp,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'PRIORITY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: Palette.walnut,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shared with your class!')),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Palette.paper,
                    side: BorderSide(
                      color: Palette.paper.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _toggleSave,
                  icon: Icon(
                    _current.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                  ),
                  label: Text(_current.isSaved ? 'Saved' : 'Save'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _current.isSaved
                        ? const Color(0xFFF3A712)
                        : Palette.paper,
                    side: BorderSide(
                      color: Palette.paper.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
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

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Palette.inkSoft),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: Palette.inkSoft,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Palette.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
