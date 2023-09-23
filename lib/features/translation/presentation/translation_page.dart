import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_bloc.dart';

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
        saveToHistoryUseCase: getIt<SaveToHistoryUseCase>(),
        logAnalyticsShareUseCase: getIt<LogAnalyticsShareUseCase>(),
        logAnalyticsTranslationUseCase: getIt<LogAnalyticsTranslationUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: word == null
              ? BlocBuilder<TranslationCubit, TranslationState>(
                  builder: (context, state) {
                    if (state is TranslationLoadedState) {
                      return Text('«${state.translation.word.word}»');
                    }
                    return const SizedBox.shrink();
                  },
                )
              : Text('«${word.word}»'),
          centerTitle: true,
          actions: [
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
