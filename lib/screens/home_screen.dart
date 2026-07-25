import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../widgets/add_edit_habit_dialog.dart';
import 'habit_detail_screen.dart';
import '../widgets/habit_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Habit> _habitsBox;
  String _selectedFilterCategory = 'Tüm Görevler';

  @override
  void initState() {
    super.initState();
    _habitsBox = Hive.box<Habit>('habits');
  }

  void _addNewHabit({
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
      title: title,
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
    await _habitsBox.flush();
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddEditHabitDialog(
        onSave: ({
          required title,
          required frequencyType,
          required intervalDays,
          required selectedWeekdays,
          required colorValue,
          required iconCodePoint,
          required category,
          required isNotificationEnabled,
          notificationHour,
          notificationMinute,
        }) {
          _addNewHabit(
            title: title,
            frequencyType: frequencyType,
            intervalDays: intervalDays,
            selectedWeekdays: selectedWeekdays,
            colorValue: colorValue,
            iconCodePoint: iconCodePoint,
            category: category,
            isNotificationEnabled: isNotificationEnabled,
            notificationHour: notificationHour,
            notificationMinute: notificationMinute,
          );
        },
      ),
    );
  }

  void _showEditHabitDialog(Habit habit) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditHabitDialog(
        habit: habit,
        onSave: ({
          required title,
          required frequencyType,
          required intervalDays,
          required selectedWeekdays,
          required colorValue,
          required iconCodePoint,
          required category,
          required isNotificationEnabled,
          notificationHour,
          notificationMinute,
        }) async {
          habit.title = title;
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
          await _habitsBox.flush();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Rutin & Alışkanlık Takibi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder<Box<Habit>>(
        valueListenable: _habitsBox.listenable(),
        builder: (context, box, _) {
          final habits = box.values.where((h) {
            if (_selectedFilterCategory == 'Tüm Görevler') return true;
            return h.category == _selectedFilterCategory;
          }).toList();

          return Column(
            children: [
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: const Text('✨ Tüm Görevler'),
                          selected: _selectedFilterCategory == 'Tüm Görevler',
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            color: _selectedFilterCategory == 'Tüm Görevler' ? Colors.white : Colors.grey[400],
                            fontWeight: _selectedFilterCategory == 'Tüm Görevler' ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          selectedColor: Colors.blueAccent.withValues(alpha: 0.3),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _selectedFilterCategory == 'Tüm Görevler' ? Colors.blueAccent : Colors.transparent,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilterCategory = 'Tüm Görevler';
                              });
                            }
                          },
                        ),
                      ),
                      ...availableCategories.map((cat) {
                        final isSelected = _selectedFilterCategory == cat.name;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text('${cat.icon} ${cat.name}'),
                            selected: isSelected,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[400],
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            selectedColor: Colors.blueAccent.withValues(alpha: 0.3),
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? Colors.blueAccent : Colors.transparent,
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilterCategory = cat.name;
                                });
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: habits.isEmpty
                    ? const Center(
                        child: Text(
                          'Bu kategoride henüz görev yok!\nAşağıdaki butonla yeni görev ekleyebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: habits.length,
                        itemBuilder: (context, index) {
                          final habit = habits[index];
                          final streak = habit.currentStreak;
                          final isDoneToday = habit.isCompletedOn(DateTime.now());

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: habit.color.withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isDoneToday ? Colors.greenAccent : habit.color.withValues(alpha: 0.4),
                                width: isDoneToday ? 2.0 : 1.0,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: habit.color.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      habit.icon,
                                      color: habit.color,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      final today = DateTime.now();
                                      final todayNormalized = DateTime(today.year, today.month, today.day);

                                      setState(() {
                                        habit.toggleDate(todayNormalized);
                                      });

                                      if (habit.key != null) {
                                        await _habitsBox.put(habit.key, habit);
                                      } else {
                                        await _habitsBox.putAt(index, habit);
                                      }
                                      await _habitsBox.flush();
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isDoneToday ? Colors.greenAccent : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDoneToday ? Colors.greenAccent : Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 18,
                                        color: isDoneToday ? Colors.black : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      habit.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        decoration: isDoneToday ? TextDecoration.lineThrough : null,
                                        color: isDoneToday ? Colors.grey : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      habit.category,
                                      style: const TextStyle(fontSize: 9, color: Colors.white70),
                                    ),
                                  ),
                                  if (streak > 0) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.orange, width: 1),
                                      ),
                                      child: Text(
                                        '🔥 $streak',
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'Son 30 Günlük İlerleme',
                                              style: TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                            if (habit.isNotificationEnabled && habit.notificationHour != null) ...[
                                              const SizedBox(width: 6),
                                              Icon(Icons.alarm, size: 12, color: Colors.amberAccent.withValues(alpha: 0.8)),
                                              Text(
                                                ' ${habit.notificationHour.toString().padLeft(2, '0')}:${habit.notificationMinute.toString().padLeft(2, '0')}',
                                                style: const TextStyle(fontSize: 9, color: Colors.amberAccent),
                                              ),
                                            ],
                                          ],
                                        ),
                                        Text(
                                          '%${habit.calculateCompletionRate(lastDays: 30).toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: habit.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: habit.calculateCompletionRate(lastDays: 30) / 100,
                                        backgroundColor: Colors.white10,
                                        valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                                        minHeight: 4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
                                    onPressed: () {
                                      _showEditHabitDialog(habit);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    onPressed: () async {
                                      await habit.delete();
                                      await _habitsBox.flush();
                                    },
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HabitDetailScreen(habit: habit),
                                  ),
                                );
                                setState(() {});
                              },
                            ),
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
        icon: const Icon(Icons.add),
        label: const Text('Yeni Görev'),
      ),
    );
  }
}