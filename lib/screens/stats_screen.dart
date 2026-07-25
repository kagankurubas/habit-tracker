import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class StatsScreen extends StatelessWidget {
  final Box<Habit> habitsBox;

  const StatsScreen({super.key, required this.habitsBox});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: habitsBox.listenable(),
      builder: (context, Box<Habit> box, _) {
        final habits = box.values.toList();

        if (habits.isEmpty) {
          return const Center(
            child: Text(
              'Henüz veri yok.\nİstatistikleri görmek için birkaç görev ekleyin!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
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
          final s = h.calculateStreak();
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

          // 🎯 GÜNCELLENEN MANTIK:
          // O günün hedefi = (Normalde o gün hedef olanlar) + (O gün henüz hedef gözükmese de bugün başlanıp TAMAMLATILANLAR)
          final dayTargets = habits.where((h) {
            final isTarget = h.isTargetDate(checkDate);
            final isDoneOnDate = h.isCompletedOn(checkDate);
            
            // Eğer o gün hedefse VEYA o gün tamamlandıysa bunu hedeflere dahil et!
            return isTarget || isDoneOnDate;
          }).toList();

          // O gün tamamlananlar
          final dayDone = dayTargets.where((h) => h.isCompletedOn(checkDate)).length;

          // Yüzde Hesabı
          double ratio = 0.0;
          if (dayTargets.isNotEmpty) {
            ratio = dayDone / dayTargets.length;
          }

          last7DaysRatios.add(ratio);

          final weekdayName = last7DaysLabels[checkDate.weekday - 1];
          current7DaysLabels.add(i == 0 ? 'Bugün' : weekdayName);
        }
        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          appBar: AppBar(
            title: const Text('Genel İstatistikler & Başarı'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatMetricCard(
                      title: 'Bugünkü Başarı',
                      value: '%${(todayProgress * 100).toInt()}',
                      subtitle: '${todayTargets.length} Görevden $todayCompleted Yapıldı',
                      icon: Icons.donut_large_rounded,
                      color: const Color(0xFF10B981),
                    ),
                    _buildStatMetricCard(
                      title: 'En Uzun Zincir',
                      value: '🔥 $maxStreak Gün',
                      subtitle: bestStreakHabit != null ? bestStreakHabit.title : 'Henüz Yok',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                    _buildStatMetricCard(
                      title: 'Toplam Tamamlama',
                      value: '$totalCompletions Kez',
                      subtitle: 'Tüm Zamanlar',
                      icon: Icons.task_alt_rounded,
                      color: const Color(0xFF3B82F6),
                    ),
                    _buildStatMetricCard(
                      title: 'Aktif Rutinler',
                      value: '${habits.length} Rutin',
                      subtitle: 'Takip Ediliyor',
                      icon: Icons.auto_awesome_rounded,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Haftalık Performans Grafiği',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: SizedBox(
                    height: 140,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final ratio = last7DaysRatios[index];
                        final label = current7DaysLabels[index];
                        final isToday = index == 6;

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '%${(ratio * 100).toInt()}',
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 24,
                              height: 90 * ratio < 6 ? 6 : 90 * ratio,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0xFF10B981)
                                    : (ratio > 0 ? const Color(0xFF3B82F6) : Colors.white10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              style: TextStyle(
                                color: isToday ? const Color(0xFF10B981) : Colors.grey,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'En İstikrarlı Rutinleriniz',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: habits.length > 3 ? 3 : habits.length,
                  itemBuilder: (context, index) {
                    final sortedHabits = List<Habit>.from(habits)
                      ..sort((a, b) => b.calculateStreak().compareTo(a.calculateStreak()));
                    final h = sortedHabits[index];
                    final streak = h.calculateStreak();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: h.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: h.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: h.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(h.icon, color: h.color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  'Toplam ${h.completedDatesList.length} Gün Tamamlandı',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Text(
                              '🔥 $streak Gün',
                              style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}