// Golden snapshots of the bulletin board screens (see `flutter test --update-goldens`).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_announcements/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpAt(WidgetTester tester, Widget widget) async {
    tester.view.physicalSize = const Size(412, 880);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();
  }

  testWidgets('golden: board', (WidgetTester tester) async {
    await pumpAt(tester, const StudentAnnouncementsApp());
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/board.png'),
    );
  });

  testWidgets('golden: detail', (WidgetTester tester) async {
    await pumpAt(
      tester,
      StudentAnnouncementsApp(
        home: AnnouncementDetailScreen(
          announcement: Announcement(
            id: '1',
            title: 'Midterm Examination Schedule',
            description:
                'The midterm examinations will begin on October 15th. Please check the detailed schedule on the student portal. All students are required to bring their student ID cards.',
            category: 'Exam',
            datePosted: DateTime(2026, 10, 8, 9, 30),
            postedBy: 'Academic Office',
            isUrgent: true,
          ),
          onChanged: (_) {},
          onDeleted: () {},
        ),
      ),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/detail.png'),
    );
  });

  testWidgets('golden: compose', (WidgetTester tester) async {
    await pumpAt(
      tester,
      const StudentAnnouncementsApp(home: CreateAnnouncementScreen()),
    );
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/compose.png'),
    );
  });
}
