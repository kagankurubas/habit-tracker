import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/badge_model.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';

class StatsScreen extends StatefulWidget {
  final Box<Habit> habitsBox;

  const StatsScreen({super.key, required this.habitsBox});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedBadgeCategory = 'Tüm Rozetler';

  final List<String> _badgeCategories = const [
    'Tüm Rozetler',
    'Genel',
    'Kodlama',
    'Müzik',
    'Oyun Dev.',
    'Spor',
    'Okuma',
    'Gizli',
  ];

  @override
  Widget build(BuildContext context) {
    // 🚀 TEMA DİNLENİYOR
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
            valueListenable: widget.habitsBox.listenable(),
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

                double ratio = 0.0;
                if (dayTargets.isNotEmpty) {
                  ratio = dayDone / dayTargets.length;
                }

                last7DaysRatios.add(ratio);

                final weekdayName = last7DaysLabels[checkDate.weekday - 1];
                current7DaysLabels.add(i == 0 ? 'Bugün' : weekdayName);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. ÖZET METRİK KARTLARI
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStatMetricCard(
                          title: 'Bugünkü Başarı',
                          value: '%${(todayProgress * 100).toInt()}',
                          subtitle: '${todayTargets.length} Görevden $todayCompleted Yapıldı',
                          icon: Icons.donut_large_rounded,
                          color: const Color(0xFF10B981),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _buildStatMetricCard(
                          title: 'En Uzun Zincir',
                          value: '🔥 $maxStreak Gün',
                          subtitle: bestStreakHabit != null ? bestStreakHabit.title : 'Henüz Yok',
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF59E0B),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _buildStatMetricCard(
                          title: 'Toplam Tamamlama',
                          value: '$totalCompletions Kez',
                          subtitle: 'Tüm Zamanlar',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF3B82F6),
                          cardColor: cardColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                        ),
                        _buildStatMetricCard(
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
                    const SizedBox(height: 24),

                    // 2. HAFTALIK PERFORMANS GRAFİĞİ
                    Text(
                      'Haftalık Performans Grafiği',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: subtextColor.withValues(alpha: 0.15)),
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
                                  style: TextStyle(color: subtextColor, fontSize: 10),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 24,
                                  height: 90 * ratio < 6 ? 6 : 90 * ratio,
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? const Color(0xFF10B981)
                                        : (ratio > 0
                                            ? const Color(0xFF3B82F6)
                                            : subtextColor.withValues(alpha: 0.15)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  label,
                                  style: TextStyle(
                                    color: isToday ? const Color(0xFF10B981) : subtextColor,
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

                    // 3. EN İSTİKRARLI RUTİNLER
                    Text(
                      'En İstikrarlı Rutinleriniz',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length > 3 ? 3 : habits.length,
                      itemBuilder: (context, index) {
                        final sortedHabits = List<Habit>.from(habits)
                          ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
                        final h = sortedHabits[index];
                        final streak = h.currentStreak;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppThemes.isLightBackground(bgColor)
                                ? Colors.black.withValues(alpha: 0.05)
                                : h.color.withValues(alpha: 0.12),
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
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                    Text(
                                      'Toplam ${h.completedDatesList.length} Gün Tamamlandı',
                                      style: TextStyle(color: subtextColor, fontSize: 12),
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
                                  style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                    // 4. BAŞARIMLAR VE ROZETLER (Kategori Filtreli)
                    _buildBadgesSection(habits, cardColor, textColor, subtextColor),
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

  Widget _buildBadgesSection(
    List<Habit> habits,
    Color cardColor,
    Color textColor,
    Color subtextColor,
  ) {
    // 1. Kategorisine göre filtreleme yapıyoruz
    final filteredBadges = _selectedBadgeCategory == 'Tüm Rozetler'
        ? allBadges
        : allBadges.where((b) => b.category == _selectedBadgeCategory).toList();

    // 2. Kazanılanlar üstte görünecek şekilde sıralıyoruz
    final sortedBadges = List<HabitBadge>.from(filteredBadges)
      ..sort((a, b) {
        final aUnlocked = a.isUnlocked(habits);
        final bUnlocked = b.isUnlocked(habits);
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;
        return 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Başarımlar & Rozetler 🏆',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),

        // 🏷️ ROZET KATEGORİ FİLTRE ÇUBUĞU
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _badgeCategories.length,
            itemBuilder: (context, index) {
              final cat = _badgeCategories[index];
              final isSelected = _selectedBadgeCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFF6366F1),
                  backgroundColor: cardColor,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedBadgeCategory = cat;
                    });
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // 🏆 ROZET GRID LISTESI
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: sortedBadges.length,
          itemBuilder: (context, index) {
            final badge = sortedBadges[index];
            final unlocked = badge.isUnlocked(habits);

            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Image.asset(badge.imagePath, width: 44, height: 44),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            badge.title,
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge.description,
                          style: TextStyle(color: subtextColor, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: unlocked
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            unlocked ? 'Kazanıldı 🎉' : 'Kilitli 🔒',
                            style: TextStyle(
                              color: unlocked ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unlocked ? Colors.amber.withValues(alpha: 0.6) : subtextColor.withValues(alpha: 0.15),
                    width: unlocked ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: unlocked ? 1.0 : 0.35,
                        child: ColorFiltered(
                          colorFilter: unlocked
                              ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                              : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                          child: Image.asset(
                            badge.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.stars_rounded, size: 40, color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      badge.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked ? textColor : subtextColor.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subtextColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}