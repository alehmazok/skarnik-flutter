import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';
import 'package:skarnik_flutter/strings.dart';

import '../domain/use_case/add_to_favorites.dart';
import '../domain/use_case/check_in_favorites.dart';
import '../domain/use_case/get_translation.dart';
import '../domain/use_case/get_word.dart';
import '../domain/use_case/log_analytics_add_to_favorites.dart';
import '../domain/use_case/log_analytics_share.dart';
import '../domain/use_case/log_analytics_translation.dart';
import '../domain/use_case/remove_from_favorites.dart';
import '../domain/use_case/save_to_history.dart';
import 'translation_cubit.dart';
import 'widgets/action_favorites.dart';
import 'widgets/action_share.dart';
import 'widgets/translation_html.dart';

class TranslationPage extends StatelessWidget {
  final Word? word;
  final int langId;
  final int wordId;
  final bool saveToHistory;

  final AddToFavoritesUseCase addToFavoritesUseCase;
  final CheckInFavoritesUseCase checkInFavoritesUseCase;
  final GetTranslationUseCase getTranslationUseCase;
  final GetWordUseCase getWordUseCase;
  final LogAnalyticsAddToFavoritesUseCase logAnalyticsAddToFavoritesUseCase;
  final LogAnalyticsShareUseCase logAnalyticsShareUseCase;
  final LogAnalyticsTranslationUseCase logAnalyticsTranslationUseCase;
  final RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  final SaveToHistoryUseCase saveToHistoryUseCase;

  TranslationPage({
    super.key,
    this.word,
    required this.langId,
    required this.wordId,
    this.saveToHistory = true,

    // Dependencies
    AddToFavoritesUseCase? addToFavoritesUseCase,
    CheckInFavoritesUseCase? checkInFavoritesUseCase,
    GetTranslationUseCase? getTranslationUseCase,
    GetWordUseCase? getWordUseCase,
    LogAnalyticsAddToFavoritesUseCase? logAnalyticsAddToFavoritesUseCase,
    LogAnalyticsShareUseCase? logAnalyticsShareUseCase,
    LogAnalyticsTranslationUseCase? logAnalyticsTranslationUseCase,
    RemoveFromFavoritesUseCase? removeFromFavoritesUseCase,
    SaveToHistoryUseCase? saveToHistoryUseCase,
  }) : addToFavoritesUseCase = addToFavoritesUseCase ?? getIt<AddToFavoritesUseCase>(),
       checkInFavoritesUseCase = checkInFavoritesUseCase ?? getIt<CheckInFavoritesUseCase>(),
       getTranslationUseCase = getTranslationUseCase ?? getIt<GetTranslationUseCase>(),
       getWordUseCase = getWordUseCase ?? getIt<GetWordUseCase>(),
       logAnalyticsAddToFavoritesUseCase =
           logAnalyticsAddToFavoritesUseCase ?? getIt<LogAnalyticsAddToFavoritesUseCase>(),
       logAnalyticsShareUseCase = logAnalyticsShareUseCase ?? getIt<LogAnalyticsShareUseCase>(),
       logAnalyticsTranslationUseCase =
           logAnalyticsTranslationUseCase ?? getIt<LogAnalyticsTranslationUseCase>(),
       removeFromFavoritesUseCase =
           removeFromFavoritesUseCase ?? getIt<RemoveFromFavoritesUseCase>(),
       saveToHistoryUseCase = saveToHistoryUseCase ?? getIt<SaveToHistoryUseCase>();

  factory TranslationPage.word({required Word word, required bool saveToHistory}) =>
      TranslationPage(
        word: word,
        langId: word.langId,
        wordId: word.wordId,
        saveToHistory: saveToHistory,
      );

  @override
  Widget build(BuildContext context) {
    final word = this.word;
    return BlocProvider(
      create: (context) => TranslationCubit(
        langId: langId,
        wordId: wordId,
        saveToHistory: saveToHistory,
        getWordUseCase: getWordUseCase,
        getTranslationUseCase: getTranslationUseCase,
        addToFavoritesUseCase: addToFavoritesUseCase,
        checkInFavoritesUseCase: checkInFavoritesUseCase,
        removeFromFavoritesUseCase: removeFromFavoritesUseCase,
        saveToHistoryUseCase: saveToHistoryUseCase,
        logAnalyticsShareUseCase: logAnalyticsShareUseCase,
        logAnalyticsTranslationUseCase: logAnalyticsTranslationUseCase,
        logAnalyticsAddToFavoritesUseCase: logAnalyticsAddToFavoritesUseCase,
      ),
      child: Scaffold(
        appBar: AppBar(
          actions: const [
            ActionFavorites(),
            ActionShare(),
          ],
        ),
        body: BlocConsumer<TranslationCubit, TranslationState>(
          listener: (context, state) {
            if (state is TranslationLoadedState) {
              context.read<SkarnikAppBloc>().add(SkarnikAppHistoryUpdated(state.translation.word));
            }
            if (state is TranslationAddedToFavoritesState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(Strings.addedToBookmarks),
                  ),
                );
            }
            if (state is TranslationRemovedFromFavoritesState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(Strings.removedFromBookmarks),
                  ),
                );
            }
            if (state is TranslationRedirectState) {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 15),
                    content: Text(
                      Strings.redirectedFromWord.replaceFirst('{}', state.word.word),
                    ),
                  ),
                );
              context.read<SkarnikAppBloc>().add(SkarnikAppAppLinkReceived(state.redirectTo));
            }
            if (state is TranslationFailedState) {
              // TODO: зрабіць больш дакладную і прыгожую апрацоўку памылак.
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 15),
                    content: Text(
                      Strings.sorryTranslationError,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.errorContainer,
                      ),
                    ),
                  ),
                );
            }
          },
          buildWhen: (_, current) => current is TranslationLoadedState,
          builder: (context, state) {
            final String wordText;
            if (state is TranslationLoadedState) {
              wordText = state.translation.maybeStressedWord;
            } else if (word != null) {
              wordText = word.word;
            } else {
              wordText = '';
            }
            if (state is TranslationLoadedState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '«$wordText»',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          state.translation.word.dictionary.translationName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TranslationHtml(content: state.translation.html),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
