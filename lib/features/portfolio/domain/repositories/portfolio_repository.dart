import '../entities/portfolio_item_entity.dart';

/// Repository for user portfolio items (Firestore collection: portfolios).
abstract class PortfolioRepository {
  /// All portfolio items for [userId].
  Future<List<PortfolioItemEntity>> getPortfolioItems(String userId);

  /// Stream of portfolio items for [userId].
  Stream<List<PortfolioItemEntity>> watchPortfolioItems(String userId);

  /// Single item by id.
  Future<PortfolioItemEntity?> getPortfolioItemById(String userId, String itemId);

  /// Add a portfolio item for the user.
  Future<PortfolioItemEntity> addPortfolioItem(String userId, PortfolioItemEntity item);

  /// Update an existing portfolio item.
  Future<void> updatePortfolioItem(String userId, PortfolioItemEntity item);

  /// Delete a portfolio item.
  Future<void> deletePortfolioItem(String userId, String itemId);
}
