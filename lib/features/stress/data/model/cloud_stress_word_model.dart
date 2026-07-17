import 'package:built_value/built_value.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:skarnik_flutter/serializers.dart';

import '../../domain/entity/stress_row.dart';
import '../../domain/entity/stress_source.dart';
import '../../domain/entity/stress_word_entry.dart';

part 'cloud_stress_word_model.g.dart';

// Covers both stress_word queries (resolveWordList selects id/word/lemma/
// table_name; getStressTable selects id/rows) -- one row shape, two
// extension mappings below, rather than two near-identical models.
//
// Column naming inherited from starnik.by's own API (GET /api/wordList
// returns "lemma": unstressed, "word": stressed) so StressWordEntry.lemma
// (compared against the plain search query) and StressWordEntry.word
// (display form) line up the same way regardless of source -- see
// tool/grammardb_import/parse.py's module docstring for the same note on
// the import side. Not the standard linguistic sense of "lemma".
abstract class CloudStressWordModel
    implements Built<CloudStressWordModel, CloudStressWordModelBuilder> {
  int get id;

  // Nullable: resolveWordList and getStressTable each select a different
  // column subset (see class doc), so only the fields the active query
  // asked for are guaranteed non-null.
  String? get word;

  String? get lemma;

  @BuiltValueField(wireName: 'table_name')
  String? get tableName;

  JsonObject? get rows;

  CloudStressWordModel._();

  factory CloudStressWordModel([void Function(CloudStressWordModelBuilder) updates]) =
      _$CloudStressWordModel;

  static CloudStressWordModel fromJson(Map<String, dynamic> json) {
    return serializers.deserializeWith(CloudStressWordModel.serializer, json)!;
  }

  static Serializer<CloudStressWordModel> get serializer => _$cloudStressWordModelSerializer;
}

extension CloudStressWordModelExt on CloudStressWordModel {
  StressWordEntry toEntity() => StressWordEntry(
    id: id,
    lemma: word!,
    word: lemma!,
    tableName: tableName,
    source: StressSource.cloud,
  );

  List<StressRow> toRows() => rows!.asList
      .map((e) => e as Map<String, dynamic>)
      .map((m) => StressRow(title: m['title'] as String, content: m['content'] as String))
      .toList();
}
