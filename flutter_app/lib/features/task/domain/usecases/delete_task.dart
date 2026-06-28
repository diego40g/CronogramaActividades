import 'package:fpdart/fpdart.dart' hide Task;
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/task_repository.dart';

@injectable
class DeleteTask implements UseCase<void, String> {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  @override
  Future<Either<Failure, void>> call(String taskId) async {
    return _repository.deleteTask(taskId);
  }
}
