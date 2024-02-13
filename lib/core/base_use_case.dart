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
