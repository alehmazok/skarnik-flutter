import 'package:flutter/material.dart';

import 'letter_button.dart';

class SearchExtraButtons extends StatelessWidget {
  static const _margin = 16.0;
  static const _spacerWidth = 8.0;

  const SearchExtraButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: const [
          LetterButton(letter: 'и'),
          SizedBox(width: _spacerWidth),
          LetterButton(letter: 'щ'),
          SizedBox(width: _spacerWidth),
          LetterButton(letter: 'ъ'),
          Spacer(),
          LetterButton(letter: 'і'),
          SizedBox(width: _spacerWidth),
          LetterButton(letter: 'ў'),
          SizedBox(width: _spacerWidth),
          LetterButton(letter: '\''),
        ],
      ),
    );
  }
}
