import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skarnik_flutter/features/settings/domain/repository/offline_dictionaries_promo_repository.dart';

@Injectable(as: OfflineDictionariesPromoRepository)
class SharedPreferencesOfflineDictionariesPromoRepository
    implements OfflineDictionariesPromoRepository {
  static const _key = 'offline_dictionaries_promo_seen';

  final _prefs = SharedPreferencesAsync();

  @override
  Future<bool> isSeen() async => await _prefs.getBool(_key) ?? false;

  @override
  Future<void> markSeen() => _prefs.setBool(_key, true);
}
