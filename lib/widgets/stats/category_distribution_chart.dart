import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/habit.dart';

class CategoryDistributionChart extends StatefulWidget {
  final List<Habit> habits;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  const CategoryDistributionChart({
    super.key,
    required this.habits,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  State<CategoryDistributionChart> createState() =>
      _CategoryDistributionChartState();
}

class _CategoryDistributionChartState extends State<CategoryDistributionChart> {
  int _touchedIndex = -1;

  // ⚡ KATEGORİ TEMİZLEME YARDIMCISI
  static String _cleanCategoryName(String rawCategory) {
    String name = rawCategory.trim();
    if (name.endsWith('.')) {
      name = name.substring(0, name.length - 1).trim();
    }
    return name.isEmpty ? 'Genel' : name;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Kategori bazında toplam tamamlama sayılarını hesaplayalım
    final Map<String, int> categoryCompletions = {};
    final Map<String, Color> categoryColors = {};
    int totalCount = 0;

    for (final habit in widget.habits) {
      final categoryName = _cleanCategoryName(habit.category);
      final count = habit.completedDatesList.length;

      if (count > 0) {
        categoryCompletions[categoryName] =
            (categoryCompletions[categoryName] ?? 0) + count;
        categoryColors[categoryName] = habit.color;
        totalCount += count;
      }
    }

    if (totalCount == 0) {
      return const SizedBox.shrink(); // Henüz tamamlama yoksa gizle
    }

    final categories = categoryCompletions.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Dağılımı',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.subtextColor.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // DONUT PASTA GRAFİK
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!
                                      .touchedSectionIndex;
                                });
                              },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 55,
                        sections: List.generate(categories.length, (i) {
                          final isTouched = i == _touchedIndex;
                          final fontSize = isTouched ? 16.0 : 12.0;
                          final radius = isTouched ? 36.0 : 30.0;
                          final catName = categories[i];
                          final count = categoryCompletions[catName]!;
                          final percentage = (count / totalCount) * 100;
                          final color =
                              categoryColors[catName] ??
                              const Color(0xFF6366F1);

                          return PieChartSectionData(
                            color: color,
                            value: count.toDouble(),
                            title: '%${percentage.toInt()}',
                            radius: radius,
                            titleStyle: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(color: Colors.black45, blurRadius: 2),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    // HALKA ORTASI MERKEZ BİLGİSİ
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$totalCount',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                        ),
                        Text(
                          'Tamamlama',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // LEJAND / KATEGORİ RENK LİSTESİ
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: categories.map((catName) {
                  final color =
                      categoryColors[catName] ?? const Color(0xFF6366F1);
                  final count = categoryCompletions[catName]!;
                  final percentage = ((count / totalCount) * 100)
                      .toStringAsFixed(0);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$catName (%$percentage)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.textColor,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
