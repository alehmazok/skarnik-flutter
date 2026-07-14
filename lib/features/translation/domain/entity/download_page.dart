import 'package:equatable/equatable.dart';

import 'api_word.dart';

class DownloadPage extends Equatable {
  final List<ApiWord> words;
  final int cursor;

  const DownloadPage({required this.words, required this.cursor});

  @override
  List<Object?> get props => [words, cursor];
}
