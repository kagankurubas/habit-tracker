import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/habit.dart';

class ShareStatsCard extends StatelessWidget {
  final List<Habit> habits;
  final GlobalKey globalKey;

  const ShareStatsCard({
    super.key,
    required this.habits,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    final totalCompletions = habits.fold<int>(
      0,
      (sum, h) => sum + h.completedDatesList.length,
    );

    int maxStreak = 0;
    Habit? bestHabit;

    for (final h in habits) {
      if (h.currentStreak > maxStreak) {
        maxStreak = h.currentStreak;
        bestHabit = h;
      }
    }

    return RepaintBoundary(
      key: globalKey,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFA5B4FC),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'routine_tracking'.tr(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'consistency_report'.tr(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Center(
              child: Column(
                children: [
                  Text(
                    '🔥 ${'longest_streak_title'.tr()}',
                    style: TextStyle(
                      color: Color(0xFFC7D2FE),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'x_days'.tr(args: [maxStreak.toString()]),
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  if (bestHabit != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      bestHabit.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'total_completions'.tr(),
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x_times'.tr(args: [totalCompletions.toString()]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'active_routines'.tr(),
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'x_routines'.tr(args: [habits.length.toString()]),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Center(
              child: Text(
                'share_motto'.tr(),
                style: TextStyle(
                  color: Colors.indigo.shade100,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
