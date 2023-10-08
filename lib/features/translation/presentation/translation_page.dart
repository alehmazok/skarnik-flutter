import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';

import '../domain/use_case/add_to_favorites.dart';
import '../domain/use_case/check_in_favorites.dart';
import '../domain/use_case/get_translation.dart';
import '../domain/use_case/get_word.dart';
import '../domain/use_case/log_analytics_share.dart';
import '../domain/use_case/log_analytics_translation.dart';
import '../domain/use_case/save_to_history.dart';
import 'translation_cubit.dart';
import 'widgets/translation_html.dart';

class TranslationPage extends StatelessWidget {
  final Word? word;
  final int langId;
  final int wordId;
  final bool saveToHistory;

  const TranslationPage({
    Key? key,
    this.word,
    required this.langId,
    required this.wordId,
    this.saveToHistory = true,
  }) : super(key: key);

  factory TranslationPage.word({required Word word, required bool saveToHistory}) => TranslationPage(
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
        getWordUseCase: getIt<GetWordUseCase>(),
        getTranslationUseCase: getIt<GetTranslationUseCase>(),
        addToFavoritesUseCase: getIt<AddToFavoritesUseCase>(),
        checkInFavoritesUseCase: getIt<CheckInFavoritesUseCase>(),
        saveToHistoryUseCase: getIt<SaveToHistoryUseCase>(),
        logAnalyticsShareUseCase: getIt<LogAnalyticsShareUseCase>(),
        logAnalyticsTranslationUseCase: getIt<LogAnalyticsTranslationUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            BlocBuilder<TranslationCubit, TranslationState>(
              builder: (context, state) {
                if (state is TranslationLoadedState) {
                  return IconButton(
                    onPressed: () => context.read<TranslationCubit>().addToFavorites(state.translation),
                    icon: Icon(state.inFavorites ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            BlocBuilder<TranslationCubit, TranslationState>(
              builder: (context, state) {
                if (state is TranslationLoadedState) {
                  return IconButton(
                    onPressed: () => context.read<TranslationCubit>().share(state.translation),
                    icon: const Icon(Icons.share),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
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
                    content: Text(
                      'Дададзена ў закладкі.',
                    ),
                  ),
                );
            }
            if (state is TranslationFailedState) {
              // TODO: зрабіць больш дакладную і прыгожую апрацоўку памылак.
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 15),
                    content: Text(
                      'Прабачце, адбылася памылка перакладу слова.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.errorContainer,
                      ),
                    ),
                  ),
                );
            }
          },
          builder: (context, state) {
            if (state is TranslationLoadedState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: BlocBuilder<TranslationCubit, TranslationState>(
                          builder: (context, state) {
                            final String text;
                            if (word != null) {
                              text = word.word;
                            } else if (state is TranslationLoadedState) {
                              text = state.translation.word.word;
                            } else {
                              text = '';
                            }
                            return Text(
                              '«$text»',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          state.translation.word.translationDirection,
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
