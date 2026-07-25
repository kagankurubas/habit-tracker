import 'habit.dart';

class HabitBadge {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final bool Function(List<Habit> habits) isUnlocked;

  HabitBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isUnlocked,
  });
}

// 🏆 TÜM ROZETLER VE AÇILMA ŞARTLARI
final List<HabitBadge> allBadges = [
  HabitBadge(
    id: 'first_step',
    title: 'İlk Adım',
    description: 'En az 1 rutini tamamla',
    imagePath: 'assets/badges/first_step.png',
    isUnlocked: (habits) {
      return habits.any((h) => h.completedDatesList.isNotEmpty);
    },
  ),
  HabitBadge(
    id: 'streak_3',
    title: 'Alev Alev',
    description: 'Bir rutinde 3 günlük seriye ulaş',
    imagePath: 'assets/badges/streak_3.png',
    isUnlocked: (habits) {
      return habits.any((h) => h.currentStreak >= 3);
    },
  ),
  HabitBadge(
    id: 'streak_7',
    title: 'İrade Ustası',
    description: 'Bir rutinde 7 günlük seriye ulaş',
    imagePath: 'assets/badges/streak_7.png',
    isUnlocked: (habits) {
      return habits.any((h) => h.currentStreak >= 7);
    },
  ),
  HabitBadge(
    id: 'completion_10',
    title: 'Işık Hızı',
    description: 'Toplamda 10 kez rutin tamamla',
    imagePath: 'assets/badges/completion_10.png',
    isUnlocked: (habits) {
      final total = habits.fold<int>(0, (sum, h) => sum + h.completedDatesList.length);
      return total >= 10;
    },
  ),
  HabitBadge(
    id: 'completion_50',
    title: 'Efsane',
    description: 'Toplamda 50 kez rutin tamamla',
    imagePath: 'assets/badges/completion_50.png',
    isUnlocked: (habits) {
      final total = habits.fold<int>(0, (sum, h) => sum + h.completedDatesList.length);
      return total >= 50;
    },
  ),
  HabitBadge(
    id: 'diversity_3',
    title: 'Çeşitlilik',
    description: 'En az 3 farklı aktif rutin oluştur',
    imagePath: 'assets/badges/diversity_3.png',
    isUnlocked: (habits) => habits.length >= 3,
  ),
  HabitBadge(
    id: 'perfect_day',
    title: 'Mükemmel Gün',
    description: 'Bugünkü tüm rutinlerini tamamla',
    imagePath: 'assets/badges/perfect_day.png',
    isUnlocked: (habits) {
      final today = DateTime.now();
      // 🎯 Sadece BUGÜN YAPILMASI GEREKEN görevleri süzüyoruz:
      final todayTargets = habits.where((h) => h.isTargetDate(today)).toList();
      
      if (todayTargets.isEmpty) return false;
      return todayTargets.every((h) => h.isCompletedOn(today));
    },
  ),
];