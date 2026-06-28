import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

@injectable
class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  final TaskRepository _repository;

  UpdateTask(this._repository);

  @override
  Future<Either<Failure, Task>> call(UpdateTaskParams params) async {
    // Validation
    if (params.task.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Title cannot be empty'));
    }

    if (params.task.title.length > 200) {
      return const Left(ValidationFailure(message: 'Title cannot exceed 200 characters'));
    }

    if (params.task.startTime != null && params.task.endTime != null) {
      if (params.task.endTime!.isBefore(params.task.startTime!)) {
        return const Left(ValidationFailure(message: 'End time must be after start time'));
      }
    }

    final updatedTask = params.task.copyWith(updatedAt: DateTime.now());
    return _repository.updateTask(updatedTask);
  }
}

class UpdateTaskParams {
  final Task task;

  const UpdateTaskParams({required this.task});
}

@injectable
class UpdateTaskStatus implements UseCase<Task, UpdateTaskStatusParams> {
  final TaskRepository _repository;

  UpdateTaskStatus(this._repository);

  @override
  Future<Either<Failure, Task>> call(UpdateTaskStatusParams params) async {
    final result = await _repository.getTaskById(params.taskId);

    return result.fold(
      (failure) => Left(failure),
      (task) {
        final updatedTask = task.copyWith(
          status: params.newStatus,
          updatedAt: DateTime.now(),
        );
        return _repository.updateTask(updatedTask);
      },
    );
  }
}

class UpdateTaskStatusParams {
  final String taskId;
  final TaskStatus newStatus;

  const UpdateTaskStatusParams({
    required this.taskId,
    required this.newStatus,
  });
}
