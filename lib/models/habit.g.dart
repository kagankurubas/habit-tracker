// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      colorValue: fields[2] as int,
      frequencyType: fields[4] as int,
      intervalDays: fields[5] as int,
      iconCodePoint: fields[7] as int,
      selectedWeekdays: (fields[6] as List?)?.cast<int>(),
      category: fields[8] as String,
      isNotificationEnabled: fields[9] as bool,
      notificationHour: fields[10] as int?,
      notificationMinute: fields[11] as int?,
    )..completedDatesList = (fields[3] as List).cast<DateTime>();
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.colorValue)
      ..writeByte(3)
      ..write(obj.completedDatesList)
      ..writeByte(4)
      ..write(obj.frequencyType)
      ..writeByte(5)
      ..write(obj.intervalDays)
      ..writeByte(6)
      ..write(obj.selectedWeekdays)
      ..writeByte(7)
      ..write(obj.iconCodePoint)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
      ..write(obj.isNotificationEnabled)
      ..writeByte(10)
      ..write(obj.notificationHour)
      ..writeByte(11)
      ..write(obj.notificationMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
