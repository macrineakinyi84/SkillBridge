import 'package:equatable/equatable.dart';

class StudentSkill extends Equatable {
  const StudentSkill({
    required this.id,
    required this.name,
    required this.level,
    required this.progress,
    required this.updatedAtMs,
  });

  final String id;
  final String name;
  final String level; // Beginner|Intermediate|Advanced (UI label for now)
  final int progress; // 0-100
  final int updatedAtMs;

  StudentSkill copyWith({String? name, String? level, int? progress, int? updatedAtMs}) {
    return StudentSkill(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  List<Object?> get props => [id, name, level, progress, updatedAtMs];
}

