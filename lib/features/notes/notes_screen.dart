import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/screen_layout.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/l10n_extensions.dart';
import '../../state/sanctuary_state.dart';
import '../../widgets/sanctuary_chip.dart';
import '../../widgets/timeline_item.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SanctuaryState>();
    final now = DateFormat('MMM d, y · h:mm a').format(DateTime.now());
    const pulseKeys = AppStrings.pulseKeys;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: ScreenLayout.screenPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.notesTimeline,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.journalEntries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.notesEmptyList,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  ...state.journalEntries.map(
                    (e) => TimelineItem(
                      entry: e,
                      onDelete: () async {
                        await state.deleteJournalEntry(e.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.notesDeleted)),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  l10n.notesPulse,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.notesPulseHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: pulseKeys
                      .map(
                        (key) => SanctuaryChip(
                          label: l10n.pulseLabel(key),
                          selected: state.notesPulseKey == key,
                          onTap: () => state.setNotesPulseKey(key),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.notesDailyEntry,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.forest.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _title,
                        decoration: InputDecoration(
                          hintText: l10n.notesTitleHint,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(now, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _body,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: l10n.notesBodyHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              _title.clear();
                              _body.clear();
                            },
                            child: Text(l10n.notesDiscard),
                          ),
                          const Spacer(),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [AppColors.sageLight, AppColors.sage],
                              ),
                            ),
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () async {
                                final saved = await state.saveReflection(
                                  title: _title.text,
                                  body: _body.text,
                                );
                                if (!context.mounted) return;
                                if (saved) {
                                  _title.clear();
                                  _body.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.notesSaved)),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.notesEmptyBodyError),
                                    ),
                                  );
                                }
                              },
                              child: Text(l10n.notesSave),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
