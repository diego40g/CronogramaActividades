import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

final class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred', super.code});
}

final class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred', super.code});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection', super.code});
}

final class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed', super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message = 'Resource not found', super.code});
}

final class SyncFailure extends Failure {
  const SyncFailure({super.message = 'Sync failed', super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unknown error occurred', super.code});
}
