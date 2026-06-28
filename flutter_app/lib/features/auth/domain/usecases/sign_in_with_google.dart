import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithGoogle implements UseCaseNoParams<AppUser> {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  @override
  Future<Either<Failure, AppUser>> call() async {
    return _repository.signInWithGoogle();
  }
}
