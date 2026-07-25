import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/habit.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat ve Adapter'ı kaydet
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());

  // Habits kutusunu aç
  await Hive.openBox<Habit>('habits');

  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const HomeScreen(),
    );
  }
}

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
  ) async {
    if (title.trim().isEmpty) return;

    final colorList = [
      Colors.green.value,
      Colors.indigoAccent.value,
      Colors.orangeAccent.value,
      Colors.purpleAccent.value,
      Colors.pinkAccent.value,
    ];

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      colorValue: colorList[_habitsBox.length % colorList.length],
      frequencyType: frequencyType,
      intervalDays: intervalDays,
      selectedWeekdays: selectedWeekdays,
    );

    await _habitsBox.add(newHabit);
  }

  void _showAddHabitDialog() {
    final controller = TextEditingController();
    int selectedFrequency = 0;
    int intervalDays = 2;
    List<int> selectedWeekdays = [1, 3, 5];
    // 🛑 İsim dolu mu kontrolü için durum değişkeni
    bool isTitleValid = false;

    final daysMap = {
      1: 'Pzt',
      2: 'Sal',
      3: 'Çar',
      4: 'Per',
      5: 'Cum',
      6: 'Cmt',
      7: 'Paz',
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Görev / Rutin Ekle'),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    // 🎯 Metin değiştikçe butonun durumunu güncelliyoruz
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
                  const Text('Tekrar Sıklığı:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: selectedFrequency,
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
                      value: intervalDays,
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
            // 🛑 Ekle butonu sadece isTitleValid true ise tıklanabilir!
            ElevatedButton(
              onPressed: isTitleValid
                  ? () {
                      _addNewHabit(
                        controller.text,
                        selectedFrequency,
                        intervalDays,
                        selectedWeekdays,
                      );
                      Navigator.pop(ctx);
                    }
                  : null, // null verildiğinde buton pasif (disabled) duruma geçer
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  } // _showAddHabitDialog()

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
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isDoneToday
                      ? BorderSide(color: habit.color, width: 1.5)
                      : BorderSide.none,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // 🎯 BUGÜNÜ TAMAMLA / İPTAL ET BUTONU
                  leading: GestureDetector(
                    onTap: () async {
                      setState(() {
                        habit.toggleDate(DateTime.now());
                      });
                      await habit.save();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDoneToday ? habit.color : habit.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: habit.color,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isDoneToday ? Icons.check : Icons.add,
                        color: isDoneToday ? Colors.white : habit.color,
                        size: 24,
                      ),
                    ),
                  ),
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
                            color: Colors.orange.withOpacity(0.2),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () async {
                          await habit.delete();
                        },
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailScreen(habit: habit),
                      ),
                    );
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
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  int _selectedViewIndex = 0; // 0: Heatmap, 1: Takvim

  Map<DateTime, int> _getHeatmapDatasets() {
    Map<DateTime, int> datasets = {};
    for (var date in widget.habit.completedDatesList) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      datasets[normalizedDate] = 1;
    }
    return datasets;
  }

  // 🎨 Renk Lejantı Yardımcı Widget'ı
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.habit.calculateStreak();
    final isDoneToday = widget.habit.isCompletedOn(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 ÖZET VE TAMAMLAMA BUTONU
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                   Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Mevcut Zincir', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '🔥 $streak Gün',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.white10),
                        Column(
                          children: [
                            const Text('Sıklık', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '🔄 ${widget.habit.frequencyText}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.cyanAccent,
                              ),
                            ),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.white10),
                        Column(
                          children: [
                            const Text('Toplam', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              '✅ ${widget.habit.completedDatesList.length} Gün',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDoneToday ? Colors.green : widget.habit.color,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            widget.habit.toggleDate(DateTime.now());
                          });
                          await widget.habit.save();
                        },
                        icon: Icon(
                          isDoneToday ? Icons.check_circle : Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                        label: Text(
                          isDoneToday ? 'Bugün Tamamlandı 🎉' : 'Bugün Tamamlandı Olarak İşaretle',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ⚙️ GÖRÜNÜM SEÇİMİ (HEATMAP / TAKVİM)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'İstikrar Raporu',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('Heatmap', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.grid_on, size: 16),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Takvim', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.calendar_month, size: 16),
                    ),
                  ],
                  selected: {_selectedViewIndex},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() {
                      _selectedViewIndex = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 📊 DİNAMİK KART (HEATMAP VEYA RENKLİ TAKVİM + LEJANT)
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _selectedViewIndex == 0
                    ? IgnorePointer(
                        ignoring: true,
                        child: HeatMap(
                          datasets: _getHeatmapDatasets(),
                          colorMode: ColorMode.color,
                          defaultColor: const Color(0xFF334155),
                          textColor: Colors.white,
                          showColorTip: false,
                          showText: true,
                          scrollable: true,
                          size: 28,
                          colorsets: {
                            1: widget.habit.color,
                          },
                        ),
                      )
                    : Column(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2024, 1, 1),
                            // Gelecek ayları da takvimde gezinebilmek için ileri bir tarih veriyoruz
                            lastDay: DateTime.utc(2030, 12, 31), 
                            focusedDay: _focusedDay,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            // 🎨 TÜM GÜNLER İÇİN TEK BİR ÖZEL ÇİZİM METODU
                            calendarBuilders: CalendarBuilders(
                              prioritizedBuilder: (context, day, focusedDay) {
                                final isDone = widget.habit.isCompletedOn(day);
                                final isTarget = widget.habit.isTargetDate(day);

                                Color bgColor = Colors.transparent;
                                Color textColor = Colors.grey.withOpacity(0.4);

                                if (isDone) {
                                  bgColor = Colors.green; // 🟩 Yapılan Günler
                                  textColor = Colors.white;
                                } else if (isTarget) {
                                  // 🨨 Yapılması Gereken HEDEF Günler (Gelecek günler dahil sarı gösteriyoruz)
                                  bgColor = Colors.amber.withOpacity(0.85);
                                  textColor = Colors.black;
                                }

                                return Container(
                                  margin: const EdgeInsets.all(4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    shape: BoxShape.circle,
                                    border: isSameDay(day, DateTime.now()) && !isDone
                                        ? Border.all(color: Colors.amber, width: 2)
                                        : null,
                                  ),
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: isTarget || isDone ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              },
                            ),
                            onDaySelected: (selectedDay, focusedDay) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Takvim görsel takiptir. Tamamlamaları üstteki butondan yapabilirsiniz!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10),
                          const SizedBox(height: 8),

                          // 🎨 Renk Açıklaması
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildLegendItem(Colors.green, 'Yapıldı'),
                              _buildLegendItem(Colors.amber, 'Hedef Gün'),
                              _buildLegendItem(Colors.grey.withOpacity(0.4), 'Rutin Dışı'),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}