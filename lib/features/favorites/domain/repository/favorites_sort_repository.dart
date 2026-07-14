import 'package:skarnik_flutter/features/favorites/domain/entity/favorites_sort_order.dart';

abstract interface class FavoritesSortRepository {
  Future<FavoritesSortOrder> getSortOrder();

  Future<void> setSortOrder(FavoritesSortOrder sortOrder);
}
