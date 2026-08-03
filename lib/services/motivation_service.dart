import 'dart:math';
import 'package:easy_localization/easy_localization.dart';

class MotivationService {
  MotivationService._();

  static final Random _random = Random();

  static const List<String> _quotes = [
    "quote_1",
    "quote_2",
    "quote_3",
    "quote_4",
    "quote_5",
    "quote_6",
  ];

  static String getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)].tr();
  }
}
