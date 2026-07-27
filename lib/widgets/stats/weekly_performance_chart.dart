import 'package:flutter/material.dart';

class WeeklyPerformanceChart extends StatelessWidget {
  final List<double> last7DaysRatios;
  final List<String> current7DaysLabels;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  const WeeklyPerformanceChart({
    super.key,
    required this.last7DaysRatios,
    required this.current7DaysLabels,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                // ⚡ Liste uzunluğu güvenliği (RangeError önleme)
                final ratio = (index < last7DaysRatios.length ? last7DaysRatios[index] : 0.0).clamp(0.0, 1.0);
                final label = index < current7DaysLabels.length ? current7DaysLabels[index] : '';
                final isToday = index == 6;

                final barHeight = 90 * ratio < 6 ? 6.0 : 90 * ratio;

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
                      height: barHeight,
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
      ],
    );
  }
}