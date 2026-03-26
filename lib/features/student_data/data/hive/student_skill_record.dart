import 'package:hive/hive.dart';

part 'student_skill_record.g.dart';

@HiveType(typeId: 41)
class StudentSkillRecord extends HiveObject {
  StudentSkillRecord({
    required this.id,
    required this.name,
    required this.level,
    required this.progress,
    required this.updatedAtMs,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String level;

  @HiveField(3)
  final int progress;

  @HiveField(4)
  final int updatedAtMs;
}

