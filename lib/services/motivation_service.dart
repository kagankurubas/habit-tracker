import 'dart:math';

class MotivationService {
  static final List<String> _quotes = [
    "Zinciri kırma, bugün de hedefine bir adım daha yaklaş!",
    "Küçük adımlar, büyük zaferler getirir. Başlayalım mı?",
    "Bugünün disiplini, yarının başarısıdır!",
    "Harika gidiyorsun! Bugünkü rutinini tamamlamaya ne dersin?",
    "Zaman akıp gidiyor ama sen hedefine odaklanmaya devam et!",
    "Rutinlerine sahip çık, geleceğini inşa et!",
  ];

  static String getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }
}
