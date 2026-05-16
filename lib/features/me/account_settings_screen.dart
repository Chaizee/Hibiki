import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_locale.dart';
import '../../l10n/l10n_extensions.dart';
import '../../state/locale_controller.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeController = context.watch<LocaleController>();

    final items = [
      (
        Icons.person_outline,
        l10n.settingsPersonalTitle,
        l10n.settingsPersonalSubtitle,
        false,
      ),
      (
        Icons.notifications_none_rounded,
        l10n.settingsRemindersTitle,
        l10n.settingsRemindersSubtitle,
        false,
      ),
      (
        Icons.shield_outlined,
        l10n.settingsPrivacyTitle,
        l10n.settingsPrivacySubtitle,
        false,
      ),
      (
        Icons.logout,
        l10n.settingsSignOutTitle,
        l10n.settingsSignOutSubtitle,
        true,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.accountSettings),
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
                Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SegmentedButton<AppLocale>(
                  segments: [
                    ButtonSegment(
                      value: AppLocale.en,
                      label: Text(l10n.languageEnglish),
                    ),
                    ButtonSegment(
                      value: AppLocale.ru,
                      label: Text(l10n.languageRussian),
                    ),
                  ],
                  selected: {localeController.locale},
                  onSelectionChanged: (set) {
                    localeController.setLocale(set.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
