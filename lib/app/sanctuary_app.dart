import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/shell/main_shell.dart';

class SanctuaryApp extends StatelessWidget {
  const SanctuaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resonant Sanctuary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}
