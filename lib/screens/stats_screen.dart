import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';
import '../widgets/stats/stat_metric_card.dart';
import '../widgets/stats/smart_insight_card.dart';
import '../widgets/stats/weekly_performance_chart.dart';
import '../widgets/stats/badges_section.dart';
import '../widgets/stats/category_distribution_chart.dart';
import '../widgets/stats/share_stats_card.dart';
import '../services/share_service.dart';

class StatsScreen extends StatelessWidget {
  final Box<Habit> habitsBox;
  final GlobalKey _shareCardKey = GlobalKey();

  static const List<String> _dayLabels = [
    'mon_short',
    'tue_short',
    'wed_short',
    'thu_short',
    'fri_short',
    'sat_short',
    'sun_short',
  ];

  StatsScreen({super.key, required this.habitsBox});

  void _showShareDialog(
    BuildContext context,
    List<Habit> habits,
    Color cardColor,
    Color textColor,
    Color subtextColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          'share_progress'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShareStatsCard(habits: habits, globalKey: _shareCardKey),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ShareService.shareWidgetAsImage(_shareCardKey);
                },
                icon: const Icon(Icons.ios_share_rounded, size: 20),
                label: Text(
                  'share_as_image'.tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final textColor = AppThemes.getTextColor(bgColor);
        final subtextColor = AppThemes.getSubtextColor(bgColor);
        final cardColor = AppThemes.getCardColor(bgColor);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(
              'general_stats_title'.tr(),
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: textColor),
                tooltip: 'share_stats'.tr(),
                onPressed: () {
                  final habits = habitsBox.values.toList();
                  if (habits.isNotEmpty) {
                    _showShareDialog(
                      context,
                      habits,
                      cardColor,
                      textColor,
                      subtextColor,
                    );
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable: habitsBox.listenable(),
            builder: (context, Box<Habit> box, _) {
              final habits = box.values.toList();

              if (habits.isEmpty) {
                return Center(
                  child: Text(
                    'no_stats_data'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtextColor, fontSize: 16),
                  ),
                );
              }

              final today = DateTime.now();
              final todayNormalized = DateTime(
                today.year,
                today.month,
                today.day,
              );

              final todayTargets = habits
                  .where((h) => h.isTargetDate(todayNormalized))
                  .toList();
              final todayCompleted = todayTargets
                  .where((h) => h.isCompletedOn(todayNormalized))
                  .length;
              final todayProgress = todayTargets.isNotEmpty
                  ? (todayCompleted / todayTargets.length)
                  : 0.0;

              final int totalCompletions = habits.fold<int>(
                0,
                (sum, h) => sum + h.completedDatesList.length,
              );

              Habit? bestStreakHabit;
              int maxStreak = 0;
              for (final h in habits) {
                final s = h.currentStreak;
                if (s > maxStreak) {
                  maxStreak = s;
                  bestStreakHabit = h;
                }
              }

              final List<double> last7DaysRatios = [];
              final List<String> current7DaysLabels = [];

              for (int i = 6; i >= 0; i--) {
                final checkDate = todayNormalized.subtract(Duration(days: i));

                final dayTargets = habits.where((h) {
                  final isTarget = h.isTargetDate(checkDate);
                  final isDoneOnDate = h.isCompletedOn(checkDate);
                  return isTarget || isDoneOnDate;
                }).toList();

                final dayDone = dayTargets
                    .where((h) => h.isCompletedOn(checkDate))
                    .length;

                final double ratio = dayTargets.isNotEmpty
                    ? (dayDone / dayTargets.length)
                    : 0.0;
                last7DaysRatios.add(ratio);

                final weekdayName = _dayLabels[checkDate.weekday - 1].tr();
                current7DaysLabels.add(i == 0 ? 'today'.tr() : weekdayName);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatMetricCard(
                          title: 'todays_success'.tr(),
                          value: '%${(todayProgress * 100).toInt()}',
                          subtitle: 'tasks_completed_out_of'.tr(
                            args: [
                              todayTargets.length.toString(),
                              todayCompleted.toString(),
                            ],
                          ),
                          icon: Icons.donut_large_rounded,
                          color: const Color(0xFF10B981),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        StatMetricCard(
                          title: 'longest_streak_title'.tr(),
                          value: maxStreak > 0
                              ? '🔥 ${'x_days'.tr(args: [maxStreak.toString()])}'
                              : 'not_yet'.tr(),
                          subtitle: bestStreakHabit != null
                              ? bestStreakHabit.title
                              : 'not_yet'.tr(),
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF59E0B),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        StatMetricCard(
                          title: 'total_completions'.tr(),
                          value: '$totalCompletions ${'x_times'.tr(args: [''])}'
                              .trim(),
                          subtitle: 'all_time'.tr(),
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF3B82F6),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        StatMetricCard(
                          title: 'active_routines'.tr(),
                          value:
                              '${habits.length} ${'x_routines'.tr(args: [''])}'
                                  .trim(),
                          subtitle: 'being_tracked'.tr(),
                          icon: Icons.auto_awesome_rounded,
                          color: const Color(0xFF8B5CF6),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SmartInsightCard(
                      habits: habits,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),

                    const SizedBox(height: 24),

                    WeeklyPerformanceChart(
                      last7DaysRatios: last7DaysRatios,
                      current7DaysLabels: current7DaysLabels,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),

                    const SizedBox(height: 24),

                    CategoryDistributionChart(
                      habits: habits,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),

                    const SizedBox(height: 24),

                    BadgesSection(
                      habits: habits,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
