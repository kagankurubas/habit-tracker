import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'models/habit.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'app_themes.dart';
import 'models/category_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Zaman dilimlerini yükle ve varsayılan lokasyonu ayarla
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

  // 2. Hive veritabanını başlat
  await Hive.initFlutter();

  // Adapter Kayıtları (Çift kayıt engelleyici ile)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HabitAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }

  // Kutuları Açalım
  final habitsBox = await Hive.openBox<Habit>('habits');
  final categoriesBox = await Hive.openBox<CategoryModel>('categories');

  // Varsayılan Kategoriler
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

  // 3. Tema servisini başlat
  await ThemeService.init();

  // 4. Bildirim servisini başlat
  final notificationService = NotificationService();

  await notificationService.init();

  for (final habit in habitsBox.values) {
    await notificationService.scheduleHabitNotification(habit);
  }
  runApp(const HabitTrackerApp());
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
          title: 'Habit Tracker',
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
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outlined),
                activeIcon: Icon(Icons.check_box_rounded),
                label: 'Rutinlerim',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'İstatistikler',
              ),
            ],
          ),
        );
      },
    );
  }
}
