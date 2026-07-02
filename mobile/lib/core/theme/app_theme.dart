import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const FlexScheme _scheme = FlexScheme.indigo;

  static ThemeData get light => FlexThemeData.light(
    scheme: _scheme,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 9,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 10,
      blendOnColors: false,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      cardRadius: 16.0,
      elevatedButtonRadius: 10.0,
      inputDecoratorRadius: 10.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
  );

  static ThemeData get dark => FlexThemeData.dark(
    scheme: _scheme,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 15,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      useTextTheme: true,
      useM2StyleDividerInM3: true,
      cardRadius: 16.0,
      elevatedButtonRadius: 10.0,
      inputDecoratorRadius: 10.0,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ),
  );
}