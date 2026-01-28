import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 1)
class Report extends HiveObject {
  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.governorate,
    required this.city,
    this.landmark,
    this.latitude,
    this.longitude,
    this.photoPath,
    required this.status,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String governorate;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final String? landmark;

  @HiveField(6)
  final double? latitude;

  @HiveField(7)
  final double? longitude;

  @HiveField(8)
  final String? photoPath;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final DateTime createdAt;
}
