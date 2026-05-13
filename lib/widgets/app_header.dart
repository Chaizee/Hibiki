import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.onSettings});

  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.mint,
            child: Icon(Icons.pets, color: AppColors.forestDeep),
          ),
          Expanded(
            child: Text(
              'Resonant Sanctuary',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.forest,
              ),
            ),
          ),
          IconButton(
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.forest,
          ),
        ],
      ),
    );
  }
}
