import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AppUser? _cachedUser;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  AppUser? get currentUser => _cachedUser;

  @override
  Stream<AppUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        return null;
      }

      try {
        final userModel = await _remoteDataSource.getUser(firebaseUser.uid);
        _cachedUser = userModel.toEntity();
        return _cachedUser;
      } catch (e) {
        _cachedUser = null;
        return null;
      }
    });
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      _cachedUser = userModel.toEntity();
      return Right(_cachedUser!);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      _cachedUser = null;
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> getCurrentUser() async {
    final firebaseUser = _remoteDataSource.currentFirebaseUser;
    if (firebaseUser == null) {
      return const Left(AuthFailure(message: 'No user signed in'));
    }

    try {
      final userModel = await _remoteDataSource.getUser(firebaseUser.uid);
      _cachedUser = userModel.toEntity();
      return Right(_cachedUser!);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUser>> updateUser(AppUser user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _remoteDataSource.updateUser(userModel);
      _cachedUser = user;
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(String token) async {
    if (_cachedUser == null) {
      return const Left(AuthFailure(message: 'No user signed in'));
    }

    try {
      await _remoteDataSource.updateFcmToken(_cachedUser!.id, token);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
