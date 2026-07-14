import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skarnik_flutter/features/favorites/domain/entity/favorites_sort_order.dart';
import 'package:skarnik_flutter/features/favorites/domain/repository/favorites_sort_repository.dart';

@Injectable(as: FavoritesSortRepository)
class SharedPreferencesFavoritesSortRepository implements FavoritesSortRepository {
  static const _key = 'favorites_sort_order';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<FavoritesSortOrder> getSortOrder() async {
    final name = await _prefs.getString(_key);
    return FavoritesSortOrder.values.firstWhere(
      (it) => it.name == name,
      orElse: () => FavoritesSortOrder.dateAdded,
    );
  }

  @override
  Future<void> setSortOrder(FavoritesSortOrder sortOrder) => _prefs.setString(_key, sortOrder.name);
}
