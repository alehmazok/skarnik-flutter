import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/history/presentation/history_cubit.dart';
import 'package:skarnik_flutter/features/home/domain/use_case/load_history.dart';
import 'package:skarnik_flutter/features/translation/domain/repository/history_repository.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockWord extends Mock implements Word {}

void main() {
  group('HistoryCubit', () {
    final historyRepository = MockHistoryRepository();

    HistoryCubit newInstance() => HistoryCubit(
          loadHistoryUseCase: LoadHistoryUseCase(historyRepository),
        );

    group('_load()', () {
      late final Word word;

      blocTest(
        'emits failed state when failed to retrieve words from database',
        setUp: () {
          when(
            () => historyRepository.getAll(any()),
          ).thenThrow(
            UnimplementedError('test error'),
          );
        },
        build: () => newInstance(),
        act: (cubit) => cubit.pagingController.notifyPageRequestListeners(0),
        expect: () => [
          isA<HistoryFailedState>(),
        ],
      );

      blocTest(
        'emits ok state when successfully retrieved words from database',
        setUp: () {
          word = MockWord();
          when(
            () => historyRepository.getAll(any()),
          ).thenAnswer(
            (_) async => [word],
          );
        },
        build: () => newInstance(),
        act: (cubit) => cubit.pagingController.notifyPageRequestListeners(0),
        expect: () => [],
        verify: (cubit) {
          final items = cubit.pagingController.itemList;
          expect(items?.length, equals(1));
          expect(items, equals([word]));
        },
      );
    });
  });
}
