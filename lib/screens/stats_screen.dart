import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';
import '../widgets/stats/stat_metric_card.dart';
import '../widgets/stats/smart_insight_card.dart';
import '../widgets/stats/weekly_performance_chart.dart';
import '../widgets/stats/badges_section.dart';

class StatsScreen extends StatelessWidget {
  final Box<Habit> habitsBox;

  const StatsScreen({super.key, required this.habitsBox});

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
              'Genel İstatistikler & Başarı',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ValueListenableBuilder(
            valueListenable: habitsBox.listenable(),
            builder: (context, Box<Habit> box, _) {
              final habits = box.values.toList();

              if (habits.isEmpty) {
                return Center(
                  child: Text(
                    'Henüz veri yok.\nİstatistikleri görmek için birkaç görev ekleyin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtextColor, fontSize: 16),
                  ),
                );
              }

              final today = DateTime.now();
              final todayNormalized = DateTime(today.year, today.month, today.day);

              final todayTargets = habits.where((h) => h.isTargetDate(todayNormalized)).toList();
              final todayCompleted = todayTargets.where((h) => h.isCompletedOn(todayNormalized)).length;
              final todayProgress = todayTargets.isNotEmpty ? (todayCompleted / todayTargets.length) : 0.0;

              int totalCompletions = 0;
              for (var h in habits) {
                totalCompletions += h.completedDatesList.length;
              }

              Habit? bestStreakHabit;
              int maxStreak = 0;
              for (var h in habits) {
                final s = h.currentStreak;
                if (s > maxStreak) {
                  maxStreak = s;
                  bestStreakHabit = h;
                }
              }

              List<double> last7DaysRatios = [];
              List<String> last7DaysLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
              List<String> current7DaysLabels = [];

              for (int i = 6; i >= 0; i--) {
                final checkDate = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));

                final dayTargets = habits.where((h) {
                  final isTarget = h.isTargetDate(checkDate);
                  final isDoneOnDate = h.isCompletedOn(checkDate);
                  return isTarget || isDoneOnDate;
                }).toList();

                final dayDone = dayTargets.where((h) => h.isCompletedOn(checkDate)).length;

                double ratio = dayTargets.isNotEmpty ? (dayDone / dayTargets.length) : 0.0;
                last7DaysRatios.add(ratio);

                final weekdayName = last7DaysLabels[checkDate.weekday - 1];
                current7DaysLabels.add(i == 0 ? 'Bugün' : weekdayName);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ÖZET METRİK KARTLARI GRID
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatMetricCard(
                          title: 'Bugünkü Başarı',
                          value: '%${(todayProgress * 100).toInt()}',
                          subtitle: '${todayTargets.length} Görevden $todayCompleted Yapıldı',
                          icon: Icons.donut_large_rounded,
                          color: const Color(0xFF10B981),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        StatMetricCard(
                          title: 'En Uzun Zincir',
                          value: '🔥 $maxStreak Gün',
                          subtitle: bestStreakHabit != null ? bestStreakHabit.title : 'Henüz Yok',
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF59E0B),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        StatMetricCard(
                          title: 'Toplam Tamamlama',
                          value: '$totalCompletions Kez',
                          subtitle: 'Tüm Zamanlar',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF3B82F6),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        StatMetricCard(
                          title: 'Aktif Rutinler',
                          value: '${habits.length} Rutin',
                          subtitle: 'Takip Ediliyor',
                          icon: Icons.auto_awesome_rounded,
                          color: const Color(0xFF8B5CF6),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 2. AKILLI RUTİN ANALİZİ KARTI
                    SmartInsightCard(
                      habits: habits,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),

                    const SizedBox(height: 24),

                    // 3. HAFTALIK PERFORMANS GRAFİĞİ
                    WeeklyPerformanceChart(
                      last7DaysRatios: last7DaysRatios,
                      current7DaysLabels: current7DaysLabels,
                      cardColor: cardColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),

                    const SizedBox(height: 24),

                    // 4. BAŞARIMLAR VE ROZETLER SEKSİYONU
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