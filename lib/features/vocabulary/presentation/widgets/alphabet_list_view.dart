import 'dart:io';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:skarnik_flutter/features/app/domain/entity/dictionary.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';
import 'package:vibration/vibration.dart';

import '../vocabulary_cubit.dart';

class SimpleListView extends StatefulWidget {
  static const rusBelAlphabet = [
    'А',
    'Б',
    'В',
    'Г',
    'Д',
    'Е',
    'Ё',
    'Ж',
    'З',
    'И',
    'Й',
    'К',
    'Л',
    'М',
    'Н',
    'О',
    'П',
    'Р',
    'С',
    'Т',
    'У',
    'Ф',
    'Х',
    'Ц',
    'Ч',
    'Ш',
    'Щ',
    'Э',
    'Ю',
    'Я',
  ];
  static const belRusAlphabet = [
    'А',
    'Б',
    'В',
    'Г',
    'Д',
    'Е',
    'Ё',
    'Ж',
    'З',
    'І',
    'Й',
    'К',
    'Л',
    'М',
    'Н',
    'О',
    'П',
    'Р',
    'С',
    'Т',
    'У',
    'Ў',
    'Ф',
    'Х',
    'Ц',
    'Ч',
    'Ш',
    'Э',
    'Ю',
    'Я',
  ];

  static final alphabetsMap = {
    Dictionary.belRus.langId: belRusAlphabet,
    Dictionary.tsbm.langId: belRusAlphabet,
    Dictionary.rusBel.langId: rusBelAlphabet,
  };

  final int langId;
  final List<Word> words;

  const SimpleListView({
    super.key,
    required this.langId,
    required this.words,
  });

  @override
  State<SimpleListView> createState() => _SimpleListViewState();
}

class _SimpleListViewState extends State<SimpleListView> {
  final _wordScrollController = ItemScrollController();
  final _indexBarDragNotifier = IndexBarDragNotifier();
  late final VoidCallback _indexBarListener;
  bool _hasVibration = false;

  Future<void> _initVibration() async {
    // Не падабаецца, як працуе вібрацыя на Андройдзе.
    _hasVibration = !Platform.isAndroid && (await Vibration.hasVibrator() ?? false);
  }

  @override
  void initState() {
    super.initState();
    _indexBarListener = () {
      final letter = _indexBarDragNotifier.dragDetails.value.tag;
      if (letter != null) {
        _onLetterPressed(letter);
      }
    };
    _indexBarDragNotifier.dragDetails.addListener(_indexBarListener);
    _initVibration();
  }

  @override
  void dispose() {
    _indexBarDragNotifier.dragDetails.removeListener(_indexBarListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alphabet = SimpleListView.alphabetsMap[widget.langId]!;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 10,
          child: ScrollablePositionedList.builder(
            itemScrollController: _wordScrollController,
            itemBuilder: (context, index) {
              final word = widget.words[index];
              return ListTile(
                title: Text(word.word),
                onTap: () {
                  context.go(
                    '/translate/word',
                    extra: {
                      'word': word,
                      'save_to_history': true,
                    },
                  );
                  context.read<VocabularyCubit>().logAnalyticsWord(word);
                },
              );
            },
            itemCount: widget.words.length,
          ),
        ),
        SizedBox(
          width: 24,
          child: IndexBar(
            data: alphabet,
            indexBarDragListener: _indexBarDragNotifier,
            itemHeight: MediaQuery.of(context).size.height < 700 ? 14 : 16,
          ),
        ),
      ],
    );
  }

  void _onLetterPressed(String letter) {
    letter = letter.toLowerCase();
    final index = widget.words.indexWhere((it) => it.letter == letter);
    if (index > 0) {
      _wordScrollController.jumpTo(index: index);
      if (_hasVibration) {
        Vibration.vibrate(duration: 10);
      }
    }
  }
}
