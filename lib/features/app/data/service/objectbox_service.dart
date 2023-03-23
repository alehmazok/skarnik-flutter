import 'package:skarnik_flutter/features/app/data/model/objectbox_word.dart';
import 'package:skarnik_flutter/objectbox.g.dart';

class ObjectboxService {
  final Store store;

  Box<ObjectboxWord> get wordBox => store.box<ObjectboxWord>();

  ObjectboxService(this.store);
}
