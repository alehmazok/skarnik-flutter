import 'dart:async';

import 'package:equatable/equatable.dart';

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
  /// Transforms the result by applying [callable] to the success value.
  /// Returns the original [Failure] unchanged.
  ///
  /// This is similar to `flatMap` but [callable] returns the transformed result
  /// directly instead of a [Future]. Use this when you need to chain asynchronous
  /// transformations.
  Future<UseCaseResult<R2>> flatMap<R2>(Future<UseCaseResult<R2>> Function(R1) callable) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => Future.value(Failure(error)),
      Success(result: final result) => callable(result),
    };
  }

  /// Transforms the success value using [callable].
  /// Returns the original [Failure] unchanged.
  ///
  /// This is a synchronous version of [flatMap] - [callable] is applied immediately
  /// and should return the transformed value (not wrapped in a [Future]).
  Future<UseCaseResult<R2>> map<R2>(R2 Function(R1) callable) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => Failure(error),
      Success(result: final result) => Success(callable(result)),
    };
  }

  /// Executes [callable] if the result is a [Success], otherwise does nothing.
  /// Returns the original [UseCaseResult] unchanged.
  ///
  /// This is useful for side effects (logging, tracking, etc.) without modifying
  /// the result. The callable receives the success value.
  Future<UseCaseResult<R1>> onSuccess(void Function(R1) callable) async {
    final result = await this;
    if (result is Success<R1>) {
      callable(result.result);
    }
    return result;
  }

  /// Executes [callable] if the result is a [Failure], otherwise does nothing.
  /// Returns the original [UseCaseResult] unchanged.
  ///
  /// This is useful for side effects on error (logging, metrics, etc.) without
  /// modifying the result. The callable receives the error.
  Future<UseCaseResult<R1>> onFailure(void Function(dynamic error) callable) async {
    final result = await this;
    if (result is Failure<R1>) {
      callable(result.error);
    }
    return result;
  }

  /// Folds the result into a single value by applying [onSuccess] or [onFailure].
  ///
  /// This is useful when you need to handle both success and failure cases
  /// and produce a final value. [onFailure] receives the error.
  Future<T> fold<T>(T Function(R1) onSuccess, T Function(dynamic error) onFailure) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => onFailure(error),
      Success(result: final result) => onSuccess(result),
    };
  }

  /// Transforms the error of a [Failure] result using [callable].
  /// Returns the original [Success] unchanged.
  ///
  /// This is useful for error normalization, wrapping, or converting errors
  /// to a different type. The callable receives the original error.
  Future<UseCaseResult<R1>> mapError(dynamic Function(dynamic error) callable) async {
    final result = await this;
    return switch (result) {
      Failure(error: final error) => Failure(callable(error)),
      Success(result: final result) => Success(result),
    };
  }
}
