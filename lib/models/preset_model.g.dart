// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresetModelAdapter extends TypeAdapter<PresetModel> {
  @override
  final int typeId = 0;

  @override
  PresetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PresetModel(
      id: fields[0] as String,
      name: fields[1] as String,
      emoji: fields[2] as String,
      leftFrequency: fields[3] as double,
      rightFrequency: fields[4] as double,
      benefit: fields[5] as String,
      isCustom: fields[6] as bool,
      createdBy: fields[7] as String?,
      exportedAt: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PresetModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.emoji)
      ..writeByte(3)
      ..write(obj.leftFrequency)
      ..writeByte(4)
      ..write(obj.rightFrequency)
      ..writeByte(5)
      ..write(obj.benefit)
      ..writeByte(6)
      ..write(obj.isCustom)
      ..writeByte(7)
      ..write(obj.createdBy)
      ..writeByte(8)
      ..write(obj.exportedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
