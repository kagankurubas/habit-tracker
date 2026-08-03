import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../models/category_model.dart';
import '../widgets/add_edit_habit_dialog.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/habit_tile.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../app_themes.dart';
import 'habit_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Habit> _habitsBox;
  late Box<CategoryModel> _categoriesBox;
  String _selectedFilterCategory = 'all_tasks';

  @override
  void initState() {
    super.initState();
    _habitsBox = Hive.box<Habit>('habits');
    _categoriesBox = Hive.box<CategoryModel>('categories');
    NotificationService.selectNotificationStream.addListener(
      _handleNotificationClick,
    );
  }

  @override
  void dispose() {
    NotificationService.selectNotificationStream.removeListener(
      _handleNotificationClick,
    );
    super.dispose();
  }

  void _handleNotificationClick() {
    final habitId = NotificationService.selectNotificationStream.value;
    if (habitId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final habit = _habitsBox.values.firstWhere(
        (h) => h.id == habitId,
        orElse: () => _habitsBox.values.first,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HabitDetailScreen(habit: habit),
        ),
      );

      NotificationService.selectNotificationStream.value = null;
    });
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddEditHabitDialog(
        onSave:
            ({
              required String title,
              required int frequencyType,
              required int intervalDays,
              required List<int> selectedWeekdays,
              required int colorValue,
              required int iconCodePoint,
              required String category,
              required bool isNotificationEnabled,
              int? notificationHour,
              int? notificationMinute,
            }) async {
              if (title.trim().isEmpty) return;

              final newHabit = Habit(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title.trim(),
                colorValue: colorValue,
                iconCodePoint: iconCodePoint,
                frequencyType: frequencyType,
                intervalDays: intervalDays,
                selectedWeekdays: selectedWeekdays,
                category: category,
                isNotificationEnabled: isNotificationEnabled,
                notificationHour: notificationHour,
                notificationMinute: notificationMinute,
              );

              await _habitsBox.add(newHabit);
              await NotificationService().scheduleHabitNotification(newHabit);
            },
      ),
    );
  }

  void _showEditHabitDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditHabitDialog(
        habit: habit,
        onSave:
            ({
              required String title,
              required int frequencyType,
              required int intervalDays,
              required List<int> selectedWeekdays,
              required int colorValue,
              required int iconCodePoint,
              required String category,
              required bool isNotificationEnabled,
              int? notificationHour,
              int? notificationMinute,
            }) async {
              habit.title = title.trim();
              habit.category = category;
              habit.colorValue = colorValue;
              habit.iconCodePoint = iconCodePoint;
              habit.frequencyType = frequencyType;
              habit.intervalDays = intervalDays;
              habit.selectedWeekdays = selectedWeekdays;
              habit.isNotificationEnabled = isNotificationEnabled;
              habit.notificationHour = notificationHour;
              habit.notificationMinute = notificationMinute;

              await habit.save();
              await NotificationService().scheduleHabitNotification(habit);
            },
      ),
    );
  }

  static String _normalizeCategory(String text) {
    return text.replaceAll('.', '').trim().toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeService.currentColor,
      builder: (context, bgColor, child) {
        final textColor = AppThemes.getTextColor(bgColor);
        final subtextColor = AppThemes.getSubtextColor(bgColor);
        final isLight = AppThemes.isLightBackground(bgColor);
        final btnBgColor = isLight
            ? const Color(0xFF1E293B)
            : const Color(0xFF6366F1);

        return Scaffold(
          backgroundColor: bgColor,
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(
              title: Text(
                'app_title'.tr(),
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: textColor),
                  tooltip: 'settings'.tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          habitsBox: _habitsBox,
                          categoriesBox: _categoriesBox,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          body: ValueListenableBuilder<Box<Habit>>(
            valueListenable: _habitsBox.listenable(),
            builder: (context, box, _) {
              final habits = box.values.where((h) {
                if (_selectedFilterCategory == 'all_tasks') return true;
                return _normalizeCategory(h.category) ==
                    _normalizeCategory(_selectedFilterCategory);
              }).toList();

              return Column(
                children: [
                  CategoryFilterBar(
                    selectedCategory: _selectedFilterCategory,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedFilterCategory = category;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: habits.isEmpty
                        ? Center(
                            child: Text(
                              'no_tasks_in_category'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: subtextColor),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: habits.length,
                            itemBuilder: (context, index) {
                              final habit = habits[index];
                              return HabitTile(
                                key: ValueKey(habit.id),
                                habit: habit,
                                index: index,
                                habitsBox: _habitsBox,
                                onEdit: () => _showEditHabitDialog(habit),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HabitDetailScreen(habit: habit),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddHabitDialog,
            backgroundColor: btnBgColor,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add),
            label: Text(
              'new_task'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
