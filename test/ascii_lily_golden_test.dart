// Golden snapshots of the ASCII lily bouquet at four growth phases:
// grass, stems + buds, full bloom, and the typed message
// (regenerate with `flutter test --update-goldens`).
//
// On Windows the app's real fonts (Consolas for the ASCII grid,
// Georgia for the caption) are loaded into the test so the goldens
// match what actually ships — including the monospace cell aspect the
// flower geometry is laid out against. Where those fonts are missing
// the test font stands in and the frames still capture the layout.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_announcements/ascii_lily_bouquet.dart';

Future<void> _loadRealFonts() async {
  if (!Platform.isWindows) return;
  const fonts = {
    'Consolas': r'C:\Windows\Fonts\consola.ttf', // note: no trailing 's'
    'Georgia': r'C:\Windows\Fonts\georgia.ttf',
  };
  for (final entry in fonts.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final loader = FontLoader(entry.key);
    loader.addFont(file.readAsBytes().then((b) => ByteData.sublistView(b)));
    await loader.load();
  }
}

void main() {
  testWidgets('golden: ascii lily bouquet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(520, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Real font files come from disk — that I/O only completes outside
    // the test's fake-async zone.
    await tester.runAsync(_loadRealFonts);
    await tester.pumpWidget(const MaterialApp(home: AsciiLilyScreen()));

    await tester.pump(const Duration(milliseconds: 700));
    await expectLater(
      find.byType(AsciiLilyBouquet),
      matchesGoldenFile('goldens/ascii_lily_1_grass.png'),
    );

    await tester.pump(const Duration(milliseconds: 1900)); // t = 2.6s
    await expectLater(
      find.byType(AsciiLilyBouquet),
      matchesGoldenFile('goldens/ascii_lily_2_stems.png'),
    );

    await tester.pump(const Duration(milliseconds: 2200)); // t = 4.8s
    await expectLater(
      find.byType(AsciiLilyBouquet),
      matchesGoldenFile('goldens/ascii_lily_3_bloom.png'),
    );

    await tester.pump(const Duration(milliseconds: 1400)); // t = 6.2s
    await expectLater(
      find.byType(AsciiLilyBouquet),
      matchesGoldenFile('goldens/ascii_lily_4_message.png'),
    );
  });
}
