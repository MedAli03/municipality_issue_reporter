import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 1)
class Report extends HiveObject {
  Report({
    required this.id,
    required this.title,
    required this.description,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? photoPath;

  @HiveField(4)
  final double? latitude;

  @HiveField(5)
  final double? longitude;

  @HiveField(6)
  final DateTime createdAt;
}
