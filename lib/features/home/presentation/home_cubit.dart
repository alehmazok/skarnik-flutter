import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];

  const HomeState();
}

class HomeInitedState extends HomeState {
  const HomeInitedState();
}

class HomeFailedState extends HomeState {
  final Object error;

  @override
  List<Object> get props => [error];

  const HomeFailedState(this.error);
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeInitedState());
}
