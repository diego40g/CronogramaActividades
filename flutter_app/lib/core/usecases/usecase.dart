import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

abstract class UseCaseNoParams<T> {
  Future<Either<Failure, T>> call();
}

abstract class StreamUseCase<T, Params> {
  Stream<Either<Failure, T>> call(Params params);
}

abstract class StreamUseCaseNoParams<T> {
  Stream<Either<Failure, T>> call();
}

class NoParams {
  const NoParams();
}
