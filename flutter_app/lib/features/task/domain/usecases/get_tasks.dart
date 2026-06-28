import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

@injectable
class GetTasks implements UseCaseNoParams<List<Task>> {
  final TaskRepository _repository;

  GetTasks(this._repository);

  @override
  Future<Either<Failure, List<Task>>> call() async {
    return _repository.getTasks();
  }
}

@injectable
class GetTasksForDate implements UseCase<List<Task>, DateTime> {
  final TaskRepository _repository;

  GetTasksForDate(this._repository);

  @override
  Future<Either<Failure, List<Task>>> call(DateTime date) async {
    return _repository.getTasksForDate(date);
  }
}

@injectable
class GetTasksByDateRange implements UseCase<List<Task>, DateRangeParams> {
  final TaskRepository _repository;

  GetTasksByDateRange(this._repository);

  @override
  Future<Either<Failure, List<Task>>> call(DateRangeParams params) async {
    return _repository.getTasksByDateRange(
      start: params.start,
      end: params.end,
    );
  }
}

class DateRangeParams {
  final DateTime start;
  final DateTime end;

  const DateRangeParams({required this.start, required this.end});
}
