import 'dart:math';

import 'package:hive/hive.dart';

import '../../../../core/storage/hive_boxes.dart';
import '../../domain/models/student_skill.dart';
import '../hive/student_skill_record.dart';

class StudentSkillsRepository {
  StudentSkillsRepository({Box<StudentSkillRecord>? box})
      : _box = box ?? Hive.box<StudentSkillRecord>(HiveBoxes.studentSkills);

  final Box<StudentSkillRecord> _box;

  List<StudentSkill> list() {
    final items = _box.values
        .map((r) => StudentSkill(
              id: r.id,
              name: r.name,
              level: r.level,
              progress: r.progress,
              updatedAtMs: r.updatedAtMs,
            ))
        .toList();
    items.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
    return items;
  }

  Future<void> upsert(StudentSkill skill) async {
    await _box.put(
      skill.id,
      StudentSkillRecord(
        id: skill.id,
        name: skill.name,
        level: skill.level,
        progress: skill.progress.clamp(0, 100),
        updatedAtMs: skill.updatedAtMs,
      ),
    );
  }

  Future<StudentSkill> create({
    required String name,
    required String level,
    required int progress,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _randomId();
    final skill = StudentSkill(
      id: id,
      name: name.trim(),
      level: level,
      progress: progress.clamp(0, 100),
      updatedAtMs: now,
    );
    await upsert(skill);
    return skill;
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  String _randomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final r = Random();
    return List.generate(12, (_) => chars[r.nextInt(chars.length)]).join();
  }
}

