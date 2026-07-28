import 'package:flutter/material.dart';
import '../services/share_service.dart';

class BadgeUnlockedDialog extends StatelessWidget {
  final String badgeTitle;
  final String badgeDescription;
  final String imagePath;
  final Color badgeColor;

  // ⚡ GlobalKey build metodu dışına alınarak re-render esnasında kaybolması önlendi
  final GlobalKey _shareKey = GlobalKey();

  BadgeUnlockedDialog({
    super.key,
    required this.badgeTitle,
    required this.badgeDescription,
    required this.imagePath,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: const Color(0xFF1E1B4B),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📸 KAREMSİ PAYLAŞILABİLİR KART ALANI
              RepaintBoundary(
                key: _shareKey,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131138),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✨ DOLGUN BÜYÜKLÜKTE ROZET GÖRSELİ
                      SizedBox(
                        height: 280,
                        width: 280,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.stars_rounded,
                            size: 200,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ÜST KÜÇÜK BAŞLIK
                      const Text(
                        '🎉 YENİ BAŞARIM!',
                        style: TextStyle(
                          color: Color(0xFFA5B4FC),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // ROZET ADI
                      Text(
                        badgeTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
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
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🚀 BUTONLAR (HARİKA & PAYLAŞ)
              SizedBox(
                width: 320,
                child: Row(
                  children: [
                    // KAPAT / HARİKA BUTONU
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Harika!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ROZETİ PAYLAŞ BUTONU
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ShareService.shareWidgetAsImage(_shareKey);
                        },
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: const Text(
                          'Paylaş',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: badgeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
