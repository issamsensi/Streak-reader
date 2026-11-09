import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/reading_reminder.dart';

class ReadingReminderService {
  ReadingReminderService._();

  static final instance = ReadingReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void>? _initFuture;
  ReadingReminderSettings? _pendingSettings;
  bool _pendingGoalCompleted = false;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    if (!_supported) return;
    try {
      tz.initializeTimeZones();
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
        macOS: DarwinInitializationSettings(),
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open Streak Reader',
        ),
      );
      final initialized = await _plugin.initialize(settings: settings);
      if (initialized != true) return;
      _initialized = true;
      final pending = _pendingSettings;
      if (pending != null) {
        await configure(pending, goalCompleted: _pendingGoalCompleted);
      }
    } catch (_) {
      // Notifications are optional; startup must continue without them.
    }
  }

  Future<void> configure(
    ReadingReminderSettings settings, {
    required bool goalCompleted,
  }) async {
    _pendingSettings = settings;
    _pendingGoalCompleted = goalCompleted;
    if (!_initialized) {
      unawaited(initialize());
      return;
    }
    try {
      await _cancelScheduled();
      if (!settings.enabled || settings.days.isEmpty) return;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final permission = await android?.requestNotificationsPermission();
    if (android != null && permission == false) return;

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosPermission = await ios?.requestPermissions(
      alert: true,
      badge: false,
      sound: true,
    );
    if (ios != null && iosPermission == false) return;

    for (final day in settings.days) {
      final id = 700 + day;
      final next = _nextOccurrence(
        day,
        settings.hour,
        settings.minute,
        skipToday: goalCompleted,
      );
      await _plugin.zonedSchedule(
        id: id,
        title: 'Streak Reader',
        body: settings.message,
        scheduledDate: next,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_reminders',
            'Reading reminders',
            channelDescription: 'Reminders to complete your daily reading goal',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
    } catch (_) {
      // Scheduling is best-effort; permission/plugin issues must not crash.
    }
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _cancelScheduled();
    } catch (_) {}
  }

  Future<void> _cancelScheduled() async {
    for (var day = 1; day <= 7; day++) {
      await _plugin.cancel(id: 700 + day);
    }
  }

  tz.TZDateTime _nextOccurrence(
    int weekday,
    int hour,
    int minute, {
    required bool skipToday,
  }) {
    final now = tz.TZDateTime.now(tz.local);
    var date =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || !date.isAfter(now)) {
      date = date.add(const Duration(days: 1));
    }
    if (skipToday &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      date = date.add(const Duration(days: 7));
    }
    return date;
  }
}
