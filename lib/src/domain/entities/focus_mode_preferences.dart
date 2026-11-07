/// How a tap behaves while reading in Focus Mode.
enum FocusTapBehavior {
  /// Tap reveals controls briefly; they hide again on their own.
  temporaryReveal,

  /// Tap toggles controls on/off until the next tap.
  toggleControls,
}

class FocusModePreferences {
  /// Open books directly in Focus Mode.
  final bool enabledByDefault;

  final FocusTapBehavior tapBehavior;

  const FocusModePreferences({
    this.enabledByDefault = false,
    this.tapBehavior = FocusTapBehavior.temporaryReveal,
  });

  FocusModePreferences copyWith({
    bool? enabledByDefault,
    FocusTapBehavior? tapBehavior,
  }) =>
      FocusModePreferences(
        enabledByDefault: enabledByDefault ?? this.enabledByDefault,
        tapBehavior: tapBehavior ?? this.tapBehavior,
      );

  Map<String, Object?> toMap() => {
        'enabledByDefault': enabledByDefault,
        'tapBehavior': tapBehavior.name,
      };

  factory FocusModePreferences.fromMap(Map<dynamic, dynamic> map) {
    return FocusModePreferences(
      enabledByDefault: map['enabledByDefault'] == true,
      tapBehavior: switch (map['tapBehavior']) {
        'toggleControls' => FocusTapBehavior.toggleControls,
        _ => FocusTapBehavior.temporaryReveal,
      },
    );
  }
}

enum ReaderMode { normal, focus }

/// Pure visibility state machine for the PDF reader chrome.
///
/// Kept session-agnostic on purpose: entering/exiting Focus Mode and
/// showing/hiding chrome never touch the reading session, so an active
/// timer keeps its session id and accumulated duration.
class ReaderChrome {
  ReaderMode mode;
  bool controlsVisible;

  ReaderChrome._(this.mode, this.controlsVisible);

  factory ReaderChrome.initial(FocusModePreferences preferences) =>
      preferences.enabledByDefault
          ? ReaderChrome._(ReaderMode.focus, false)
          : ReaderChrome._(ReaderMode.normal, true);

  bool get isFocus => mode == ReaderMode.focus;

  void enterFocus() {
    mode = ReaderMode.focus;
    controlsVisible = false;
  }

  void exitFocus() {
    mode = ReaderMode.normal;
    controlsVisible = true;
  }

  /// Handles a deliberate tap. Returns true when the caller should schedule
  /// an automatic hide (only for a temporary reveal in Focus Mode).
  bool onTap(FocusTapBehavior behavior) {
    if (!isFocus) {
      controlsVisible = !controlsVisible;
      return false;
    }
    if (behavior == FocusTapBehavior.toggleControls) {
      controlsVisible = !controlsVisible;
      return false;
    }
    controlsVisible = true;
    return true;
  }

  /// Automatic hide after a temporary reveal. No-op outside Focus Mode.
  void onAutoHide() {
    if (isFocus) controlsVisible = false;
  }
}
