import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/main_shell.dart';
import '../state/locale_controller.dart';

class SanctuaryApp extends StatelessWidget {
  const SanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();

    return MaterialApp(
      title: 'Resonant Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: locale.locale.flutterLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShell(),
    );
  }
}
