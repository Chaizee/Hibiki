import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.person_outline,
        'Personal Information',
        'Update your details and avatar',
        false,
      ),
      (
        Icons.notifications_none_rounded,
        'Mindfulness Reminders',
        'Push notifications and schedule',
        false,
      ),
      (
        Icons.shield_outlined,
        'Privacy & Security',
        'Manage your data and encryption',
        false,
      ),
      (
        Icons.logout,
        'Sign Out',
        'Securely exit your account',
        true,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...items.map(
                  (e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.white,
                      foregroundColor:
                          e.$4 ? const Color(0xFFB45353) : AppColors.forest,
                      child: Icon(e.$1),
                    ),
                    title: Text(
                      e.$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: e.$4
                            ? const Color(0xFFB45353)
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(e.$3),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
