# The Campus Bulletin Board

A student announcements app that looks like the corkboard in the hallway — notes
are pinned to a textured board, taped down with coloured washi tape, and stamped
red when they are urgent.

## Screens

| Screen | What it does |
| --- | --- |
| **Board** (home) | Bunting strung under the app bar, filter tabs cut from tape, and a feed of paper notes that drop onto the board one after another. |
| **The note** (detail) | The full sheet on cork, with a hand-drawn underline, pin metadata, and a bottom bar for sharing or saving. |
| **Pin a new note** (create) | A fresh sheet of paper with the category taped across the top; validation, categories, an optional urgent stamp, and a **date + time picker** for when the announcement happens. |

## Dates on every note

- **When it happens** — `eventDate` is optional; notes that have one show a
  tinted strip with the exact date/time plus a countdown pill
  (`Today`, `Tomorrow`, `In 5 days`, `3 days ago`). The pill turns red within
  2 days, amber within a week, green after that.
- **When it was made** — `datePosted` is stamped on every card
  (`Posted on Oct 08, 2026 - 9:30 AM`) and shown in full on the detail sheet.

## Look & feel

- `CorkboardPainter` paints the cork (speckles + vignette) — no bitmaps needed.
- `BuntingPainter` draws the flags hanging from the app bar.
- `DeckleClipper` tears the bottom edge of every sheet; `PhysicalShape` casts a
  shadow that follows the tear.
- `SquigglePainter` draws the wavy underline on the detail sheet.
- Notes sit at a tiny deterministic tilt (`tiltFor`) so the board looks hand-pinned.

Everything is drawn with Flutter's own painting API, so the app adds no assets
and no extra packages.

## Run it

```bash
flutter pub get
flutter run          # any device
flutter test         # 4 widget tests + 3 golden snapshots
```

## Install it on an Android phone

```bash
flutter build apk --release
```

The installer is written to:

```
build/app/outputs/flutter-apk/app-release.apk
```

Copy that `.apk` to the phone (USB cable, Google Drive, Bluetooth, QR file
share...), open it, and allow **Install unknown apps** for your file manager /
browser when Android asks. That's all — no Play Store account needed.

Notes:

- The app id is `com.example.student_announcements`; change
  `applicationId` in `android/app/build.gradle.kts` before publishing anywhere.
- `flutter build apk --split-per-abi` makes smaller per-device APKs.

Golden snapshots live in `test/goldens/`; regenerate them with
`flutter test --update-goldens` after a design change.
