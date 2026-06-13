import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/screen_layout.dart';
import '../../data/models/journal_entry.dart';
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
  final _formKey = GlobalKey();
  String? _editingId;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _isEditing => _editingId != null;

  void _startEditing(JournalEntry entry) {
    setState(() {
      _editingId = entry.id;
      _title.text = entry.title;
      _body.text = entry.body;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _formKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _title.clear();
      _body.clear();
    });
  }

  void _submit(SanctuaryState state) {
    final l10n = context.l10n;
    final title = _title.text;
    final body = _body.text;

    final ok = _isEditing
        ? state.updateJournalEntry(id: _editingId!, title: title, body: body)
        : state.saveReflection(title: title, body: body);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.notesEmptyBodyError)),
      );
      return;
    }

    final wasEditing = _isEditing;
    _clearForm();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(wasEditing ? l10n.notesUpdated : l10n.notesSaved),
        duration: const Duration(seconds: 2),
      ),
    );
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
                      selected: _editingId == e.id,
                      onTap: () => _startEditing(e),
                      onDelete: () {
                        if (_editingId == e.id) _clearForm();
                        state.deleteJournalEntry(e.id);
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
                  _isEditing ? l10n.notesEdit : l10n.notesDailyEntry,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Container(
                  key: _formKey,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: _isEditing
                        ? Border.all(
                            color: AppColors.sage.withValues(alpha: 0.7),
                            width: 1.5,
                          )
                        : null,
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
                            onPressed: _clearForm,
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
                              onPressed: () => _submit(state),
                              child: Text(
                                _isEditing ? l10n.notesUpdate : l10n.notesSave,
                              ),
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
