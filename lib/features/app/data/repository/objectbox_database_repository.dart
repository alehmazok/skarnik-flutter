import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/database_repository.dart';
import '../model/objectbox_search_word.dart';
import '../service/objectbox_store_holder.dart';

@Injectable(as: DatabaseRepository)
class ObjectboxDatabaseRepository implements DatabaseRepository {
  static const _mdbFileName = 'data.mdb';
  static const _mdbAsset = 'assets/objectbox/$_mdbFileName';
  static const _mdbSearchDirectoryName = 'objectbox_search';
  static const _mdbHistoryDirectoryName = 'objectbox_history';

  final _logger = getLogger(ObjectboxDatabaseRepository);

  @override
  Future<int> createDatabase() async {
    final mdbCopyFile = await _getSearchMdbCopyFile();
    final exists = await mdbCopyFile.exists();
    if (!exists) {
      await _createDatabaseCopy(mdbCopyFile);
    }
    final searchStore = await _openObjectboxStore();
    final historyStore = await _openHistoryObjectboxStore();
    _registerStoreHolder(
      searchStore: searchStore,
      historyStore: historyStore,
    );
    final box = searchStore.box<ObjectboxSearchWord>();

    return box.count();
  }

  Future<File> _getSearchMdbCopyFile() async => File(join(await _getSearchObjectBoxDir(), _mdbFileName));

  Future<String> _getSearchObjectBoxDir() => _getObjectBoxDir(_mdbSearchDirectoryName);

  Future<String> _getObjectBoxDir(String dir) async {
    final documentsDir = await getApplicationDocumentsDirectory();

    return join(documentsDir.path, dir);
  }

  Future<void> _createDatabaseCopy(File file) async {
    _logger.fine('Make database copy from `$_mdbAsset` to `${file.path}`');
    await file.create(recursive: true);
    final assetsDataFile = await rootBundle.load(_mdbAsset);
    final totalBytes = assetsDataFile.buffer.asUint8List(
      assetsDataFile.offsetInBytes,
      assetsDataFile.lengthInBytes,
    );
    await file.writeAsBytes(totalBytes);
  }

  Future<Store> _openObjectboxStore() async => openStore(
        directory: await _getSearchObjectBoxDir(),
      );

  Future<Store> _openHistoryObjectboxStore() async => openStore(
        directory: await _getObjectBoxDir(_mdbHistoryDirectoryName),
      );

  void _registerStoreHolder({
    required Store searchStore,
    required Store historyStore,
  }) {
    final service = ObjectboxStoreHolder(
      searchStore: searchStore,
      historyStore: historyStore,
    );
    _logger.fine('Рэгіструем `${service.runtimeType}` залежнасць, як сінглтон.');
    getIt.registerSingleton(service);
  }
}
