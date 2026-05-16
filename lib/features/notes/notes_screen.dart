import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/screen_layout.dart';
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
    final state = context.watch<SanctuaryState>();
    final now = DateFormat('MMM d, y · h:mm a').format(DateTime.now());

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
                    Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                const SizedBox(height: 8),
                ...state.journalEntries.map((e) => TimelineItem(entry: e)),
                const SizedBox(height: 20),
                Text(
                  'Today\'s Pulse',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'How are your thoughts flowing right now?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Steady', 'Vibrant', 'Foggy', 'Gentle']
                      .map(
                        (label) => SanctuaryChip(
                          label: label,
                          selected: state.notesPulse == label,
                          onTap: () => state.setNotesPulse(label),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                Text('Daily Entry', style: Theme.of(context).textTheme.titleLarge),
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
                        decoration: const InputDecoration(
                          hintText: 'Title your reflection…',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(now, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.format_bold),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.format_italic),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.format_list_bulleted),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.format_quote_rounded),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.image_outlined),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.mic_none_rounded),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _body,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: 'Start writing from the heart…',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          const SanctuaryChip(label: 'Personal', filled: true),
                          const SanctuaryChip(label: 'Gratitude', filled: true),
                          ActionChip(
                            label: const Text('+'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              _title.clear();
                              _body.clear();
                            },
                            child: const Text('Discard'),
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
                                await state.saveReflection(
                                  title: _title.text,
                                  body: _body.text,
                                  tags: const ['Personal', 'Gratitude'],
                                );
                                if (context.mounted) {
                                  _title.clear();
                                  _body.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Reflection saved'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Save Reflection'),
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
