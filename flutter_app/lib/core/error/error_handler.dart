import 'package:logger/logger.dart';

import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void logError(Object error, [StackTrace? stackTrace]) {
    _logger.e('Error occurred', error: error, stackTrace: stackTrace);
  }

  static void logWarning(String message) {
    _logger.w(message);
  }

  static void logInfo(String message) {
    _logger.i(message);
  }

  static void logDebug(String message) {
    _logger.d(message);
  }

  static Failure handleException(Object exception) {
    if (exception is ServerException) {
      return ServerFailure(message: exception.message, code: exception.code);
    }
    if (exception is CacheException) {
      return CacheFailure(message: exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    }
    if (exception is AuthException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }
    if (exception is NotFoundException) {
      return NotFoundFailure(message: exception.message);
    }
    if (exception is ValidationException) {
      return ValidationFailure(message: exception.message);
    }

    logError(exception);
    return UnknownFailure(message: exception.toString());
  }
}
