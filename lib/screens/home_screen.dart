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

                          // ESKİ UZUN CARD YAPISI SİLİNDİ, YERİNE HABITTILE EKLENDİ
                          return HabitTile(
                            habit: habit,
                            index: index,
                            habitsBox: _habitsBox,
                            onEdit: () => _showEditHabitDialog(habit),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HabitDetailScreen(habit: habit),
                                ),
                              );
                              setState(() {});
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
        icon: const Icon(Icons.add),
        label: const Text('Yeni Görev'),
      ),
    );
  }
}