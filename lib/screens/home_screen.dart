import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Habit> _habitsBox;

  @override
  void initState() {
    super.initState();
    _habitsBox = Hive.box<Habit>('habits');
  }

  void _addNewHabit(
    String title,
    int frequencyType,
    int intervalDays,
    List<int> selectedWeekdays,
    int colorValue,
    int iconCodePoint,
  ) async {
    if (title.trim().isEmpty) return;

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
      frequencyType: frequencyType,
      intervalDays: intervalDays,
      selectedWeekdays: selectedWeekdays,
    );

    await _habitsBox.add(newHabit);
    await _habitsBox.flush();
  }

  void _showAddHabitDialog() {
    final controller = TextEditingController();
    int selectedFrequency = 0;
    int intervalDays = 2;
    List<int> selectedWeekdays = [1, 3, 5];
    bool isTitleValid = false;

    final List<Color> availableColors = [
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
    ];
    int selectedColorValue = availableColors[0].toARGB32();

    final List<IconData> availableIcons = [
      Icons.book_rounded,
      Icons.fitness_center_rounded,
      Icons.music_note_rounded,
      Icons.code_rounded,
      Icons.water_drop_rounded,
      Icons.directions_run_rounded,
      Icons.bed_rounded,
      Icons.self_improvement_rounded,
    ];
    int selectedIconCodePoint = availableIcons[0].codePoint;

    final daysMap = {
      1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Görev / Rutin Ekle'),
          content: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (text) {
                      setDialogState(() {
                        isTitleValid = text.trim().isNotEmpty;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Örn: Kitap Oku, Gitar Çalış...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('İkon Seç:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableIcons.map((iconData) {
                      final isSelected = selectedIconCodePoint == iconData.codePoint;
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedIconCodePoint = iconData.codePoint;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(selectedColorValue).withValues(alpha: 0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Color(selectedColorValue) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            iconData,
                            color: isSelected ? Color(selectedColorValue) : Colors.grey,
                            size: 22,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Tema Rengi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: availableColors.map((color) {
                      final isSelected = selectedColorValue == color.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColorValue = color.toARGB32();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Tekrar Sıklığı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: selectedFrequency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Her Gün')),
                      DropdownMenuItem(value: 1, child: Text('Hafta İçi (Pzt-Cum)')),
                      DropdownMenuItem(value: 2, child: Text('Hafta Sonu (Cmt-Paz)')),
                      DropdownMenuItem(value: 3, child: Text('X Günde Bir')),
                      DropdownMenuItem(value: 4, child: Text('Haftanın Belirli Günleri')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedFrequency = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  if (selectedFrequency == 3) ...[
                    const Text('Kaç günde bir yapılmalı?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: intervalDays,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 2, child: Text('2 Günde Bir')),
                        DropdownMenuItem(value: 3, child: Text('3 Günde Bir')),
                        DropdownMenuItem(value: 4, child: Text('4 Günde Bir')),
                        DropdownMenuItem(value: 5, child: Text('5 Günde Bir')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            intervalDays = val;
                          });
                        }
                      },
                    ),
                  ],

                  if (selectedFrequency == 4) ...[
                    const Text('Hangi günlerde yapılacak?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: daysMap.entries.map((entry) {
                        final isSelected = selectedWeekdays.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          selectedColor: Color(selectedColorValue).withValues(alpha: 0.3),
                          onSelected: (bool selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedWeekdays.add(entry.key);
                              } else {
                                selectedWeekdays.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(selectedColorValue),
              ),
              onPressed: isTitleValid
                  ? () {
                      _addNewHabit(
                        controller.text,
                        selectedFrequency,
                        intervalDays,
                        selectedWeekdays,
                        selectedColorValue,
                        selectedIconCodePoint,
                      );
                      Navigator.pop(ctx);
                    }
                  : null,
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHabitDialog(Habit habit) {
    final controller = TextEditingController(text: habit.title);
    int selectedFrequency = habit.frequencyType;
    int intervalDays = habit.intervalDays;
    List<int> selectedWeekdays = List<int>.from(habit.selectedWeekdays);
    bool isTitleValid = habit.title.trim().isNotEmpty;
    int selectedColorValue = habit.colorValue;
    int selectedIconCodePoint = habit.iconCodePoint;

    final List<Color> availableColors = [
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
    ];

    final List<IconData> availableIcons = [
      Icons.book_rounded,
      Icons.fitness_center_rounded,
      Icons.music_note_rounded,
      Icons.code_rounded,
      Icons.water_drop_rounded,
      Icons.directions_run_rounded,
      Icons.bed_rounded,
      Icons.self_improvement_rounded,
    ];

    final daysMap = {
      1: 'Pzt', 2: 'Sal', 3: 'Çar', 4: 'Per', 5: 'Cum', 6: 'Cmt', 7: 'Paz'
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Görevi Düzenle'),
          content: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    onChanged: (text) {
                      setDialogState(() {
                        isTitleValid = text.trim().isNotEmpty;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Görevin Adı',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('İkon Seç:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableIcons.map((iconData) {
                      final isSelected = selectedIconCodePoint == iconData.codePoint;
                      return InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedIconCodePoint = iconData.codePoint;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected ? Color(selectedColorValue).withValues(alpha: 0.2) : Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Color(selectedColorValue) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            iconData,
                            color: isSelected ? Color(selectedColorValue) : Colors.grey,
                            size: 22,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Tema Rengi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: availableColors.map((color) {
                      final isSelected = selectedColorValue == color.toARGB32();
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColorValue = color.toARGB32();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)]
                                : [],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  const Text('Tekrar Sıklığı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: selectedFrequency,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Her Gün')),
                      DropdownMenuItem(value: 1, child: Text('Hafta İçi (Pzt-Cum)')),
                      DropdownMenuItem(value: 2, child: Text('Hafta Sonu (Cmt-Paz)')),
                      DropdownMenuItem(value: 3, child: Text('X Günde Bir')),
                      DropdownMenuItem(value: 4, child: Text('Haftanın Belirli Günleri')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedFrequency = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  if (selectedFrequency == 3) ...[
                    const Text('Kaç günde bir yapılmalı?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: intervalDays,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 2, child: Text('2 Günde Bir')),
                        DropdownMenuItem(value: 3, child: Text('3 Günde Bir')),
                        DropdownMenuItem(value: 4, child: Text('4 Günde Bir')),
                        DropdownMenuItem(value: 5, child: Text('5 Günde Bir')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            intervalDays = val;
                          });
                        }
                      },
                    ),
                  ],

                  if (selectedFrequency == 4) ...[
                    const Text('Hangi günlerde yapılacak?', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: daysMap.entries.map((entry) {
                        final isSelected = selectedWeekdays.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          selectedColor: Color(selectedColorValue).withValues(alpha: 0.3),
                          onSelected: (bool selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedWeekdays.add(entry.key);
                              } else {
                                selectedWeekdays.remove(entry.key);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(selectedColorValue),
              ),
              onPressed: isTitleValid
                  ? () async {
                      habit.title = controller.text;
                      habit.colorValue = selectedColorValue;
                      habit.iconCodePoint = selectedIconCodePoint;
                      habit.frequencyType = selectedFrequency;
                      habit.intervalDays = intervalDays;
                      habit.selectedWeekdays = selectedWeekdays;

                      await habit.save();
                      await _habitsBox.flush();

                      if (context.mounted) Navigator.pop(ctx);
                    }
                  : null,
              child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutin & Alışkanlık Takibi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ValueListenableBuilder<Box<Habit>>(
        valueListenable: _habitsBox.listenable(),
        builder: (context, box, _) {
          final habits = box.values.toList();

          if (habits.isEmpty) {
            return const Center(
              child: Text(
                'Henüz eklenmiş bir görev yok!\nAşağıdaki butonla yeni görev ekleyebilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final streak = habit.calculateStreak();
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  
                  // 🎭 SOL İKON VE TAMAMLAMA BUTONU
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

                  // 📝 BAŞLIK VE SERİ SAYACI
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: isDoneToday ? TextDecoration.lineThrough : null,
                            color: isDoneToday ? Colors.grey : Colors.white,
                          ),
                        ),
                      ),
                      if (streak > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🔥 ', style: TextStyle(fontSize: 12)),
                              Text(
                                '$streak Gün',
                                style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // 🔄 ALT BİLGİ METNİ
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '🔄 ${habit.frequencyText}  •  ${isDoneToday ? 'Bugün Tamamlandı 🎉' : 'Bugün henüz yapılmadı'}',
                      style: TextStyle(
                        color: isDoneToday ? Colors.greenAccent : Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // ⚙️ SAĞ BUTONLAR (Düzenle, Sil, Detaya Git)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                        onPressed: () {
                          _showEditHabitDialog(habit);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await habit.delete();
                          await _habitsBox.flush();
                        },
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),

                  // 🎯 KARTA TIKLANDIĞINDA DETAY SAYFASINA GİT
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