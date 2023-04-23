import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skarnik_flutter/features/app/domain/entity/word.dart';

class AlphabetListView extends StatelessWidget {
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
    'Ъ',
    'Ы',
    'Ь',
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
    'Ы',
    'Ь',
    'Э',
    'Ю',
    'Я',
  ];

  static const alphabets = [
    rusBelAlphabet,
    belRusAlphabet,
    belRusAlphabet,
  ];

  final int langId;
  final Iterable<Word> words;

  const AlphabetListView({
    Key? key,
    required this.langId,
    required this.words,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final words = this.words.toList();
    return AzListView(
      indexBarData: alphabets[langId],
      data: words.map((word) => WordSuspensionBean.fromWord(word)).toList(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return ListTile(
          title: Text(word.word),
          onTap: () => context.go(
            '/translate/word',
            extra: {
              'word': word,
              'save_to_history': true,
            },
          ),
        );
      },
    );
  }
}

class WordSuspensionBean extends ISuspensionBean {
  final String word;
  final String tag;

  WordSuspensionBean({required this.word, required this.tag});

  factory WordSuspensionBean.fromWord(Word word) => WordSuspensionBean(
        word: word.word,
        tag: word.word[0],
      );

  @override
  String getSuspensionTag() => tag;
}
