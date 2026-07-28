import 'habit.dart';

class HabitBadge {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final String category;
  final bool Function(List<Habit> habits) isUnlocked;

  const HabitBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.isUnlocked,
  });
}

// 🛠️ YARDIMCI METOTLAR (Kod tekrarını engeller ve performansı artırır)
int _getTotalCompletions(List<Habit> habits) {
  return habits.fold<int>(0, (sum, h) => sum + h.completedDatesList.length);
}

int _getCategoryCompletions(List<Habit> habits, String category) {
  return habits
      .where((h) => h.category == category)
      .fold<int>(0, (sum, h) => sum + h.completedDatesList.length);
}

// 🏆 TÜM ROZETLER VE AÇILMA ŞARTLARI
final List<HabitBadge> allBadges = [
  // 📌 1. GENEL ROZETLER
  HabitBadge(
    id: 'first_step',
    title: 'İlk Adım',
    description: 'En az 1 rutini tamamla',
    imagePath: 'assets/badges/first_step.png',
    category: 'Genel',
    isUnlocked: (habits) => habits.any((h) => h.completedDatesList.isNotEmpty),
  ),
  HabitBadge(
    id: 'streak_3',
    title: 'Alev Alev',
    description: 'Bir rutinde 3 günlük seriye ulaş',
    imagePath: 'assets/badges/streak_3.png',
    category: 'Genel',
    isUnlocked: (habits) => habits.any((h) => h.currentStreak >= 3),
  ),
  HabitBadge(
    id: 'streak_7',
    title: 'İrade Ustası',
    description: 'Bir rutinde 7 günlük seriye ulaş',
    imagePath: 'assets/badges/streak_7.png',
    category: 'Genel',
    isUnlocked: (habits) => habits.any((h) => h.currentStreak >= 7),
  ),
  HabitBadge(
    id: 'completion_10',
    title: 'Işık Hızı',
    description: 'Toplamda 10 kez rutin tamamla',
    imagePath: 'assets/badges/completion_10.png',
    category: 'Genel',
    isUnlocked: (habits) => _getTotalCompletions(habits) >= 10,
  ),
  HabitBadge(
    id: 'completion_50',
    title: 'Efsane',
    description: 'Toplamda 50 kez rutin tamamla',
    imagePath: 'assets/badges/completion_50.png',
    category: 'Genel',
    isUnlocked: (habits) => _getTotalCompletions(habits) >= 50,
  ),
  HabitBadge(
    id: 'diversity_3',
    title: 'Çeşitlilik',
    description: 'En az 3 farklı aktif rutin oluştur',
    imagePath: 'assets/badges/diversity_3.png',
    category: 'Genel',
    isUnlocked: (habits) => habits.length >= 3,
  ),
  HabitBadge(
    id: 'perfect_day',
    title: 'Mükemmel Gün',
    description: 'Bugün planladığın en az 3 hedefi eksiksiz tamamla',
    imagePath: 'assets/badges/perfect_day.png',
    category: 'Genel',
    isUnlocked: (habits) {
      final now = DateTime.now();
      final todayNormalized = DateTime(now.year, now.month, now.day);
      final todayTargets = habits
          .where((h) => h.isTargetDate(todayNormalized))
          .toList();

      if (todayTargets.length < 3) return false;
      return todayTargets.every((h) => h.isCompletedOn(todayNormalized));
    },
  ),

  // 💻 2. KODLAMA ROZETLERİ
  HabitBadge(
    id: 'code_first',
    title: 'Hello World',
    description: 'Kodlama kategorisinde ilk görevini tamamla',
    imagePath: 'assets/badges/code_first.png',
    category: 'Kodlama',
    isUnlocked: (habits) => habits.any(
      (h) => h.category == 'Kodlama' && h.completedDatesList.isNotEmpty,
    ),
  ),
  HabitBadge(
    id: 'code_bug_hunter',
    title: 'Bug Avcısı',
    description: 'Kodlama kategorisinde 5 görev tamamla',
    imagePath: 'assets/badges/code_bug_hunter.png',
    category: 'Kodlama',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Kodlama') >= 5,
  ),
  HabitBadge(
    id: 'code_master',
    title: 'Yazılım Bükücü',
    description: 'Kodlama kategorisinde 15 görev tamamla',
    imagePath: 'assets/badges/code_master.png',
    category: 'Kodlama',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Kodlama') >= 15,
  ),

  // 🎸 3. MÜZİK ROZETLERİ
  HabitBadge(
    id: 'music_first',
    title: 'İlk Akor',
    description: 'Müzik kategorisinde ilk pratik yapışın',
    imagePath: 'assets/badges/music_first.png',
    category: 'Müzik',
    isUnlocked: (habits) => habits.any(
      (h) => h.category == 'Müzik' && h.completedDatesList.isNotEmpty,
    ),
  ),
  HabitBadge(
    id: 'music_virtuoso',
    title: 'Virtüöz',
    description: 'Müzik kategorisinde 10 kez pratik yap',
    imagePath: 'assets/badges/music_virtuoso.png',
    category: 'Müzik',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Müzik') >= 10,
  ),
  HabitBadge(
    id: 'music_rockstar',
    title: 'Rock Efsanesi',
    description: 'Müzik kategorisinde 20 görev tamamla',
    imagePath: 'assets/badges/music_rockstar.png',
    category: 'Müzik',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Müzik') >= 20,
  ),

  // 🎮 4. OYUN DEV. ROZETLERİ
  HabitBadge(
    id: 'gamedev_builder',
    title: 'Dünya Mimarı',
    description: 'Oyun Dev. kategorisinde ilk görevini tamamla',
    imagePath: 'assets/badges/gamedev_builder.png',
    category: 'Oyun Dev.',
    isUnlocked: (habits) => habits.any(
      (h) => h.category == 'Oyun Dev.' && h.completedDatesList.isNotEmpty,
    ),
  ),
  HabitBadge(
    id: 'gamedev_level_up',
    title: 'Level Up',
    description: 'Oyun Dev. kategorisinde 10 görev tamamla',
    imagePath: 'assets/badges/gamedev_level_up.png',
    category: 'Oyun Dev.',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Oyun Dev.') >= 10,
  ),

  // 🏃 5. SPOR ROZETLERİ
  HabitBadge(
    id: 'sport_runner',
    title: 'Maratoncu',
    description: 'Spor kategorisinde 5 görev tamamla',
    imagePath: 'assets/badges/sport_runner.png',
    category: 'Spor',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Spor') >= 5,
  ),
  HabitBadge(
    id: 'sport_ironman',
    title: 'Demir Adam',
    description: 'Spor kategorisinde 15 tamamlama yap',
    imagePath: 'assets/badges/sport_ironman.png',
    category: 'Spor',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Spor') >= 15,
  ),

  // 📚 6. OKUMA ROZETLERİ
  HabitBadge(
    id: 'read_bookworm',
    title: 'Kitap Kurdu',
    description: 'Okuma kategorisinde 5 görev tamamla',
    imagePath: 'assets/badges/read_bookworm.png',
    category: 'Okuma',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Okuma') >= 5,
  ),
  HabitBadge(
    id: 'read_sage',
    title: 'Bilge',
    description: 'Okuma kategorisinde 15 görev tamamla',
    imagePath: 'assets/badges/read_sage.png',
    category: 'Okuma',
    isUnlocked: (habits) => _getCategoryCompletions(habits, 'Okuma') >= 15,
  ),

  // 🦉 7. GİZLİ BAŞARIMLAR
  HabitBadge(
    id: 'secret_early_bird',
    title: 'Erkenci Kuş',
    description: 'Sabah 05:00 - 08:00 saatleri arasında bir görev tamamla',
    imagePath: 'assets/badges/secret_early_bird.png',
    category: 'Gizli',
    isUnlocked: (habits) {
      return habits.any((h) {
        return h.completedDatesList.any((d) {
          final local = d.toLocal();
          return local.hour >= 5 && local.hour < 8;
        });
      });
    },
  ),
  HabitBadge(
    id: 'secret_night_owl',
    title: 'Gece Kuşu',
    description: 'Gece 00:00 - 05:00 saatleri arasında bir görev tamamla',
    imagePath: 'assets/badges/secret_night_owl.png',
    category: 'Gizli',
    isUnlocked: (habits) {
      return habits.any((h) {
        return h.completedDatesList.any((d) {
          final local = d.toLocal();
          final isExactlyMidnight =
              local.hour == 0 && local.minute == 0 && local.second == 0;
          return !isExactlyMidnight && (local.hour >= 0 && local.hour < 5);
        });
      });
    },
  ),
];
