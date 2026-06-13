import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/screen_layout.dart';
import '../../data/models/recommendation.dart';
import '../../l10n/l10n_extensions.dart';
import '../../l10n/mood_result_l10n.dart';
import '../../state/sanctuary_state.dart';
import '../../widgets/mood_card.dart';

class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<SanctuaryState>();
    final result = state.lastResult;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: ScreenLayout.screenPadding(context).copyWith(bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      height: 1.15,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(text: l10n.listenTitle1),
                      TextSpan(
                        text: l10n.listenTitleEmphasis,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      TextSpan(text: l10n.listenTitle2),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.listenSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                MoodCard(
                  moodLabel: result != null
                      ? result.localizedMoodLabel(l10n)
                      : l10n.moodSerene,
                  tags: result?.localizedTags(l10n) ??
                      [l10n.tagConsistent, l10n.tagWarm],
                  stressLevel: result?.stressLevel ?? 24,
                  stressCaption: l10n.stressLevel(
                    (result?.stressLevel ?? 24).round(),
                  ),
                ),
                const SizedBox(height: 28),
                Center(child: _RecordOrb(state: state)),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    switch (state.phase) {
                      VoiceSessionPhase.recording => l10n.listenRecordingHint,
                      VoiceSessionPhase.processing => l10n.listenProcessingHint,
                      _ => l10n.listenRecordHint,
                    },
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (state.lastError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.lastError!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.listenPersonalized,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => state.refreshRecommendations(),
                      child: Text(l10n.viewAll),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.recommendations.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final r = state.recommendations[i];
                      return _RecoCard(reco: r, wide: i == 0);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _PeakInsightCard(
                  stress: result?.stressLevel ?? 28,
                  onLog: () {},
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

class _RecordOrb extends StatelessWidget {
  const _RecordOrb({required this.state});

  final SanctuaryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recording = state.phase == VoiceSessionPhase.recording;
    final busy = state.phase == VoiceSessionPhase.processing;

    return GestureDetector(
      onTap: busy ? null : () => state.toggleRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        width: 168,
        height: 168,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: recording
                ? [AppColors.sage, AppColors.forest]
                : [AppColors.sageLight, AppColors.sage],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.sage.withValues(alpha: 0.45),
              blurRadius: recording ? 36 : 22,
              spreadRadius: recording ? 2 : 0,
            ),
          ],
        ),
        child: busy
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(36),
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic_none_rounded,
                    size: 40,
                    color: AppColors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recording ? l10n.stop : l10n.record,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RecoCard extends StatelessWidget {
  const _RecoCard({required this.reco, this.wide = false});

  final Recommendation reco;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = l10n.recoTitle(reco.id);
    final subtitle = l10n.recoSubtitle(reco.id);

    return Container(
      width: wide ? 220 : 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wide)
            Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.mintSoft, AppColors.mint],
                ),
              ),
              child: const Center(
                child: Icon(Icons.waves, color: AppColors.forest),
              ),
            )
          else
            CircleAvatar(
              backgroundColor: AppColors.mint,
              child: Icon(reco.icon, color: AppColors.forest),
            ),
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (reco.durationLabel != null)
            Text(
              reco.durationLabel!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _PeakInsightCard extends StatelessWidget {
  const _PeakInsightCard({required this.stress, required this.onLog});

  final double stress;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vibrant = stress < 35;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.mint,
            child: Icon(Icons.pets, color: AppColors.forestDeep, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vibrant ? l10n.peakVibrant : l10n.peakTense,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onLog,
                  child: Text(l10n.logMoment),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
