import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streak_reader/main.dart';
import 'package:streak_reader/src/core/di/providers.dart';
import 'package:streak_reader/src/data/datasources/local/app_database.dart';
import 'package:streak_reader/src/domain/entities/focus_mode_preferences.dart';
import 'package:streak_reader/src/features/reader/presentation/pdf_reader_screen.dart';
import 'package:streak_reader/src/features/reader/providers/reading_session_provider.dart';
import 'package:streak_reader/src/features/settings/providers/settings_provider.dart';

void main() {
  group('FocusModePreferences', () {
    test('defaults to normal mode with temporary reveal', () {
      const prefs = FocusModePreferences();
      expect(prefs.enabledByDefault, isFalse);
      expect(prefs.tapBehavior, FocusTapBehavior.temporaryReveal);
    });

    test('round-trips through its persisted map', () {
      const prefs = FocusModePreferences(
        enabledByDefault: true,
        tapBehavior: FocusTapBehavior.toggleControls,
      );
      final restored = FocusModePreferences.fromMap(prefs.toMap());
      expect(restored.enabledByDefault, isTrue);
      expect(restored.tapBehavior, FocusTapBehavior.toggleControls);
    });

    test('unknown persisted values fall back to safe defaults', () {
      final restored = FocusModePreferences.fromMap(const {
        'enabledByDefault': 'yes',
        'tapBehavior': 'bogus',
      });
      expect(restored.enabledByDefault, isFalse);
      expect(restored.tapBehavior, FocusTapBehavior.temporaryReveal);
    });
  });

  group('ReaderChrome', () {
    test('starts in normal mode with controls visible by default', () {
      final chrome = ReaderChrome.initial(const FocusModePreferences());
      expect(chrome.isFocus, isFalse);
      expect(chrome.controlsVisible, isTrue);
    });

    test('starts in focus mode with controls hidden when preferred', () {
      final chrome = ReaderChrome.initial(
        const FocusModePreferences(enabledByDefault: true),
      );
      expect(chrome.isFocus, isTrue);
      expect(chrome.controlsVisible, isFalse);
    });

    test('tap toggles controls in normal mode', () {
      final chrome = ReaderChrome.initial(const FocusModePreferences());
      expect(
        chrome.onTap(FocusTapBehavior.temporaryReveal),
        isFalse,
      );
      expect(chrome.controlsVisible, isFalse);
      chrome.onTap(FocusTapBehavior.toggleControls);
      expect(chrome.controlsVisible, isTrue);
      expect(chrome.isFocus, isFalse);
    });

    test('temporary reveal shows controls and requests an auto-hide', () {
      final chrome = ReaderChrome.initial(
        const FocusModePreferences(enabledByDefault: true),
      );
      expect(chrome.onTap(FocusTapBehavior.temporaryReveal), isTrue);
      expect(chrome.controlsVisible, isTrue);
      chrome.onAutoHide();
      expect(chrome.controlsVisible, isFalse);
      expect(chrome.isFocus, isTrue);
    });

    test('toggle behavior in focus mode needs no auto-hide', () {
      final chrome = ReaderChrome.initial(
        const FocusModePreferences(enabledByDefault: true),
      );
      expect(chrome.onTap(FocusTapBehavior.toggleControls), isFalse);
      expect(chrome.controlsVisible, isTrue);
      // No auto-hide is scheduled in toggle mode; only the next tap hides.
      chrome.onTap(FocusTapBehavior.toggleControls);
      expect(chrome.controlsVisible, isFalse);
    });

    test('exit focus restores normal mode with visible controls', () {
      final chrome = ReaderChrome.initial(
        const FocusModePreferences(enabledByDefault: true),
      );
      chrome.exitFocus();
      expect(chrome.isFocus, isFalse);
      expect(chrome.controlsVisible, isTrue);
      chrome.enterFocus();
      expect(chrome.isFocus, isTrue);
      expect(chrome.controlsVisible, isFalse);
    });
  });

  test('focus preferences persist across settings controllers', () async {
    SharedPreferences.setMockInitialValues({});
    final first = SettingsController();
    await first.initialized;
    await first.setFocusMode(const FocusModePreferences(
      enabledByDefault: true,
      tapBehavior: FocusTapBehavior.toggleControls,
    ));

    final second = SettingsController();
    await second.initialized;
    expect(second.state.focusMode.enabledByDefault, isTrue);
    expect(
      second.state.focusMode.tapBehavior,
      FocusTapBehavior.toggleControls,
    );
  });

  testWidgets('book opens in focus mode when that is the saved default',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'settings_focus_mode':
          '{"enabledByDefault":true,"tapBehavior":"toggleControls"}',
    });
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final file = File('${Directory.systemTemp.path}/focus_default_test.pdf');
    file.writeAsBytesSync('%PDF-1.4\n%%EOF'.codeUnits);
    addTearDown(() => file.deleteSync());
    await db.insertBook(BooksCompanion.insert(
      title: 'Default Focus Book',
      readingStatus: const drift.Value('currently_reading'),
      filePath: drift.Value(file.path),
    ));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Default Focus Book'));
    await tester.tap(find.text('Default Focus Book'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PdfReaderScreen), findsOneWidget);
    // No enter-focus button: already in focus with chrome hidden.
    expect(find.byIcon(Icons.fullscreen_rounded), findsNothing);
    // Tap toggles the minimal controls on (toggleControls preference).
    final center = tester.getCenter(find.byType(PdfReaderScreen));
    await tester.tapAt(center + const Offset(0, 200));
    await tester.pump();
    expect(find.text('Exit Focus'), findsOneWidget);
    await tester.tapAt(center + const Offset(0, 200));
    await tester.pump();
    final topOpacity = tester
        .widgetList<AnimatedOpacity>(
          find.ancestor(
            of: find.text('Exit Focus'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .first
        .opacity;
    expect(topOpacity, 0);
  });

  testWidgets('focus mode hides chrome while the session keeps running',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final file = File('${Directory.systemTemp.path}/focus_mode_test.pdf');
    file.writeAsBytesSync('%PDF-1.4\n%%EOF'.codeUnits);
    addTearDown(() => file.deleteSync());
    final bookId = await db.insertBook(BooksCompanion.insert(
      title: 'Focus Book',
      readingStatus: const drift.Value('currently_reading'),
      filePath: drift.Value(file.path),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Focus Book'));
    await tester.tap(find.text('Focus Book'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PdfReaderScreen), findsOneWidget);

    // Start a session in normal mode.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(PdfReaderScreen)),
    );
    expect(find.byTooltip('Focus Mode'), findsOneWidget);
    await tester.tap(find.text('بدء القراءة'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    final controller =
        container.read(readingSessionControllerProvider.notifier);
    expect(controller.hasSession, isTrue);
    expect(controller.isActive, isTrue);
    final sessionId = controller.state.sessionId;
    final elapsedBeforeFocus = controller.elapsedSeconds;

    // Enter focus mode: chrome disappears, session must not restart.
    await tester.tap(find.byIcon(Icons.fullscreen_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.fullscreen_rounded), findsNothing);
    // Chrome fades out (opacity 0 + pointer-ignored) rather than unmounting.
    final pauseOpacity = tester
        .widgetList<AnimatedOpacity>(
          find.ancestor(
            of: find.text('إيقاف مؤقت'),
            matching: find.byType(AnimatedOpacity),
          ),
        )
        .first
        .opacity;
    expect(pauseOpacity, 0);
    final pauseIgnore = tester
        .widgetList<IgnorePointer>(
          find.ancestor(
            of: find.text('إيقاف مؤقت'),
            matching: find.byType(IgnorePointer),
          ),
        )
        .any((w) => w.ignoring);
    expect(pauseIgnore, isTrue);
    expect(controller.isActive, isTrue);
    expect(controller.state.sessionId, sessionId);

    await tester.pump(const Duration(seconds: 3));
    expect(controller.elapsedSeconds, greaterThanOrEqualTo(elapsedBeforeFocus));

    // Exit via tap-reveal then Exit Focus.
    final center = tester.getCenter(find.byType(PdfReaderScreen));
    await tester.tapAt(center + const Offset(0, 200));
    await tester.pump();
    expect(find.text('Exit Focus'), findsOneWidget);
    await tester.tap(find.text('Exit Focus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.fullscreen_rounded), findsOneWidget);
    // Same single session, still active, never duplicated or restarted.
    expect(controller.state.sessionId, sessionId);
    expect(controller.isActive, isTrue);
    final allSessions = await (db.select(db.readingSessions)
          ..where((t) => t.bookId.equals(bookId)))
        .get();
    expect(allSessions, hasLength(1));
  });
}
