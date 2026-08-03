import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:easy_localization/easy_localization.dart';

class AddEditHabitDialog extends StatefulWidget {
  final Habit? habit;
  final Function({
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
  })
  onSave;

  const AddEditHabitDialog({super.key, this.habit, required this.onSave});

  @override
  State<AddEditHabitDialog> createState() => _AddEditHabitDialogState();
}

class _AddEditHabitDialogState extends State<AddEditHabitDialog> {
  late TextEditingController _controller;
  late String _selectedCategory;
  late int _selectedFrequency;
  late int _intervalDays;
  late List<int> _selectedWeekdays;
  late bool _isTitleValid;
  late int _selectedColorValue;
  late int _selectedIconCodePoint;
  late bool _isNotificationEnabled;
  TimeOfDay? _selectedTime;

  final List<Color> _availableColors = const [
    Color(0xFF10B981),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFEF4444),
  ];

  final List<IconData> _availableIcons = const [
    Icons.book_rounded,
    Icons.fitness_center_rounded,
    Icons.music_note_rounded,
    Icons.code_rounded,
    Icons.water_drop_rounded,
    Icons.directions_run_rounded,
    Icons.bed_rounded,
    Icons.self_improvement_rounded,
  ];

  final Map<int, String> _daysMap = const {
    1: 'Pzt',
    2: 'Sal',
    3: 'Çar',
    4: 'Per',
    5: 'Cum',
    6: 'Cmt',
    7: 'Paz',
  };

  @override
  void initState() {
    super.initState();
    final h = widget.habit;
    _controller = TextEditingController(text: h?.title ?? '');
    _selectedCategory = h?.category ?? 'Genel';
    _selectedFrequency = h?.frequencyType ?? 0;
    _intervalDays = h?.intervalDays ?? 2;
    _selectedWeekdays = h != null
        ? List<int>.from(h.selectedWeekdays)
        : [1, 3, 5];
    _isTitleValid = _controller.text.trim().isNotEmpty;
    _selectedColorValue = h?.colorValue ?? _availableColors[0].toARGB32();
    _selectedIconCodePoint = h?.iconCodePoint ?? _availableIcons[0].codePoint;
    _isNotificationEnabled = h?.isNotificationEnabled ?? false;

    if (h?.notificationHour != null && h?.notificationMinute != null) {
      _selectedTime = TimeOfDay(
        hour: h!.notificationHour!,
        minute: h.notificationMinute!,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;

    return AlertDialog(
      title: Text(isEditing ? 'edit_task'.tr() : 'add_new_task'.tr()),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: !isEditing,
              onChanged: (text) {
                setState(() {
                  _isTitleValid = text.trim().isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: 'example_habits_placeholder'.tr(),
                labelText: isEditing ? 'task_name'.tr() : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'select_icon'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((iconData) {
                final isSelected = _selectedIconCodePoint == iconData.codePoint;
                final activeColor = Color(_selectedColorValue);

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIconCodePoint = iconData.codePoint;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? activeColor.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? activeColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: isSelected ? activeColor : Colors.grey,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text(
              'theme_color'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _availableColors.map((color) {
                final colorVal = color.toARGB32();
                final isSelected = _selectedColorValue == colorVal;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorValue = colorVal;
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
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
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

            Text(
              'category'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue:
                  availableCategories.any((c) => c.name == _selectedCategory)
                  ? _selectedCategory
                  : 'Genel',
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: availableCategories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.name,
                  child: Text('${cat.icon} ${cat.name.tr()}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedCategory = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            Text(
              'repeat_frequency'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedFrequency,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                DropdownMenuItem(value: 0, child: Text('every_day'.tr())),
                DropdownMenuItem(value: 1, child: Text('weekday'.tr())),
                DropdownMenuItem(value: 2, child: Text('weekend'.tr())),
                DropdownMenuItem(value: 3, child: Text('interval_days'.tr())),
                DropdownMenuItem(value: 4, child: Text('specific_days'.tr())),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedFrequency = val;
                  });
                }
              },
            ),
            const SizedBox(height: 12),

            if (_selectedFrequency == 3) ...[
              const Text(
                'Kaç günde bir yapılmalı?',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _intervalDays,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 2, child: Text('2 Günde Bir')),
                  DropdownMenuItem(value: 3, child: Text('3 Günde Bir')),
                  DropdownMenuItem(value: 4, child: Text('4 Günde Bir')),
                  DropdownMenuItem(value: 5, child: Text('5 Günde Bir')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _intervalDays = val;
                    });
                  }
                },
              ),
            ],

            if (_selectedFrequency == 4) ...[
              const Text(
                'Hangi günlerde yapılacak?',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _daysMap.entries.map((entry) {
                  final isSelected = _selectedWeekdays.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    selectedColor: Color(
                      _selectedColorValue,
                    ).withValues(alpha: 0.3),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedWeekdays.add(entry.key);
                        } else {
                          _selectedWeekdays.remove(entry.key);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: Color(_selectedColorValue).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Color(_selectedColorValue).withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    title: Text(
                      'reminder_notification'.tr(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _isNotificationEnabled,
                    activeThumbColor: Color(_selectedColorValue),
                    onChanged: (bool value) {
                      setState(() {
                        _isNotificationEnabled = value;
                      });
                    },
                  ),
                  if (_isNotificationEnabled) ...[
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: const Icon(
                        Icons.alarm,
                        color: Colors.amberAccent,
                      ),
                      title: Text(
                        _selectedTime == null
                            ? 'Hatırlatma Saati Ayarla'
                            : 'Saat: ${_selectedTime!.format(context)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Her gün bu saatte bildirim gönderilir',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(_selectedColorValue),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime ?? TimeOfDay.now(),
                          );
                          if (!mounted) return;
                          if (picked != null) {
                            setState(() {
                              _selectedTime = picked;
                            });
                          }
                        },
                        child: Text(
                          _selectedTime == null ? 'Seç' : 'Değiştir',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(_selectedColorValue),
          ),
          onPressed: _isTitleValid
              ? () {
                  if (_isNotificationEnabled && _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Bildirim için bir hatırlatma saati seçmelisin.',
                        ),
                      ),
                    );
                    return;
                  }

                  widget.onSave(
                    title: _controller.text.trim(),
                    frequencyType: _selectedFrequency,
                    intervalDays: _intervalDays,

                    selectedWeekdays: _selectedFrequency == 4
                        ? List<int>.from(_selectedWeekdays)
                        : <int>[],

                    colorValue: _selectedColorValue,
                    iconCodePoint: _selectedIconCodePoint,
                    category: _selectedCategory,
                    isNotificationEnabled: _isNotificationEnabled,
                    notificationHour: _selectedTime?.hour,
                    notificationMinute: _selectedTime?.minute,
                  );

                  Navigator.pop(context);
                }
              : null,
          child: Text(
            isEditing ? 'save'.tr() : 'add'.tr(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
