import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../search_cubit.dart';

class LetterButton extends StatelessWidget {
  final String letter;

  const LetterButton({
    Key? key,
    required this.letter,
  })  : assert(letter.length == 1),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'letter_button_$letter',
      onPressed: () => context.read<SearchCubit>().appendLetter(letter),
      mini: true,
      child: Text(
        letter,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
