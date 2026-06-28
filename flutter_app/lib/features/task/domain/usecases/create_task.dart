import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

@injectable
class CreateTask implements UseCase<Task, CreateTaskParams> {
  final TaskRepository _repository;

  CreateTask(this._repository);

  @override
  Future<Either<Failure, Task>> call(CreateTaskParams params) async {
    // Validation
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Title cannot be empty'));
    }

    if (params.title.length > 200) {
      return const Left(ValidationFailure(message: 'Title cannot exceed 200 characters'));
    }

    if (params.startTime != null && params.endTime != null) {
      if (params.endTime!.isBefore(params.startTime!)) {
        return const Left(ValidationFailure(message: 'End time must be after start time'));
      }
    }

    final now = DateTime.now();
    final task = Task(
      id: '',
      title: params.title.trim(),
      description: params.description ?? '',
      status: TaskStatus.todo,
      priority: params.priority ?? TaskPriority.none,
      tags: params.tags ?? [],
      startTime: params.startTime,
      endTime: params.endTime,
      isAllDay: params.isAllDay ?? false,
      recurrence: params.recurrence,
      createdAt: now,
      updatedAt: now,
    );

    return _repository.createTask(task);
  }
}

class CreateTaskParams {
  final String title;
  final String? description;
  final TaskPriority? priority;
  final List<String>? tags;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool? isAllDay;
  final Recurrence? recurrence;

  const CreateTaskParams({
    required this.title,
    this.description,
    this.priority,
    this.tags,
    this.startTime,
    this.endTime,
    this.isAllDay,
    this.recurrence,
  });
}
