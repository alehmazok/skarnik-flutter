import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract class BaseUseCase<R> {
  const BaseUseCase();
}

abstract class UseCase<R, A> extends BaseUseCase<R> {
  const UseCase() : super();

  FutureOr<R> call(A args);
}

abstract class NoArgsUseCase<R> extends BaseUseCase<R> {
  const NoArgsUseCase() : super();

  FutureOr<R> call();
}

abstract class EitherUseCase1<Result, Argument> extends BaseUseCase<Result> {
  const EitherUseCase1() : super();

  FutureOr<Either<Object, Result>> call(Argument argument);
}

abstract class EitherUseCase2<Result, Argument1, Argument2> extends BaseUseCase<Result> {
  const EitherUseCase2() : super();

  FutureOr<Either<Object, Result>> call(Argument1 argument1, Argument2 argument2);
}

abstract class EitherUseCase3<Result, Argument1, Argument2, Argument3> extends BaseUseCase<Result> {
  const EitherUseCase3() : super();

  FutureOr<Either<Object, Result>> call(Argument1 argument1, Argument2 argument2, Argument3 argument3);
}

abstract class EitherUseCase4<Result, Argument1, Argument2, Argument3, Argument4> extends BaseUseCase<Result> {
  const EitherUseCase4() : super();

  FutureOr<Either<Object, Result>> call(
    Argument1 argument1,
    Argument2 argument2,
    Argument3 argument3,
    Argument4 argument4,
  );
}

abstract class NoArgsEitherUseCase<R> extends BaseUseCase<R> {
  const NoArgsEitherUseCase() : super();

  FutureOr<Either<Object, R>> call();
}

// Discussion: https://github.com/spebbe/dartz/issues/34#issuecomment-593095745.
extension FutureEither<L, R> on Future<Either<L, R>> {
  Future<Either<L, R2>> flatMap<R2>(Function1<R, Future<Either<L, R2>>> f) {
    return then(
      (either1) => either1.fold(
        (l) => Future.value(left<L, R2>(l)),
        f,
      ),
    );
  }

  Future<Either<L, R2>> map<R2>(Function1<R, R2> f) {
    return then(
      (either1) => either1.fold(
        (l) => Future.value(left<L, R2>(l)),
        (r) => Future.value(right<L, R2>(f(r))),
      ),
    );
  }
}

sealed class UseCaseResult<R> extends Equatable {
  const UseCaseResult();
}

class Success<R> extends UseCaseResult<R> {
  final R result;

  @override
  List<Object?> get props => [result];

  const Success(this.result) : super();
}

class Failure<R> extends UseCaseResult<R> {
  final dynamic error;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [error, stackTrace];

  const Failure(this.error, [this.stackTrace]) : super();
}

extension FutureResponseExt<R1> on Future<UseCaseResult<R1>> {
  Future<UseCaseResult<R2>> flatMap<R2>(Future<UseCaseResult<R2>> Function(R1) callable) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => Future.value(Failure(error)),
      Success(result: final result) => callable(result),
    };
  }

  Future<UseCaseResult<R2>> map<R2>(R2 Function(R1) callable) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => Future.value(Failure(error)),
      Success(result: final result) => Future.value(Success(callable(result))),
    };
  }

  Future<Success<R2>> mapSuccess<R2>(R2 Function(R1) callable) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => throw error,
      Success(result: final result) => Future.value(Success(callable(result))),
    };
  }
}
