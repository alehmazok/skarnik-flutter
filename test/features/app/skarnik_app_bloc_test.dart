import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skarnik_flutter/core/pair.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/app/domain/repository/analytics_app_repository.dart';
import 'package:skarnik_flutter/features/app/domain/repository/database_repository.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/get_app_link_stream.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/handle_app_link.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/init_database.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/init_remote_config.dart';
import 'package:skarnik_flutter/features/app/domain/use_case/log_analytics_app_started.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';
import 'package:test/test.dart';

class MockDatabaseRepository extends Mock implements DatabaseRepository {}

class MockAnalyticsAppRepository extends Mock implements AnalyticsAppRepository {}

class MockInitRemoteConfigCase extends Mock implements InitRemoteConfigUseCase {}

class MockGetAppLinkStreamCase extends Mock implements GetAppLinkStreamUseCase {}

class MockHandleAppLinksCase extends Mock implements HandleAppLinkUseCase {}

class MockWord extends Mock implements Word {}

void main() {
  group('SkarnikAppBloc', () {
    final databaseRepository = MockDatabaseRepository();
    final analyticsAppRepository = MockAnalyticsAppRepository();
    final initRemoteConfigUseCase = MockInitRemoteConfigCase();
    final getAppLinkStreamUseCase = MockGetAppLinkStreamCase();
    final handleAppLinkUseCase = MockHandleAppLinksCase();

    SkarnikAppBloc newInstance() => SkarnikAppBloc(
          initDatabaseUseCase: InitDatabaseUseCase(databaseRepository),
          initRemoteConfigUseCase: initRemoteConfigUseCase,
          getAppLinkStreamUseCase: getAppLinkStreamUseCase,
          handleAppLinkUseCase: handleAppLinkUseCase,
          logAnalyticsAppOpenUseCase: LogAnalyticsAppOpenUseCase(analyticsAppRepository),
        );

    setUp(() {});

    group('_init()', () {
      blocTest(
        'emits failed state when remote config failed to initialize',
        setUp: () {
          when(
            () => initRemoteConfigUseCase.call(),
          ).thenAnswer(
            (_) async => Left(UnimplementedError('test remote config error')),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<SkarnikAppFailedState>()
              .having(
                (state) => state.error,
                'error',
                isA<UnimplementedError>(),
              )
              .having(
                (state) => (state.error as UnimplementedError).message,
                'error message',
                equals('test remote config error'),
              ),
        ],
      );

      blocTest(
        'emits failed state when database failed to initialize',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenThrow(UnimplementedError('test database error'));
        },
        build: () => newInstance(),
        expect: () => [
          isA<SkarnikAppFailedState>()
              .having(
                (state) => state.error,
                'error',
                isA<UnimplementedError>(),
              )
              .having(
                (state) => (state.error as UnimplementedError).message,
                'error message',
                equals('test database error'),
              ),
        ],
      );

      blocTest(
        'emits ok state when analytics failed to log event',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenAnswer((_) async => 1);
          when(() => analyticsAppRepository.logAppStarted()).thenThrow(UnimplementedError('test error'));
          when(() => getAppLinkStreamUseCase.call()).thenAnswer((_) async => const Right(Stream.empty()));
        },
        build: () => newInstance(),
        expect: () => [
          isA<SkarnikAppInitedState>(),
        ],
      );

      blocTest(
        'emits ok state when app links stream is failed',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenAnswer((_) async => 1);
          when(() => analyticsAppRepository.logAppStarted()).thenThrow(UnimplementedError('test error'));
          when(
            () => getAppLinkStreamUseCase.call(),
          ).thenAnswer(
            (_) async => Left(UnimplementedError('test app link stream error')),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<SkarnikAppInitedState>(),
        ],
      );

      blocTest(
        'emits ok state when app links stream has initial value',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenAnswer((_) async => 1);
          when(() => analyticsAppRepository.logAppStarted()).thenThrow(UnimplementedError('test error'));
          when(
            () => getAppLinkStreamUseCase.call(),
          ).thenAnswer(
            (_) async => Right(Stream.value('test app link')),
          );
          when(
            () => handleAppLinkUseCase.call(any()),
          ).thenAnswer(
            (_) async => const Right(Pair(3, 4)),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<SkarnikAppInitedState>(),
          isA<SkarnikAppAppLinkReceivedState>()
              .having((state) => state.langId, 'langId', 3)
              .having((state) => state.wordId, 'wordId', 4),
        ],
      );

      blocTest(
        'emits ok state when failed to handle initial app link',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenAnswer((_) async => 1);
          when(() => analyticsAppRepository.logAppStarted()).thenThrow(UnimplementedError('test error'));
          when(
            () => getAppLinkStreamUseCase.call(),
          ).thenAnswer(
            (_) async => Right(Stream.value('test app link')),
          );
          when(
            () => handleAppLinkUseCase.call(any()),
          ).thenAnswer(
            (_) async => Left(UnimplementedError('test handle app link error')),
          );
        },
        build: () => newInstance(),
        expect: () => [
          isA<SkarnikAppInitedState>(),
        ],
      );
    });

    group('_handleAppLink()', () {
      blocTest(
        'emits ok state when failed to handle initial app link',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenAnswer((_) async => 1);
          when(() => analyticsAppRepository.logAppStarted()).thenAnswer((_) async => true);
          when(
            () => getAppLinkStreamUseCase.call(),
          ).thenAnswer(
            (_) async => const Right(Stream.empty()),
          );
          when(
            () => handleAppLinkUseCase.call(any()),
          ).thenAnswer(
            (_) async => const Right(Pair(1, 2)),
          );
        },
        build: () => newInstance(),
        act: (bloc) => bloc.add(const SkarnikAppAppLinkReceived('test app link')),
        expect: () => [
          isA<SkarnikAppAppLinkReceivedState>()
              .having((state) => state.langId, 'langId', 1)
              .having((state) => state.wordId, 'wordId', 2),
          isA<SkarnikAppInitedState>(),
        ],
      );
    });
    group('_updateHistory()', () {
      late final Word word;
      blocTest(
        'emits ok state when update history event received',
        setUp: () {
          when(() => initRemoteConfigUseCase.call()).thenAnswer((_) async => const Right(true));
          when(() => databaseRepository.createDatabase()).thenAnswer((_) async => 1);
          when(() => analyticsAppRepository.logAppStarted()).thenAnswer((_) async => true);
          word = MockWord();
          when(() => word.wordId).thenReturn(1);
        },
        build: () => newInstance(),
        act: (bloc) => bloc.add(SkarnikAppHistoryUpdated(word)),
        expect: () => [
          isA<SkarnikAppHistoryUpdatedState>().having((state) => state.word.wordId, 'wordId', equals(1)),
          isA<SkarnikAppInitedState>(),
        ],
      );
    });
  });
}
