import 'package:equatable/equatable.dart';

class Pair<F, S> extends Equatable {
  final F first;
  final S second;

  @override
  List<Object?> get props => [first, second];

  const Pair(this.first, this.second);

  Pair<F, S> copy({F? first, S? second}) => Pair(first ?? this.first, second ?? this.second);

  Pair<F, S> copyWithFirst(F value) => copy(first: value);

  Pair<F, S> copyWithSecond(S value) => copy(second: value);
}
