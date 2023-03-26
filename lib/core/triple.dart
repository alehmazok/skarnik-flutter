import 'package:equatable/equatable.dart';

import 'pair.dart';

class Triple<F, S, T> extends Equatable {
  final F first;
  final S second;
  final T third;

  @override
  List<Object?> get props => [first, second, third];

  const Triple(this.first, this.second, this.third);

  factory Triple.fromPair(Pair<F, S> pair, T third) => Triple(pair.first, pair.second, third);

  Triple<F, S, T> copy({F? first, S? second, T? third}) => Triple(
        first ?? this.first,
        second ?? this.second,
        third ?? this.third,
      );

  Triple<F, S, T> copyWithFirst(F value) => copy(first: value);

  Triple<F, S, T> copyWithSecond(S value) => copy(second: value);

  Triple<F, S, T> copyWithThird(T value) => copy(third: value);
}
