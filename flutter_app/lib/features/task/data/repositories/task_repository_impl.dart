import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  TaskRepositoryImpl(this._remoteDataSource, this._authRepository);

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) throw const AuthException(message: 'User not authenticated');
    return user.id;
  }

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final models = await _remoteDataSource.getTasks(_userId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final models = await _remoteDataSource.getTasksByDateRange(
        _userId,
        start,
        end,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksForDate(DateTime date) async {
    try {
      final models = await _remoteDataSource.getTasksForDate(_userId, date);
      return Right(models.map((m) => m.toEntity()).toList());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String taskId) async {
    try {
      final model = await _remoteDataSource.getTaskById(_userId, taskId);
      return Right(model.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final created = await _remoteDataSource.createTask(_userId, model);
      return Right(created.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    try {
      final model = TaskModel.fromEntity(task);
      final updated = await _remoteDataSource.updateTask(_userId, model);
      return Right(updated.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await _remoteDataSource.deleteTask(_userId, taskId);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Task>>> watchTasks() {
    try {
      return _remoteDataSource.watchTasks(_userId).map(
            (models) => Right<Failure, List<Task>>(
              models.map((m) => m.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(Left(UnknownFailure(message: e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<Task>>> watchTasksForDate(DateTime date) {
    try {
      return _remoteDataSource.watchTasksForDate(_userId, date).map(
            (models) => Right<Failure, List<Task>>(
              models.map((m) => m.toEntity()).toList(),
            ),
          );
    } catch (e) {
      return Stream.value(Left(UnknownFailure(message: e.toString())));
    }
  }

  @override
  Future<Either<Failure, List<Subtask>>> getSubtasks(String taskId) async {
    try {
      final models = await _remoteDataSource.getSubtasks(_userId, taskId);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subtask>> addSubtask(
    String taskId,
    Subtask subtask,
  ) async {
    try {
      final model = SubtaskModel.fromEntity(subtask);
      final created =
          await _remoteDataSource.addSubtask(_userId, taskId, model);
      return Right(created.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Subtask>> updateSubtask(
    String taskId,
    Subtask subtask,
  ) async {
    try {
      final model = SubtaskModel.fromEntity(subtask);
      final updated =
          await _remoteDataSource.updateSubtask(_userId, taskId, model);
      return Right(updated.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSubtask(
    String taskId,
    String subtaskId,
  ) async {
    try {
      await _remoteDataSource.toggleSubtask(_userId, taskId, subtaskId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubtask(
    String taskId,
    String subtaskId,
  ) async {
    try {
      await _remoteDataSource.deleteSubtask(_userId, taskId, subtaskId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reorderSubtasks(
    String taskId,
    List<String> subtaskIds,
  ) async {
    try {
      await _remoteDataSource.reorderSubtasks(_userId, taskId, subtaskIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
