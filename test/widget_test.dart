// Smoke tests for the campus bulletin board UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_announcements/main.dart';

Finder tapeTab(String filter) => find.byKey(ValueKey<String>(filter));

void main() {
  testWidgets('board renders notes and filter tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentAnnouncementsApp());
    await tester.pumpAndSettle();

    expect(find.text('THE CAMPUS BULLETIN'), findsOneWidget);
    expect(find.text('Midterm Examination Schedule'), findsOneWidget);
    expect(find.text('Pin a note'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Winter Break Schedule'),
      240,
      scrollable: find.byType(Scrollable).last,
    );

    expect(find.text('Winter Break Schedule'), findsOneWidget);
  });

  testWidgets('filtering by category narrows the board',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentAnnouncementsApp());
    await tester.pumpAndSettle();

    await tester.tap(tapeTab('Holiday'));
    await tester.pumpAndSettle();

    expect(find.text('Winter Break Schedule'), findsOneWidget);
    expect(find.text('Midterm Examination Schedule'), findsNothing);
  });

  testWidgets('compose screen opens from a filtered board',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StudentAnnouncementsApp());
    await tester.pumpAndSettle();

    await tester.tap(tapeTab('Exam'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pin a note'));
    await tester.pumpAndSettle();

    expect(find.text('Pin it to the board'), findsOneWidget);
    expect(find.text('Fresh off the press'), findsOneWidget);
  });
  testWidgets('tapping a note opens its sheet', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentAnnouncementsApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Midterm Examination Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('THE NOTE'), findsOneWidget); // detail app bar
    expect(find.text('THE FULL NOTE'), findsOneWidget);
    expect(find.text('PINNED BY'), findsOneWidget);
    expect(find.text('Academic Office'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });
}
