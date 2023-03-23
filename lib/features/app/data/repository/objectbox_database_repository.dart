import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/logging.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

import '../../domain/repository/database_repository.dart';
import '../model/objectbox_word.dart';
import '../service/objectbox_service.dart';

@Injectable(as: DatabaseRepository)
class ObjectboxDatabaseRepository implements DatabaseRepository {
  static const _mdbFileName = 'data.mdb';
  static const _mdbAsset = 'assets/objectbox/$_mdbFileName';
  static const _mdbCopyDirectoryName = 'objectbox_copy';

  final _logger = getLogger(ObjectboxDatabaseRepository);

  @override
  Future<int> createDatabase() async {
    final mdbCopyFile = await _getMdbCopyFile();
    final exists = await mdbCopyFile.exists();
    if (!exists) {
      await _createDatabaseCopy(mdbCopyFile);
    }
    final store = await _openObjectboxStore();
    _registerService(store);
    final box = store.box<ObjectboxWord>();

    return box.count();
  }

  Future<File> _getMdbCopyFile() async => File(join(await _getObjectBoxCopyDir(), _mdbFileName));

  Future<String> _getObjectBoxCopyDir() async {
    final documentsDir = await getApplicationDocumentsDirectory();

    return join(documentsDir.path, _mdbCopyDirectoryName);
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

  Future<Store> _openObjectboxStore() async => openStore(directory: await _getObjectBoxCopyDir());

  void _registerService(Store store) {
    final service = ObjectboxService(store);
    _logger.fine('Рэгіструем `${service.runtimeType}` залежнасць, як сінглтон.');
    getIt.registerSingleton(service);
  }
}
