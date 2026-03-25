import 'package:equatable/equatable.dart';

class SkillEntity extends Equatable {
  const SkillEntity({
    required this.id,
    required this.name,
    this.category,
    this.proficiencyLevel,
    this.notes,
  });

  final String id;
  final String name;
  final String? category;
  final String? proficiencyLevel;
  final String? notes;

  @override
  List<Object?> get props => [id, name, category, proficiencyLevel, notes];
}
