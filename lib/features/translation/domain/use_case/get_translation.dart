import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';
import 'package:skarnik_flutter/core/exceptions.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/logging.dart';

import '../entity/translation.dart';
import '../repository/api_translation_repository.dart';
import '../repository/cloud_translation_repository.dart';
import '../repository/local_translation_repository.dart';
import '../repository/website_translation_repository.dart';

@injectable
class GetTranslationUseCase {
  final _logger = getLogger(GetTranslationUseCase);

  final LocalTranslationRepository _localTranslationRepository;
  final ApiTranslationRepository _apiWordRepository;
  final CloudTranslationRepository _cloudTranslationRepository;
  final WebsiteTranslationRepository _websiteTranslationRepository;

  GetTranslationUseCase({
    required LocalTranslationRepository localTranslationRepository,
    required ApiTranslationRepository apiWordRepository,
    required CloudTranslationRepository cloudTranslationRepository,
    required WebsiteTranslationRepository websiteTranslationRepository,
  }) : _localTranslationRepository = localTranslationRepository,
       _apiWordRepository = apiWordRepository,
       _cloudTranslationRepository = cloudTranslationRepository,
       _websiteTranslationRepository = websiteTranslationRepository;

  Future<UseCaseResult<Translation>> call(Word word) => _callLocal(word);

  Future<UseCaseResult<Translation>> _callLocal(Word word) async {
    final localWord = await _localTranslationRepository.getWord(
      langId: word.langId,
      wordId: word.wordId,
    );
    if (localWord == null) {
      return _callApi(word);
    }
    final redirectTo = localWord.redirectTo;
    if (redirectTo != null) {
      return Failure(
        TranslationRedirectError(
          word: word,
          redirectTo: redirectTo,
        ),
      );
    }
    final translation = localWord.toTranslation(
      word: word,
      source: 'local',
    );
    return Success(translation);
  }

  Future<UseCaseResult<Translation>> _callApi(Word word) async {
    try {
      final apiWord = await _apiWordRepository.getWord(word);
      final redirectTo = apiWord.redirectTo;
      if (redirectTo != null) {
        return Failure(
          TranslationRedirectError(
            word: word,
            redirectTo: redirectTo,
          ),
        );
      }
      final translation = apiWord.toTranslation(
        word: word,
        source: 'api',
      );
      return Success(translation);
    } catch (e, st) {
      _logger.warning('Адбылася памылка падчас запыту перакладу праз API:', e, st);
      return _callCloud(word);
    }
  }

  Future<UseCaseResult<Translation>> _callCloud(Word word) async {
    try {
      final apiWord = await _cloudTranslationRepository.getWord(word);
      final redirectTo = apiWord.redirectTo;
      if (redirectTo != null) {
        return Failure(
          TranslationRedirectError(
            word: word,
            redirectTo: redirectTo,
          ),
        );
      }
      final translation = apiWord.toTranslation(
        word: word,
        source: 'cloud',
      );
      return Success(translation);
    } catch (e, st) {
      _logger.warning('Адбылася памылка падчас запыту перакладу праз Cloud:', e, st);
      return _callWebsite(word);
    }
  }

  Future<UseCaseResult<Translation>> _callWebsite(Word word) async {
    try {
      final translation = await _websiteTranslationRepository.getTranslation(word);
      return Success(translation);
    } catch (e, st) {
      _logger.severe('Адбылася памылка падчас запыту перакладу праз сайт:', e, st);
      return Failure(e);
    }
  }
}
