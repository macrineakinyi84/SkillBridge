import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/portfolio_item_entity.dart';
import '../../../../core/constants/firestore_constants.dart';

/// Firestore document model for portfolio items (collection: portfolios).
class PortfolioItemModel {
  const PortfolioItemModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      FirestoreConstants.id: id,
      FirestoreConstants.userId: userId,
      'title': title,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      FirestoreConstants.createdAt: createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      FirestoreConstants.updatedAt: updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  static PortfolioItemModel fromJson(Map<String, dynamic> json) {
    return PortfolioItemModel(
      id: json[FirestoreConstants.id] as String? ?? '',
      userId: json[FirestoreConstants.userId] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      url: json['url'] as String?,
      imageUrl: json['imageUrl'] as String?,
      createdAt: _parseTimestamp(json[FirestoreConstants.createdAt]),
      updatedAt: _parseTimestamp(json[FirestoreConstants.updatedAt]),
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  PortfolioItemEntity toEntity() => PortfolioItemEntity(
        id: id,
        title: title,
        description: description,
        url: url,
        imageUrl: imageUrl,
      );

  static PortfolioItemModel fromEntity(
    PortfolioItemEntity entity, {
    required String userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioItemModel(
      id: entity.id,
      userId: userId,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      imageUrl: entity.imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
