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

  void _addNewHabit(String title) async {
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
    );

    // Kutuya ekle (Hive nesneye otomatik key/index bağlar)
    await _habitsBox.add(newHabit);
  }

  void _showAddHabitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Görev / Rutin Ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Örn: Su İç, Gitar Pratiği Yap...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              _addNewHabit(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Ekle'),
          ),
        ],
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
                      isDoneToday ? 'Bugün Tamamlandı! 🎉' : 'Bugün henüz yapılmadı',
                      style: TextStyle(
                        color: isDoneToday ? Colors.greenAccent : Colors.grey[400],
                        fontSize: 13,
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
  // Kullanıcının seçtiği görünüm: 0 -> Heatmap, 1 -> Aylık Takvim
  int _selectedViewIndex = 0;

  Map<DateTime, int> _getHeatmapDatasets() {
    Map<DateTime, int> datasets = {};
    for (var date in widget.habit.completedDatesList) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      datasets[normalizedDate] = 1;
    }
    return datasets;
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
            // 🎯 DETAY EKRANI BUGÜNÜ TAMAMLA BUTONU
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
                        Container(height: 30, width: 1, color: Colors.grey.withOpacity(0.3)),
                        Column(
                          children: [
                            const Text('Toplam Gün', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                    // Büyük Buton
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

            // ⚙️ GÖRÜNÜM SEÇİMİ (TOGGLE SWITCH)
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

            // 📊 SEÇİLEN GÖRÜNÜM (DİNAMİK DEĞİŞEN KART)
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: _selectedViewIndex == 0
                    ? // 🟩 HEATMAP GÖRÜNÜMÜ (IgnorePointer ile tamamen tıklanamaz yapıldı)
                      IgnorePointer(
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
                    : // 📅 AYLIK TAKVİM GÖRÜNÜMÜ (Tıklama uyarılı)
                      TableCalendar(
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.now(),
                        focusedDay: _focusedDay,
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: widget.habit.color.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: widget.habit.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        selectedDayPredicate: (day) {
                          return widget.habit.isCompletedOn(day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Takvim geçmişi görüntülemek içindir. Tamamlamaları üstteki butondan yapabilirsiniz!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}