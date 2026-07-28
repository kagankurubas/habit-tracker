import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int iconCodePoint;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon = '📌',
    this.colorValue = 0xFF6366F1,
    this.iconCodePoint = 0xe3af,
  });

  // 🎨 İsme göre akıllı renk eşlemesi
  Color get color {
    if (colorValue != 0xFF6366F1) return Color(colorValue);

    switch (name.trim().toLowerCase()) {
      case 'kodlama':
        return const Color(0xFF3B82F6);
      case 'müzik':
        return const Color(0xFF8B5CF6);
      case 'oyun dev.':
      case 'oyun dev':
        return const Color(0xFFF59E0B);
      case 'spor':
        return const Color(0xFF10B981);
      case 'okuma':
        return const Color(0xFF06B6D4);
      case 'sağlık':
        return const Color(0xFFEF4444);
      default:
        return Color(colorValue);
    }
  }

  // 🎭 İsme göre akıllı ikon eşlemesi
  IconData get iconData {
    switch (name.trim().toLowerCase()) {
      case 'genel':
        return Icons.push_pin_rounded;
      case 'kodlama':
        return Icons.laptop_rounded;
      case 'müzik':
        return Icons.music_note_rounded;
      case 'oyun dev.':
      case 'oyun dev':
        return Icons.sports_esports_rounded;
      case 'spor':
        return Icons.directions_run_rounded;
      case 'okuma':
        return Icons.book_rounded;
      case 'sağlık':
        return Icons.local_hospital_rounded;
      default:
        return _iconMap[iconCodePoint] ?? Icons.star_rounded;
    }
  }

  static final Map<int, IconData> _iconMap = {
    Icons.star_rounded.codePoint: Icons.star_rounded,
    Icons.push_pin_rounded.codePoint: Icons.push_pin_rounded,
    Icons.laptop_rounded.codePoint: Icons.laptop_rounded,
    Icons.music_note_rounded.codePoint: Icons.music_note_rounded,
    Icons.sports_esports_rounded.codePoint: Icons.sports_esports_rounded,
    Icons.directions_run_rounded.codePoint: Icons.directions_run_rounded,
    Icons.book_rounded.codePoint: Icons.book_rounded,
    Icons.fitness_center_rounded.codePoint: Icons.fitness_center_rounded,
    Icons.local_hospital_rounded.codePoint: Icons.local_hospital_rounded,
    Icons.work_rounded.codePoint: Icons.work_rounded,
    Icons.brush_rounded.codePoint: Icons.brush_rounded,
  };
}
