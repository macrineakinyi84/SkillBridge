import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/readiness_entity.dart';
import '../../../../core/constants/firestore_constants.dart';

/// Firestore document model for readiness_scores (one doc per user: readiness_scores/{userId}).
class ReadinessScoreModel {
  const ReadinessScoreModel({
    required this.userId,
    required this.score,
    this.maxScore = 100,
    this.feedback,
    this.updatedAt,
  });

  final String userId;
  final int score;
  final int maxScore;
  final String? feedback;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FirestoreConstants.userId: userId,
      'score': score,
      'maxScore': maxScore,
      'feedback': feedback,
      FirestoreConstants.updatedAt: updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  static ReadinessScoreModel fromJson(Map<String, dynamic> json) {
    return ReadinessScoreModel(
      userId: json[FirestoreConstants.userId] as String? ?? '',
      score: (json['score'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 100,
      feedback: json['feedback'] as String?,
      updatedAt: _parseTimestamp(json[FirestoreConstants.updatedAt]),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  ReadinessEntity toEntity() => ReadinessEntity(
        score: score,
        maxScore: maxScore,
        feedback: feedback,
      );

  static ReadinessScoreModel fromEntity(String userId, ReadinessEntity entity, {DateTime? updatedAt}) {
    return ReadinessScoreModel(
      userId: userId,
      score: entity.score,
      maxScore: entity.maxScore,
      feedback: entity.feedback,
      updatedAt: updatedAt,
    );
  }
}
