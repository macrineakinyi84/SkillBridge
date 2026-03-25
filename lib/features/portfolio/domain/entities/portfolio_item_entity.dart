import 'package:equatable/equatable.dart';

class PortfolioItemEntity extends Equatable {
  const PortfolioItemEntity({
    required this.id,
    required this.title,
    this.description,
    this.url,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String? description;
  final String? url;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, title, description, url, imageUrl];
}
