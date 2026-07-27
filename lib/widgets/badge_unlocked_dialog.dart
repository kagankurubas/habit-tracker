import 'package:flutter/material.dart';

class BadgeUnlockedDialog extends StatelessWidget {
  final String badgeTitle;
  final String badgeDescription;
  final IconData badgeIcon;
  final Color badgeColor;

  const BadgeUnlockedDialog({
    super.key,
    required this.badgeTitle,
    required this.badgeDescription,
    required this.badgeIcon,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: const Color(0xFF1E1B4B),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // KUTLAMA İKONU & PARLAMA EFEKTİ
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(badgeIcon, color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // BAŞLIK
            const Text(
              '🎉 Yeni Başarım Kazanıldı!',
              style: TextStyle(
                color: Color(0xFFA5B4FC),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // ROZET ADI
            Text(
              badgeTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // AÇIKLAMA
            Text(
              badgeDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // TAMAM / HARİKA BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: badgeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Harika! 🚀',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}