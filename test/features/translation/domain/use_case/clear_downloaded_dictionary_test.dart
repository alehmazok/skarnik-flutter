import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/download_cursor_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/local_translation_repository.dart';
import 'package:skarnik_flutter/features/translation/domain/use_case/clear_downloaded_dictionary.dart';

class MockLocalTranslationRepository extends Mock implements LocalTranslationRepository {}

class MockDownloadCursorRepository extends Mock implements DownloadCursorRepository {}

void main() {
  const dictionary = Dictionary.tsbm;

  late MockLocalTranslationRepository localRepo;
  late MockDownloadCursorRepository cursorRepo;
  late ClearDownloadedDictionaryUseCase useCase;

  setUp(() {
    localRepo = MockLocalTranslationRepository();
    cursorRepo = MockDownloadCursorRepository();
    useCase = ClearDownloadedDictionaryUseCase(localRepo, cursorRepo);
  });

  test('clears local words and the resume cursor on success', () async {
    when(() => localRepo.clear(dictionary.langId)).thenAnswer((_) async {});
    when(() => cursorRepo.clearCursor(dictionary)).thenAnswer((_) async {});

    final result = await useCase(dictionary);

    expect(result, const Success<bool>(true));
    verify(() => localRepo.clear(dictionary.langId)).called(1);
    verify(() => cursorRepo.clearCursor(dictionary)).called(1);
  });

  test('returns Failure and skips clearing the cursor if local clear throws', () async {
    final error = Exception('disk error');
    when(() => localRepo.clear(dictionary.langId)).thenThrow(error);

    final result = await useCase(dictionary);

    expect(result, isA<Failure<bool>>());
    verifyNever(() => cursorRepo.clearCursor(dictionary));
  });
}
