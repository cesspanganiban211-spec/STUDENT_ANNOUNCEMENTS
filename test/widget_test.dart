// Smoke tests for the campus bulletin board UI.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:student_announcements/main.dart';

Finder tapeTab(String filter) => find.byKey(ValueKey<String>(filter));

Future<void> pumpBoard(WidgetTester tester) async {
  await tester.pumpWidget(const StudentAnnouncementsApp());
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('board renders notes and filter tabs',
      (WidgetTester tester) async {
    await pumpBoard(tester);

    expect(find.text('STUDENT ANNOUNCEMENTS'), findsOneWidget);
    expect(find.byKey(const ValueKey('chcc-crest')), findsOneWidget); // seal
    expect(
      find.text('CONCEPCION HOLY CROSS COLLEGE'),
      findsOneWidget,
    );
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
    await pumpBoard(tester);

    await tester.tap(tapeTab('Holiday'));
    await tester.pumpAndSettle();

    expect(find.text('Winter Break Schedule'), findsOneWidget);
    expect(find.text('Midterm Examination Schedule'), findsNothing);
  });

  testWidgets('search finds notes by keyword', (WidgetTester tester) async {
    await pumpBoard(tester);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'science');
    await tester.pumpAndSettle();

    expect(find.text('Annual Science Fair 2026'), findsOneWidget);
    expect(find.text('Winter Break Schedule'), findsNothing);
  });

  testWidgets('compose screen opens from a filtered board',
      (WidgetTester tester) async {
    await pumpBoard(tester);

    await tester.tap(tapeTab('Exam'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pin a note'));
    await tester.pumpAndSettle();

    expect(find.text('Pin it to the board'), findsOneWidget);
    expect(find.text('Fresh off the press'), findsOneWidget);
  });

  testWidgets('tapping a note opens its sheet', (WidgetTester tester) async {
    await pumpBoard(tester);

    await tester.tap(find.text('Midterm Examination Schedule'));
    await tester.pumpAndSettle();

    expect(find.text('THE NOTE'), findsOneWidget); // detail app bar
    expect(find.text('THE FULL NOTE'), findsOneWidget);
    expect(find.text('PINNED BY'), findsOneWidget);
    expect(find.text('Academic Office'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('deleting from the sheet unpins it and UNDO brings it back',
      (WidgetTester tester) async {
    await pumpBoard(tester);

    await tester.tap(find.text('Midterm Examination Schedule'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Unpin')); // confirm dialog
    await tester.pumpAndSettle();

    expect(find.text('Midterm Examination Schedule'), findsNothing);
    expect(
        find.text('Unpinned "Midterm Examination Schedule"'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();

    expect(find.text('Midterm Examination Schedule'), findsOneWidget);
  });

  testWidgets('saving a note marks it and the saved filter shows it',
      (WidgetTester tester) async {
    await pumpBoard(tester);

    await tester.tap(find.text('Midterm Examination Schedule'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Tucked into your pocket!'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 saved'), findsOneWidget);

    await tester.tap(find.byTooltip('Show saved notes only'));
    await tester.pumpAndSettle();

    expect(find.text('Midterm Examination Schedule'), findsOneWidget);
    expect(find.text('Library Hours Extended'), findsNothing);
  });

  testWidgets('editing a note keeps the change', (WidgetTester tester) async {
    // Tall surface so the whole form fits without scrolling.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpBoard(tester);

    await tester.tap(find.text('Midterm Examination Schedule'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    expect(find.text('EDIT NOTE'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Midterm Schedule (revised)',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(find.text('Midterm Schedule (revised)'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Midterm Schedule (revised)'), findsOneWidget);
  });
}
