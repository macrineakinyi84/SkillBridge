import 'package:equatable/equatable.dart';

/// Badge definition (earned or locked).
class BadgeModel extends Equatable {
  const BadgeModel({
    required this.id,
    required this.name,
    this.description,
    this.iconPath,
    this.earnedAt,
    this.requirementText,
  });

  final String id;
  final String name;
  final String? description;
  final String? iconPath;
  final DateTime? earnedAt;
  final String? requirementText;

  bool get isEarned => earnedAt != null;

  @override
  List<Object?> get props => [id, name, description, iconPath, earnedAt, requirementText];
}
