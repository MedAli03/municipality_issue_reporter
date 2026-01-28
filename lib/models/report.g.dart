// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

class ReportAdapter extends TypeAdapter<Report> {
  @override
  final int typeId = 1;

  @override
  Report read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return Report(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      governorate: fields[3] as String,
      city: fields[4] as String,
      landmark: fields[5] as String?,
      latitude: fields[6] as double?,
      longitude: fields[7] as double?,
      photoPath: fields[8] as String?,
      status: fields[9] as String,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Report obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.governorate)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.landmark)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude)
      ..writeByte(8)
      ..write(obj.photoPath)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
