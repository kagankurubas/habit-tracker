import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/habit.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final DateTime _focusedDay = DateTime.now();
  int _selectedViewIndex = 0;

  // 🎯 HEDEF GÜN İÇİN SABİT SARI RENK
  static const Color targetDayColor = Color(0xFFF59E0B);

  Map<DateTime, int> _getHeatmapDatasets() {
    final Map<DateTime, int> datasets = {};
    for (final date in widget.habit.completedDatesList) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      datasets[normalizedDate] = 1;
    }
    return datasets;
  }

  Widget _buildLegendItem(Color color, String label, Color subtextColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: subtextColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.habit.currentStreak;
    final isDoneToday = widget.habit.isCompletedOn(DateTime.now());
    final themeColor = widget.habit.color;

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final textColor = AppThemes.getTextColor(bgColor);
        final subtextColor = AppThemes.getSubtextColor(bgColor);
        final cardColor = AppThemes.getCardColor(bgColor);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Row(
              children: [
                Icon(widget.habit.icon, color: themeColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.habit.title,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            iconTheme: IconThemeData(color: textColor),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // DİNAMİK TEMALI ÖZET KARTI
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        themeColor.withValues(alpha: 0.25),
                        cardColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Mevcut Zincir', style: TextStyle(color: subtextColor, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '🔥 $streak Gün',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: themeColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(height: 30, width: 1, color: subtextColor.withValues(alpha: 0.2)),
                            Column(
                              children: [
                                Text('Sıklık', style: TextStyle(color: subtextColor, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '🔄 ${widget.habit.frequencyText}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(height: 30, width: 1, color: subtextColor.withValues(alpha: 0.2)),
                            Column(
                              children: [
                                Text('Toplam', style: TextStyle(color: subtextColor, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '✅ ${widget.habit.totalCompletedDays} Gün',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: subtextColor.withValues(alpha: 0.2)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDoneToday ? Colors.green : themeColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              setState(() {
                                widget.habit.toggleDate(DateTime.now());
                              });
                              await widget.habit.save();
                            },
                            icon: Icon(
                              isDoneToday ? Icons.check_circle : Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            label: Text(
                              isDoneToday ? 'Bugün Tamamlandı 🎉' : 'Bugün Tamamlandı Olarak İşaretle',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // GÖRÜNÜM SEÇİMİ (HEATMAP & TAKVİM SEÇİCİ)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'İstikrar Raporu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
                    ),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text('Heatmap', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.grid_on, size: 16),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('Takvim', style: TextStyle(fontSize: 12)),
                          icon: Icon(Icons.calendar_month, size: 16),
                        ),
                      ],
                      selected: {_selectedViewIndex},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _selectedViewIndex = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // DİNAMİK KART / HEATMAP & TAKVİM
                Card(
                  color: cardColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _selectedViewIndex == 0
                        ? IgnorePointer(
                            child: HeatMap(
                              datasets: _getHeatmapDatasets(),
                              colorMode: ColorMode.color,
                              defaultColor: AppThemes.isLightBackground(bgColor)
                                  ? Colors.grey.shade300
                                  : const Color(0xFF334155),
                              textColor: textColor,
                              showColorTip: false,
                              showText: true,
                              scrollable: true,
                              size: 28,
                              colorsets: {
                                1: themeColor,
                              },
                            ),
                          )
                        : Column(
                            children: [
                              TableCalendar(
                                firstDay: DateTime.utc(2024, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                                  leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                                  rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  prioritizedBuilder: (context, day, focusedDay) {
                                    final isDone = widget.habit.isCompletedOn(day);
                                    final isTarget = widget.habit.isTargetDate(day);

                                    Color itemBgColor = Colors.transparent;
                                    Color itemTextColor = subtextColor.withValues(alpha: 0.6);

                                    if (isDone) {
                                      itemBgColor = Colors.green;
                                      itemTextColor = Colors.white;
                                    } else if (isTarget) {
                                      itemBgColor = targetDayColor.withValues(alpha: 0.85);
                                      itemTextColor = Colors.white;
                                    }

                                    return Container(
                                      margin: const EdgeInsets.all(4),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: itemBgColor,
                                        shape: BoxShape.circle,
                                        border: isSameDay(day, DateTime.now()) && !isDone
                                            ? Border.all(color: targetDayColor, width: 2)
                                            : null,
                                      ),
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          color: itemTextColor,
                                          fontWeight: isTarget || isDone ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                onDaySelected: (selectedDay, focusedDay) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Takvim görsel takiptir. Tamamlamaları üstteki butondan yapabilirsiniz!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              Divider(color: subtextColor.withValues(alpha: 0.2)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildLegendItem(Colors.green, 'Yapıldı', subtextColor),
                                  _buildLegendItem(targetDayColor, 'Hedef Gün', subtextColor),
                                  _buildLegendItem(subtextColor.withValues(alpha: 0.4), 'Rutin Dışı', subtextColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // İSTATİSTİK ÖZET KARTLARI
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: cardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Column(
                            children: [
                              Text(
                                '%${widget.habit.calculateCompletionRate(lastDays: 30).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: widget.habit.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aylık Başarı',
                                style: TextStyle(fontSize: 11, color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: cardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Column(
                            children: [
                              Text(
                                '%${widget.habit.calculateCompletionRate(lastDays: 7).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Son 7 Gün',
                                style: TextStyle(fontSize: 11, color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: cardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Column(
                            children: [
                              Text(
                                '${widget.habit.totalCompletedDays}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Toplam Gün',
                                style: TextStyle(fontSize: 11, color: subtextColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}