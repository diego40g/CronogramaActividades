import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/task.dart';
import '../../../domain/usecases/create_task.dart';
import '../../../domain/usecases/delete_task.dart';
import '../../../domain/usecases/get_tasks.dart';
import '../../../domain/usecases/update_task.dart';

part 'task_list_bloc.freezed.dart';

enum TaskFilter { all, todo, inProgress, done, today }

@injectable
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final GetTasks _getTasks;
  final CreateTask _createTask;
  final UpdateTask _updateTask;
  final DeleteTask _deleteTask;

  TaskListBloc(
    this._getTasks,
    this._createTask,
    this._updateTask,
    this._deleteTask,
  ) : super(const TaskListState()) {
    on<_Started>(_onStarted);
    on<_Refreshed>(_onRefreshed);
    on<_TaskCreated>(_onTaskCreated);
    on<_TaskStatusChanged>(_onTaskStatusChanged);
    on<_TaskDeleted>(_onTaskDeleted);
    on<_FilterChanged>(_onFilterChanged);
    on<_Cleared>(_onCleared);
  }

  Future<void> _onStarted(
    _Started event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _getTasks();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (tasks) => emit(state.copyWith(
        isLoading: false,
        tasks: tasks,
      )),
    );
  }

  Future<void> _onRefreshed(
    _Refreshed event,
    Emitter<TaskListState> emit,
  ) async {
    final result = await _getTasks();

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (tasks) => emit(state.copyWith(tasks: tasks, error: null)),
    );
  }

  Future<void> _onTaskCreated(
    _TaskCreated event,
    Emitter<TaskListState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _createTask(CreateTaskParams(
      title: event.title,
      description: event.description,
      priority: event.priority,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
    ));

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (task) {
        final updatedTasks = [...state.tasks, task];
        emit(state.copyWith(
          isLoading: false,
          tasks: updatedTasks,
        ));
      },
    );
  }

  Future<void> _onTaskStatusChanged(
    _TaskStatusChanged event,
    Emitter<TaskListState> emit,
  ) async {
    final updatedTask = event.task.copyWith(
      status: event.newStatus,
      updatedAt: DateTime.now(),
    );

    // Optimistic update
    final updatedTasks = state.tasks.map((t) {
      return t.id == event.task.id ? updatedTask : t;
    }).toList();

    emit(state.copyWith(tasks: updatedTasks));

    final result = await _updateTask(UpdateTaskParams(task: updatedTask));

    result.fold(
      (failure) {
        // Revert on failure
        add(const TaskListEvent.refreshed());
        // Could show error snackbar here
      },
      (_) {
        // Success - already updated optimistically
      },
    );
  }

  Future<void> _onTaskDeleted(
    _TaskDeleted event,
    Emitter<TaskListState> emit,
  ) async {
    // Optimistic delete
    final updatedTasks =
        state.tasks.where((t) => t.id != event.taskId).toList();
    emit(state.copyWith(tasks: updatedTasks));

    final result = await _deleteTask(event.taskId);

    result.fold(
      (failure) {
        // Revert on failure
        add(const TaskListEvent.refreshed());
      },
      (_) {
        // Success
      },
    );
  }

  void _onFilterChanged(
    _FilterChanged event,
    Emitter<TaskListState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onCleared(
    _Cleared event,
    Emitter<TaskListState> emit,
  ) {
    emit(const TaskListState());
  }
}

@Freezed(fromJson: false, toJson: false)
abstract class TaskListEvent with _$TaskListEvent {
  const factory TaskListEvent.started() = _Started;
  const factory TaskListEvent.refreshed() = _Refreshed;
  const factory TaskListEvent.taskCreated({
    required String title,
    String? description,
    TaskPriority? priority,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
  }) = _TaskCreated;
  const factory TaskListEvent.taskStatusChanged(
    Task task,
    TaskStatus newStatus,
  ) = _TaskStatusChanged;
  const factory TaskListEvent.taskDeleted(String taskId) = _TaskDeleted;
  const factory TaskListEvent.filterChanged(TaskFilter filter) = _FilterChanged;
  const factory TaskListEvent.cleared() = _Cleared;
}

@Freezed(fromJson: false, toJson: false)
abstract class TaskListState with _$TaskListState {
  const TaskListState._();

  const factory TaskListState({
    @Default([]) List<Task> tasks,
    @Default(TaskFilter.all) TaskFilter filter,
    @Default(false) bool isLoading,
    String? error,
  }) = _TaskListState;

  List<Task> get filteredTasks {
    return switch (filter) {
      TaskFilter.all => tasks,
      TaskFilter.todo => tasks.where((Task t) => t.status == TaskStatus.todo).toList(),
      TaskFilter.inProgress => tasks.where((Task t) => t.status == TaskStatus.inProgress).toList(),
      TaskFilter.done => tasks.where((Task t) => t.status == TaskStatus.done).toList(),
      TaskFilter.today => _todaysTasks,
    };
  }

  List<Task> get _todaysTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return tasks.where((Task t) {
      if (t.startTime == null) return false;
      return t.startTime!.isAfter(today) && t.startTime!.isBefore(tomorrow);
    }).toList();
  }

  bool get hasError => error != null;
}
