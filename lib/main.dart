import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models/habit.dart';

void main() {
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
          seedColor: const Color(0xFF6366F1), // Modern İndigo
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Koyu Lacivert Arka Plan
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
  // Örnek başlangıç verileri
  final List<Habit> _habits = [
    Habit(
      id: '1',
      title: 'Kitap Oku (20 Sayfa)',
      color: Colors.green, // ya da özel renk için: const Color(0xFF10B981)
    ),
    Habit(
      id: '2',
      title: 'Yazılım / Kodlama Çalış',
      color: Colors.indigoAccent,
    ),
    Habit(
      id: '3',
      title: 'Egzersiz / Yürüyüş',
      color: Colors.orangeAccent,
    ),
  ];

  void _addNewHabit(String title) {
    if (title.trim().isEmpty) return;
    setState(() {
      _habits.add(
        Habit(
          id: DateTime.now().toString(),
          title: title,
          color: Colors.primaries[_habits.length % Colors.primaries.length],
        ),
      );
    });
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
      body: _habits.isEmpty
          ? const Center(child: Text('Henüz eklenmiş bir görev yok!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: habit.color.withOpacity(0.2),
                      child: Icon(Icons.check_circle_outline, color: habit.color),
                    ),
                    title: Text(
                      habit.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Tamamlanan Gün: ${habit.completedDates.length}',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailScreen(
                            habit: habit,
                            onToggle: () => setState(() {}),
                          ),
                        ),
                      );
                    },
                  ),
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
  final VoidCallback onToggle;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.onToggle,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit.title),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              color: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
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
                    setState(() {
                      widget.habit.toggleDate(selectedDay);
                      _focusedDay = focusedDay;
                    });
                    widget.onToggle(); // Ana ekranı güncelle
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'İpucu: Görevi tamamladığın günün üzerine tıklayarak işaretleyebilirsin!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}