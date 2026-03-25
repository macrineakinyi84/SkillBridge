import 'package:equatable/equatable.dart';

class AssessmentQuestion extends Equatable {
  const AssessmentQuestion({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.difficulty = 'medium',
  });

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String difficulty;

  @override
  List<Object?> get props => [id, text, options, correctIndex, difficulty];
}
