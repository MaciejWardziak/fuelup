import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/station_providers.dart';
import 'data/services/theme_service.dart';
import 'data/services/locale_service.dart';
import 'core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedTheme = await ThemeService.load();
  final savedLocale = await LocaleService.load();
  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => savedTheme),
        localeProvider.overrideWith((ref) => savedLocale),
      ],
      child: const FuelUpApp(),
    ),
  );
}

class FuelUpApp extends ConsumerWidget {
  const FuelUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'FuelUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: ref.watch(localeProvider),
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pl'),
        Locale('en'),
      ],
    );
  }
}