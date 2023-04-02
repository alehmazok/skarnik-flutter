import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skarnik_flutter/di.skarnik.dart';
import 'package:skarnik_flutter/features/app/domain/entity/skarnik_word_ext.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:skarnik_flutter/features/app/presentation/skarnik_app_cubit.dart';

import '../domain/use_case/get_translation.dart';
import '../domain/use_case/get_word.dart';
import '../domain/use_case/save_to_history.dart';
import 'translation_cubit.dart';

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
      ),
      child: Scaffold(
        appBar: AppBar(
          title: word == null ? null : Text('«${word.word}»'),
          centerTitle: true,
          actions: [
            BlocBuilder<TranslationCubit, TranslationState>(
              builder: (context, state) {
                if (state is TranslationLoadedState) {
                  return IconButton(
                    onPressed: () => Share.share(state.translation.uri.toString()),
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
              context.read<SkarnikAppCubit>().updateHistory(state.translation.word);
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
                      SelectableHtml(
                        data: state.translation.html,
                        shrinkWrap: true,
                        style: {'div#skarnik': Style(fontSize: FontSize.large)},
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                        onAnchorTap: (url, context, attrs, element) => debugPrint('open: $url'),
                      ),
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
