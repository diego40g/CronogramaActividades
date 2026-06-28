import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignOut implements UseCaseNoParams<void> {
  final AuthRepository _repository;

  SignOut(this._repository);

  @override
  Future<Either<Failure, void>> call() async {
    return _repository.signOut();
  }
}
