import 'dart:math';

class MotivationService {
  // 🛠️ Yanlışlıkla nesne üretilmesini engeller
  MotivationService._();

  static final Random _random = Random();

  static const List<String> _quotes = [
    "Zinciri kırma, bugün de hedefine bir adım daha yaklaş!",
    "Küçük adımlar, büyük zaferler getirir. Başlayalım mı?",
    "Bugünün disiplini, yarının başarısıdır!",
    "Harika gidiyorsun! Bugünkü rutinini tamamlamaya ne dersin?",
    "Zaman akıp gidiyor ama sen hedefine odaklanmaya devam et!",
    "Rutinlerine sahip çık, geleceğini inşa et!",
  ];

  /// 🎲 Rastgele bir motivasyon sözü döndürür
  static String getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }
}
