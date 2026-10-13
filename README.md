# CHCC Student Announcements

A student announcements app that looks like the campus notice board at night —
cream paper notes are pinned to a deep navy board, taped down with coloured
washi tape, and stamped red when they are urgent. The **official seal of
Concepcion Holy Cross College, Inc.** sits in the header beside the wordmark.

## Screens

| Screen | What it does |
| --- | --- |
| **Board** (home) | The CHCC crest and wordmark in the app bar, bunting strung underneath, filter tabs cut from tape, and a feed of paper notes that drop onto the board one after another. |
| **Events** (bottom tab) | The campus diary: every dated note as a card with a calendar chip, **venue**, date strip and countdown — **soonest first**, with an **Upcoming / Past** switch. |
| **The note** (detail) | The full sheet on the navy board, with a hand-drawn underline, pin metadata, and a bottom bar for sharing or saving. |
| **Pin a new note** (create) | A fresh sheet of paper with the category taped across the top; validation, categories, an optional urgent stamp, a **venue**, a **date + time picker**, and an optional **take-it-down timer** for temporary notes. |

The **Board / Events** switch lives in the bottom navigation bar, and the
button on each tab matches it — *Pin a note* on the board, *Add an event*
(pre-set to the Event category) on the diary.

## Dates on every note

- **When it happens** — `eventDate` is optional; notes that have one show a
  tinted strip with the exact date/time plus a countdown pill
  (`Today`, `Tomorrow`, `In 5 days`, `3 days ago`). The pill turns red within
  2 days, amber within a week, green after that.
- **When it was made** — `datePosted` is stamped on every card
  (`Posted on Oct 08, 2026 - 9:30 AM`) and shown in full on the detail sheet.
- **Where it happens** — `venue` is an optional field of its own (not buried
  in the description). It shows under the title on the board, on every event
  card, and as a **VENUE** row on the note sheet. Empty venues read
  *"Venue to be announced"*.
- **When it goes away** — `expiresAt` makes a note *temporary*. The compose
  form offers a switch plus take-down choices (*After the event*, *In 24
  hours*, *In 3 days*, *In 7 days*, *In 30 days*), previews the exact moment,
  and stamps the note with an amber **TAKES ITSELF DOWN** pill. Once the time
  passes the note is off the board, off the events page, and out of storage —
  no clutter left behind.

## Everything else it can do

| Feature | How it works |
| --- | --- |
| **Events page** | Upcoming events sorted soonest-first with date, countdown and venue; flip to **Past** for what has already happened. Notes without a date stay on the board only. |
| **Delete** | Swipe a note left on the board (or tap the trash icon on the sheet). It asks first, then shows **UNDO** in the snack bar if you change your mind. |
| **Edit** | Pencil icon on the sheet reopens the form pre-filled — "Save changes" keeps the original posted date and id. |
| **Search** | Magnifier in the app bar drops down a search box; matches title, details *and* who posted it, on top of the category tabs. |
| **Saved notes** | Bookmark on the sheet (or its bottom bar) files a note into your pocket; the bookmark in the app bar filters to saved notes only, and the header counts them. |
| **It remembers** | The whole board is written to `shared_preferences` as JSON, so notes you add, edit, save or delete today are still there tomorrow. |

## Look & feel

- `CorkboardPainter` paints the midnight-navy board (top-lit gradient +
  speckles + vignette) — no bitmaps needed.
- `BuntingPainter` draws the flags hanging from the app bar.
- `DeckleClipper` tears the bottom edge of every sheet; `PhysicalShape` casts a
  shadow that follows the tear.
- `SquigglePainter` draws the wavy underline on the detail sheet.
- Notes sit at a tiny deterministic tilt (`tiltFor`) so the board looks hand-pinned.
- The **CHCC seal** (`assets/chcc_seal.jpg`, Concepcion Holy Cross College, Inc.)
  is the header crest, the empty-board mark, the favicon / PWA icon, and the
  Android launcher icon.

Everything is drawn with Flutter's own painting API, so the app adds no assets
and no extra packages.

## Run it

```bash
flutter pub get
flutter run          # any device
flutter test         # 12 widget tests + 4 golden snapshots
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
