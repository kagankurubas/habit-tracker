import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'models/habit.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'app_themes.dart';
import 'models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  tz.initializeTimeZones();
  try {
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone.toString()));
  } catch (e) {
    tz.setLocalLocation(tz.getLocation('UTC'));
  }

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }

  final habitsBox = await Hive.openBox<Habit>('habits');
  final categoriesBox = await Hive.openBox<CategoryModel>('categories');

  if (categoriesBox.isEmpty) {
    final defaultCategories = [
      CategoryModel(id: '1', name: 'Genel', icon: '📌'),
      CategoryModel(id: '2', name: 'Kodlama', icon: '💻'),
      CategoryModel(id: '3', name: 'Müzik', icon: '🎸'),
      CategoryModel(id: '4', name: 'Oyun Dev.', icon: '🎮'),
      CategoryModel(id: '5', name: 'Spor', icon: '🏃'),
      CategoryModel(id: '6', name: 'Okuma', icon: '📚'),
      CategoryModel(id: '7', name: 'Sağlık', icon: '🧘'),
    ];

    for (final cat in defaultCategories) {
      await categoriesBox.add(cat);
    }
  }

  await ThemeService.init();

  final notificationService = NotificationService();

  await notificationService.init();

  for (final habit in habitsBox.values) {
    await notificationService.scheduleHabitNotification(habit);
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      child: const HabitTrackerApp(),
    ),
  );
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          onGenerateTitle: (context) => context.tr('app_title'),
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: bgColor,
          ),
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late final Box<Habit> _habitsBox;

  @override
  void initState() {
    super.initState();
    _habitsBox = Hive.box<Habit>('habits');
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      StatsScreen(habitsBox: _habitsBox),
    ];

    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final navBarBg = AppThemes.getNavBarColor(bgColor);
        final textColor = AppThemes.getTextColor(bgColor);

        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: navBarBg,
            selectedItemColor: AppThemes.isLightBackground(bgColor)
                ? Colors.indigo.shade700
                : const Color(0xFF6366F1),
            unselectedItemColor: textColor.withValues(alpha: 0.6),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.check_box_outlined),
                activeIcon: const Icon(Icons.check_box_rounded),
                label: context.tr('routines'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart_rounded),
                label: context.tr('statistics'),
              ),
            ],
          ),
        );
      },
    );
  }
}
