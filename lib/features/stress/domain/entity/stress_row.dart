import 'package:equatable/equatable.dart';

class StressRow extends Equatable {
  final String title;
  final String content;

  @override
  List<Object> get props => [title, content];

  const StressRow({required this.title, required this.content});
}
