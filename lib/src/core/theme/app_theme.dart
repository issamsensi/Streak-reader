import 'package:flutter/material.dart';

/// Brand palette shared by the light and dark themes.
///
/// Accent colours live in a [ThemeExtension] so widgets can ask for
/// "the streak colour" instead of hard-coding values that break in dark mode.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color streak;
  final Color gold;
  final Color pages;
  final Color success;
  final Color bannerStart;
  final Color bannerEnd;
  final Color onBanner;
  final Color border;
  final Color muted;

  const AppPalette({
    required this.streak,
    required this.gold,
    required this.pages,
    required this.success,
    required this.bannerStart,
    required this.bannerEnd,
    required this.onBanner,
    required this.border,
    required this.muted,
  });

  static const light = AppPalette(
    streak: Color(0xFFE07A3F),
    gold: Color(0xFFC4992F),
    pages: Color(0xFF416C93),
    success: Color(0xFF3F7A4E),
    bannerStart: Color(0xFF214E43),
    bannerEnd: Color(0xFF2F6B5B),
    onBanner: Color(0xFFF4FBF8),
    border: Color(0xFFE7DFD1),
    muted: Color(0xFF66716A),
  );

  static const dark = AppPalette(
    streak: Color(0xFFF2A26B),
    gold: Color(0xFFE7C36A),
    pages: Color(0xFF7FAAD4),
    success: Color(0xFF86C694),
    bannerStart: Color(0xFF1D4A3E),
    bannerEnd: Color(0xFF14362D),
    onBanner: Color(0xFFDFF6EC),
    border: Color(0xFF303B35),
    muted: Color(0xFF97A29B),
  );

  @override
  AppPalette copyWith({
    Color? streak,
    Color? gold,
    Color? pages,
    Color? success,
    Color? bannerStart,
    Color? bannerEnd,
    Color? onBanner,
    Color? border,
    Color? muted,
  }) {
    return AppPalette(
      streak: streak ?? this.streak,
      gold: gold ?? this.gold,
      pages: pages ?? this.pages,
      success: success ?? this.success,
      bannerStart: bannerStart ?? this.bannerStart,
      bannerEnd: bannerEnd ?? this.bannerEnd,
      onBanner: onBanner ?? this.onBanner,
      border: border ?? this.border,
      muted: muted ?? this.muted,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      streak: Color.lerp(streak, other.streak, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      pages: Color.lerp(pages, other.pages, t)!,
      success: Color.lerp(success, other.success, t)!,
      bannerStart: Color.lerp(bannerStart, other.bannerStart, t)!,
      bannerEnd: Color.lerp(bannerEnd, other.bannerEnd, t)!,
      onBanner: Color.lerp(onBanner, other.onBanner, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

class AppTheme {
  AppTheme._();

  /// Reading-optimised face used for body copy and controls.
  static const String bodyFont = 'ReadexPro';

  /// Geometric editorial face used for headings and large numbers.
  static const String displayFont = 'Alexandria';

  static const Color _seed = Color(0xFF2F6B5E);

  // Warm, saturated cover colours that stay readable with white text.
  static const List<List<Color>> _coverGradients = [
    [Color(0xFF2F6B5B), Color(0xFF1D4A3F)],
    [Color(0xFFB4633A), Color(0xFF8A4526)],
    [Color(0xFF4C6B8A), Color(0xFF324B66)],
    [Color(0xFF7A5C8E), Color(0xFF5B406D)],
    [Color(0xFF8A7A3F), Color(0xFF6B5C2A)],
  ];

  /// Deterministic cover gradient so a book keeps its colour between rebuilds.
  static List<Color> coverGradientFor(String title) {
    var hash = 0;
    for (final unit in title.trim().codeUnits) {
      hash = (hash + unit) % _coverGradients.length;
    }
    return _coverGradients[hash];
  }

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF2F6B5E),
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFCFEDE3),
    onPrimaryContainer: const Color(0xFF082E25),
    secondary: const Color(0xFFB4633A),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFFFDBC8),
    onSecondaryContainer: const Color(0xFF3D1604),
    tertiary: const Color(0xFF8A6A1F),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFFFE3A6),
    onTertiaryContainer: const Color(0xFF2B1D00),
    surface: const Color(0xFFFAF6EF),
    onSurface: const Color(0xFF1B211E),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF5EFE5),
    surfaceContainer: const Color(0xFFEFE8DC),
    surfaceContainerHigh: const Color(0xFFE9E1D3),
    surfaceContainerHighest: const Color(0xFFE3DACB),
    onSurfaceVariant: const Color(0xFF5C665F),
    outline: const Color(0xFF7D8880),
    outlineVariant: const Color(0xFFD5CEC1),
    surfaceTint: const Color(0xFF2F6B5E),
    inverseSurface: const Color(0xFF2F3531),
    onInverseSurface: const Color(0xFFF0F1EC),
    inversePrimary: const Color(0xFF8FD6C0),
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF93D8C3),
    onPrimary: const Color(0xFF00382C),
    primaryContainer: const Color(0xFF1B4F42),
    onPrimaryContainer: const Color(0xFFAFF2DC),
    secondary: const Color(0xFFF2B792),
    onSecondary: const Color(0xFF4B2109),
    secondaryContainer: const Color(0xFF6B351C),
    onSecondaryContainer: const Color(0xFFFFDBC8),
    tertiary: const Color(0xFFE9C46A),
    onTertiary: const Color(0xFF3B2F00),
    tertiaryContainer: const Color(0xFF574400),
    onTertiaryContainer: const Color(0xFFFFE3A6),
    surface: const Color(0xFF101614),
    onSurface: const Color(0xFFE2E8E3),
    surfaceContainerLowest: const Color(0xFF0B100E),
    surfaceContainerLow: const Color(0xFF171E1B),
    surfaceContainer: const Color(0xFF1B2420),
    surfaceContainerHigh: const Color(0xFF25302A),
    surfaceContainerHighest: const Color(0xFF303C35),
    onSurfaceVariant: const Color(0xFFBFC9C2),
    outline: const Color(0xFF89948D),
    outlineVariant: const Color(0xFF3B4640),
    surfaceTint: const Color(0xFF93D8C3),
    inverseSurface: const Color(0xFFE2E8E3),
    onInverseSurface: const Color(0xFF28302B),
    inversePrimary: const Color(0xFF2F6B5E),
  );

  static ThemeData get light => _build(
        scheme: _lightScheme,
        palette: AppPalette.light,
      );

  static ThemeData get dark => _build(
        scheme: _darkScheme,
        palette: AppPalette.dark,
      );

  static ThemeData _build({
    required ColorScheme scheme,
    required AppPalette palette,
  }) {
    final textTheme = _textTheme(scheme);
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: bodyFont,
      textTheme: textTheme,
    );

    final roundedButton = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );

    return base.copyWith(
      extensions: [palette],
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 68,
        titleSpacing: 20,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: palette.border),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: roundedButton,
          elevation: 0,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: roundedButton,
          side: BorderSide(color: palette.border),
          foregroundColor: scheme.onSurface,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.muted),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: palette.border),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        modalBackgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        dragHandleColor: scheme.outlineVariant,
        dragHandleSize: const Size(40, 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        side: BorderSide(color: palette.border),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: const StadiumBorder(),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 2,
        ),
        minVerticalPadding: 8,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: scheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.border),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        actionTextColor: scheme.inversePrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final text = TextTheme(
      displayLarge: _display(44, FontWeight.w700, 1.12),
      displayMedium: _display(36, FontWeight.w700, 1.14),
      displaySmall: _display(30, FontWeight.w600, 1.18),
      headlineLarge: _display(28, FontWeight.w600, 1.2),
      headlineMedium: _display(24, FontWeight.w600, 1.22),
      headlineSmall: _display(21, FontWeight.w600, 1.24),
      titleLarge: _display(20, FontWeight.w600, 1.28),
      titleMedium: _body(16, FontWeight.w600, 1.35),
      titleSmall: _body(14, FontWeight.w600, 1.35),
      bodyLarge: _body(16, FontWeight.w400, 1.6),
      bodyMedium: _body(14, FontWeight.w400, 1.55),
      bodySmall: _body(12, FontWeight.w400, 1.45),
      labelLarge: _body(14, FontWeight.w600, 1.3),
      labelMedium: _body(12, FontWeight.w500, 1.3),
      labelSmall: _body(11, FontWeight.w500, 1.3),
    );
    return text.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
  }

  static TextStyle _display(
    double size,
    FontWeight weight,
    double height,
  ) {
    return TextStyle(
      fontFamily: displayFont,
      fontSize: size,
      fontWeight: weight,
      height: height,
    );
  }

  static TextStyle _body(
    double size,
    FontWeight weight,
    double height,
  ) {
    return TextStyle(
      fontFamily: bodyFont,
      fontSize: size,
      fontWeight: weight,
      height: height,
    );
  }
}
