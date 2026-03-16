import 'package:flutter_test/flutter_test.dart';
import 'package:skarnik_flutter/core/base_use_case.dart';

void main() {
  group('FutureResponseExt', () {
    // Test data
    const successValue = 'test-value';
    const errorValue = 'test-error';

    // Helper functions to create test futures
    Future<UseCaseResult<String>> successFuture() async => const Success(successValue);
    Future<UseCaseResult<String>> failureFuture() async => const Failure(errorValue);

    group('flatMap', () {
      test('should transform success value using callable', () async {
        // Arrange
        final future = successFuture();

        // Act
        final result = await future.flatMap<int>((value) async {
          return Success(value.length);
        });

        // Assert
        expect(result, isA<Success<int>>());
        expect((result as Success).result, equals(successValue.length));
      });

      test('should return original failure unchanged', () async {
        // Arrange
        final future = failureFuture();
        var wasCalled = false;

        // Act
        final result = await future.flatMap<int>((value) async {
          wasCalled = true;
          return Success(value.length);
        });

        // Assert
        expect(result, isA<Failure<int>>());
        expect((result as Failure).error, equals(errorValue));
        expect(wasCalled, isFalse);
      });
    });

    group('map', () {
      test('should transform success value synchronously', () async {
        // Arrange
        final future = successFuture();

        // Act
        final result = await future.map<int>((value) => value.length);

        // Assert
        expect(result, isA<Success<int>>());
        expect((result as Success).result, equals(successValue.length));
      });

      test('should return original failure unchanged', () async {
        // Arrange
        final future = failureFuture();
        var wasCalled = false;

        // Act
        final result = await future.map<int>((value) {
          wasCalled = true;
          return value.length;
        });

        // Assert
        expect(result, isA<Failure<int>>());
        expect((result as Failure).error, equals(errorValue));
        expect(wasCalled, isFalse);
      });
    });

    group('onSuccess', () {
      test('should execute callable on success and return original result', () async {
        // Arrange
        final future = successFuture();
        var capturedValue = '';

        // Act
        final result = await future.onSuccess((value) {
          capturedValue = value;
        });

        // Assert
        expect(result, isA<Success<String>>());
        expect((result as Success).result, equals(successValue));
        expect(capturedValue, equals(successValue));
      });

      test('should not execute callable on failure and return original result', () async {
        // Arrange
        final future = failureFuture();
        var wasCalled = false;

        // Act
        final result = await future.onSuccess((value) {
          wasCalled = true;
        });

        // Assert
        expect(result, isA<Failure<String>>());
        expect((result as Failure).error, equals(errorValue));
        expect(wasCalled, isFalse);
      });
    });

    group('onFailure', () {
      test('should execute callable on failure and return original result', () async {
        // Arrange
        final future = failureFuture();
        dynamic capturedError;

        // Act
        final result = await future.onFailure((error) {
          capturedError = error;
        });

        // Assert
        expect(result, isA<Failure<String>>());
        expect((result as Failure).error, equals(errorValue));
        expect(capturedError, equals(errorValue));
      });

      test('should not execute callable on success and return original result', () async {
        // Arrange
        final future = successFuture();
        var wasCalled = false;

        // Act
        final result = await future.onFailure((error) {
          wasCalled = true;
        });

        // Assert
        expect(result, isA<Success<String>>());
        expect((result as Success).result, equals(successValue));
        expect(wasCalled, isFalse);
      });
    });

    group('fold', () {
      test('should apply onSuccess function for success result', () async {
        // Arrange
        final future = successFuture();

        // Act
        final result = await future.fold<int>(
          (value) => value.length,
          (error) => -1,
        );

        // Assert
        expect(result, equals(successValue.length));
      });

      test('should apply onFailure function for failure result', () async {
        // Arrange
        final future = failureFuture();

        // Act
        final result = await future.fold<int>(
          (value) => value.length,
          (error) => -1,
        );

        // Assert
        expect(result, equals(-1));
      });
    });

    group('mapError', () {
      test('should transform error for failure result', () async {
        // Arrange
        final future = failureFuture();

        // Act
        final result = await future.mapError((error) => 'Transformed: $error');

        // Assert
        expect(result, isA<Failure<String>>());
        expect((result as Failure).error, equals('Transformed: $errorValue'));
      });

      test('should return original success unchanged', () async {
        // Arrange
        final future = successFuture();
        var wasCalled = false;

        // Act
        final result = await future.mapError((error) {
          wasCalled = true;
          return 'Transformed: $error';
        });

        // Assert
        expect(result, isA<Success<String>>());
        expect((result as Success).result, equals(successValue));
        expect(wasCalled, isFalse);
      });
    });
  });
}
