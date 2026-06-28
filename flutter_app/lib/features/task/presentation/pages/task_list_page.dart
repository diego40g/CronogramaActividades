import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_states/empty_state.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../bloc/task_list/task_list_bloc.dart';
import '../widgets/task_card.dart';

@RoutePage()
class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses the global TaskListBloc from app.dart
    return const _TaskListView();
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          BlocBuilder<TaskListBloc, TaskListState>(
            buildWhen: (prev, curr) => prev.filter != curr.filter,
            builder: (context, state) {
              return PopupMenuButton<TaskFilter>(
                icon: const Icon(Icons.filter_list),
                onSelected: (filter) {
                  context.read<TaskListBloc>().add(
                        TaskListEvent.filterChanged(filter),
                      );
                },
                itemBuilder: (_) => TaskFilter.values.map((filter) {
                  return PopupMenuItem(
                    value: filter,
                    child: Row(
                      children: [
                        if (state.filter == filter)
                          const Icon(Icons.check, size: 18)
                        else
                          const SizedBox(width: 18),
                        const SizedBox(width: 8),
                        Text(_filterLabel(filter)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          if (state.isLoading && state.tasks.isEmpty) {
            return const Center(child: LoadingIndicator(size: 48));
          }

          if (state.hasError && state.tasks.isEmpty) {
            return ErrorState(
              message: state.error!,
              onRetry: () {
                context.read<TaskListBloc>().add(const TaskListEvent.started());
              },
            );
          }

          if (state.filteredTasks.isEmpty) {
            return EmptyState(
              icon: Icons.task_alt,
              title: 'No tasks yet',
              subtitle: 'Create your first task to get started',
              action: ElevatedButton.icon(
                onPressed: () {
                  context.router.push(TaskFormRoute());
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Task'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TaskListBloc>().add(const TaskListEvent.refreshed());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = state.filteredTasks[index];
                return TaskCard(
                  task: task,
                  onTap: () {
                    context.router.push(TaskDetailRoute(taskId: task.id));
                  },
                  onStatusChanged: (status) {
                    context.read<TaskListBloc>().add(
                          TaskListEvent.taskStatusChanged(task, status),
                        );
                  },
                  onDelete: () {
                    context.read<TaskListBloc>().add(
                          TaskListEvent.taskDeleted(task.id),
                        );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(TaskFormRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.todo:
        return 'To Do';
      case TaskFilter.inProgress:
        return 'In Progress';
      case TaskFilter.done:
        return 'Done';
      case TaskFilter.today:
        return 'Today';
    }
  }
}
