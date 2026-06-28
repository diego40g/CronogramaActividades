import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> get authStateChanges;

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AppUser>> getCurrentUser();

  Future<Either<Failure, AppUser>> updateUser(AppUser user);

  Future<Either<Failure, void>> updateFcmToken(String token);
}
