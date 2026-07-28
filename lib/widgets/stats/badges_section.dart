import 'package:flutter/material.dart';
import '../../models/habit.dart';
import '../../models/badge_model.dart';

class BadgesSection extends StatefulWidget {
  final List<Habit> habits;
  final Color cardColor;
  final Color textColor;
  final Color subtextColor;

  const BadgesSection({
    super.key,
    required this.habits,
    required this.cardColor,
    required this.textColor,
    required this.subtextColor,
  });

  @override
  State<BadgesSection> createState() => _BadgesSectionState();
}

class _BadgesSectionState extends State<BadgesSection> {
  String _selectedBadgeCategory = 'Tüm Rozetler';

  static const List<String> _badgeCategories = [
    'Tüm Rozetler',
    'Genel',
    'Kodlama',
    'Müzik',
    'Oyun Dev.',
    'Spor',
    'Okuma',
    'Gizli',
  ];

  // ⚡ KATEGORİ TEMİZLEME (Boşluk / Nokta Toleransı)
  static String _normalizeCategory(String text) {
    return text.replaceAll('.', '').trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final filteredBadges = _selectedBadgeCategory == 'Tüm Rozetler'
        ? allBadges
        : allBadges.where((b) {
            return _normalizeCategory(b.category) ==
                _normalizeCategory(_selectedBadgeCategory);
          }).toList();

    // ⚡ OPTİMİZE EDİLDİ: isUnlocked kontrolü her karşılaştırma için tekrar çalışmasın diye Map ile önceden hesaplanır
    final unlockedStatus = {
      for (final badge in filteredBadges)
        badge.id: badge.isUnlocked(widget.habits),
    };

    final sortedBadges = List<HabitBadge>.from(filteredBadges)
      ..sort((a, b) {
        final aUnlocked = unlockedStatus[a.id] ?? false;
        final bUnlocked = unlockedStatus[b.id] ?? false;
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;
        return 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Başarımlar & Rozetler 🏆',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
        const SizedBox(height: 12),

        // ROZET KATEGORİ FİLTRE ÇUBUĞU
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
                  backgroundColor: widget.cardColor,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : widget.textColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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

        // ROZET GRID LISTESİ
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
            final unlocked = unlockedStatus[badge.id] ?? false;
            final isHiddenCategory =
                _normalizeCategory(badge.category) == 'gizli';

            // 🕵️ GİZLİ ROZET ADI MANTIGI
            final displayTitle = (isHiddenCategory && !unlocked)
                ? '???'
                : badge.title;
            final displayDesc = (isHiddenCategory && !unlocked)
                ? 'Bu sürpriz ve gizli bir rozettir! Doğru zamanda kendiliğinden açılacak.'
                : badge.description;

            return GestureDetector(
              onTap: () {
                final dialogBackground = Color.alphaBlend(
                  widget.cardColor,
                  Theme.of(context).scaffoldBackgroundColor,
                );

                showDialog<void>(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.72),
                  builder: (dialogContext) {
                    return Dialog(
                      backgroundColor: dialogBackground,
                      insetPadding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: Opacity(
                                  opacity: unlocked ? 1 : 0.4,
                                  child: Image.asset(
                                    badge.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) {
                                      return Icon(
                                        Icons.stars_rounded,
                                        size: 80,
                                        color: unlocked
                                            ? Colors.amber
                                            : widget.subtextColor,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                displayTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                displayDesc,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: widget.subtextColor,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: unlocked
                                      ? Colors.green.withValues(alpha: 0.18)
                                      : Colors.red.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: unlocked
                                        ? Colors.greenAccent.withValues(
                                            alpha: 0.5,
                                          )
                                        : Colors.redAccent.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                                child: Text(
                                  unlocked ? 'Kazanıldı 🎉' : 'Kilitli 🔒',
                                  style: TextStyle(
                                    color: unlocked
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                  ),
                                  child: const Text('Kapat'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: widget.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: unlocked
                        ? Colors.amber.withValues(alpha: 0.6)
                        : widget.subtextColor.withValues(alpha: 0.15),
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
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.dst,
                                )
                              : const ColorFilter.mode(
                                  Colors.grey,
                                  BlendMode.saturation,
                                ),
                          child: Image.asset(
                            badge.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.stars_rounded,
                                size: 40,
                                color: Colors.grey,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayTitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: unlocked
                            ? widget.textColor
                            : widget.subtextColor.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: unlocked
                            ? FontWeight.bold
                            : FontWeight.normal,
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
}
