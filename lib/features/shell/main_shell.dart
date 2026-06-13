import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/sanctuary_state.dart';
import '../../widgets/sanctuary_bottom_nav.dart';
import '../history/history_screen.dart';
import '../listen/listen_screen.dart';
import '../me/me_screen.dart';
import '../notes/notes_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final index = context.watch<SanctuaryState>().tabIndex;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          ListenScreen(),
          HistoryScreen(),
          NotesScreen(),
          MeScreen(),
        ],
      ),
      bottomNavigationBar: SanctuaryBottomNav(
        currentIndex: index,
        onSelect: context.read<SanctuaryState>().setTab,
      ),
    );
  }
}
