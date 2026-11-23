import 'package:material_ui/material_ui.dart';

class AppPalette {
  static const Color primaryGreen = Color(0xFF28654F);
  static const Color darkGreen = Color(0xFF153F33);
  static const Color success = Color(0xFF3D805D);
  static const Color goldDark = Color(0xFFA87830);
  static const Color error = Color(0xFFB34B42);
  static const Color white = Color(0xFFFBF8EF);
  static const Color ink = Color(0xFF202B25);
  static const Color softGold = Color(0xFFE8D8B8);
  static const Color gold = Color(0xFFD5B46D);
}

class AppSurfaces {
  const AppSurfaces({
    required this.background,
    required this.surface,
    required this.raised,
    required this.bottomBar,
    required this.border,
    required this.muted,
    required this.text,
  });

  final Color background;
  final Color surface;
  final Color raised;
  final Color bottomBar;
  final Color border;
  final Color muted;
  final Color text;

  static const dark = AppSurfaces(
    background: Color(0xFF101512),
    surface: Color(0xFF1A211C),
    raised: Color(0xFF252E28),
    bottomBar: Color(0xFF191F1B),
    border: Color(0xFF343D35),
    muted: Color(0xFFA7ADA3),
    text: Color(0xFFF2EEE3),
  );

  static const light = AppSurfaces(
    background: Color(0xFFF5F1E7),
    surface: Color(0xFFFFFCF5),
    raised: Color(0xFFECE5D7),
    bottomBar: Color(0xFFFFFCF5),
    border: Color(0xFFE4DCCB),
    muted: Color(0xFF6D756B),
    text: Color(0xFF202B25),
  );

  static AppSurfaces forContext(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) return light;
    return dark;
  }
}

class AppTheme {
  static ThemeData get dark =>
      _buildTheme(brightness: Brightness.dark, palette: AppSurfaces.dark);

  static ThemeData get light =>
      _buildTheme(brightness: Brightness.light, palette: AppSurfaces.light);

  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppSurfaces palette,
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primaryGreen,
          brightness: brightness,
        ).copyWith(
          primary: AppPalette.primaryGreen,
          onPrimary: Colors.white,
          secondary: AppPalette.success,
          onSecondary: Colors.white,
          error: AppPalette.error,
          onError: Colors.white,
          surface: palette.surface,
          onSurface: palette.text,
          onSurfaceVariant: palette.muted,
          outline: palette.border,
          outlineVariant: palette.border,
          surfaceContainerHighest: palette.raised,
        );

    final baseTextTheme = ThemeData(
      brightness: brightness,
      fontFamily: 'sans-serif',
    ).textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      fontFamily: 'sans-serif',
      textTheme: baseTextTheme
          .apply(bodyColor: palette.text, displayColor: palette.text)
          .copyWith(
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.35),
            bodySmall: baseTextTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 1.45,
            ),
            labelLarge: baseTextTheme.labelLarge?.copyWith(fontSize: 14),
            titleMedium: baseTextTheme.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: baseTextTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: false,
      ),
      iconTheme: IconThemeData(color: palette.muted),
      dividerTheme: DividerThemeData(color: palette.border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFF0ECE2)
            : palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: TextStyle(color: palette.muted, fontSize: 14),
        labelStyle: TextStyle(color: palette.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: AppPalette.primaryGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.darkGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.text,
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          minimumSize: const Size.fromHeight(50),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.raised,
        contentTextStyle: TextStyle(color: palette.text),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        titleTextStyle: TextStyle(
          color: palette.text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: palette.muted, height: 1.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
