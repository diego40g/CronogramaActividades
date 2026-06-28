import 'package:fpdart/fpdart.dart' hide Task;

import '../../../../core/error/failures.dart';
import '../entities/subtask.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasks();

  Future<Either<Failure, List<Task>>> getTasksByDateRange({
    required DateTime start,
    required DateTime end,
  });

  Future<Either<Failure, List<Task>>> getTasksForDate(DateTime date);

  Future<Either<Failure, Task>> getTaskById(String taskId);

  Future<Either<Failure, Task>> createTask(Task task);

  Future<Either<Failure, Task>> updateTask(Task task);

  Future<Either<Failure, void>> deleteTask(String taskId);

  Stream<Either<Failure, List<Task>>> watchTasks();

  Stream<Either<Failure, List<Task>>> watchTasksForDate(DateTime date);

  // Subtask operations
  Future<Either<Failure, List<Subtask>>> getSubtasks(String taskId);

  Future<Either<Failure, Subtask>> addSubtask(String taskId, Subtask subtask);

  Future<Either<Failure, Subtask>> updateSubtask(String taskId, Subtask subtask);

  Future<Either<Failure, void>> toggleSubtask(String taskId, String subtaskId);

  Future<Either<Failure, void>> deleteSubtask(String taskId, String subtaskId);

  Future<Either<Failure, void>> reorderSubtasks(String taskId, List<String> subtaskIds);
}
