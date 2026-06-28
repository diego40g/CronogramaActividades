import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../task/domain/entities/task.dart';
import '../../../task/presentation/bloc/task_list/task_list_bloc.dart';

@RoutePage()
class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  DateTime _selectedDate = DateTime.now();

  List<Task> _getTasksForDay(List<Task> tasks, DateTime day) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return tasks.where((task) {
      if (task.startTime == null) return false;
      return task.startTime!.isAfter(startOfDay) &&
          task.startTime!.isBefore(endOfDay);
    }).toList();
  }

  List<Task> _getTasksForHour(List<Task> tasks, int hour) {
    return tasks.where((task) {
      if (task.startTime == null) return false;
      return task.startTime!.hour == hour;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          final tasksForDay = _getTasksForDay(state.tasks, _selectedDate);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (tasksForDay.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${tasksForDay.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    return _buildTimeSlot(context, index, tasksForDay);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimeSlot(BuildContext context, int hour, List<Task> tasksForDay) {
    final timeLabel = '${hour.toString().padLeft(2, '0')}:00';
    final tasksForHour = _getTasksForHour(tasksForDay, hour);

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  timeLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ),
            ),
          ),
          Expanded(
            child: tasksForHour.isEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )
                : Column(
                    children: tasksForHour.map((task) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Material(
                          color: _getTaskColor(context, task),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              context.router.push(TaskDetailRoute(taskId: task.id));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (task.startTime != null)
                                          Text(
                                            '${task.startTime!.hour.toString().padLeft(2, '0')}:${task.startTime!.minute.toString().padLeft(2, '0')}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusIcon(task.status),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTaskColor(BuildContext context, Task task) {
    switch (task.priority) {
      case TaskPriority.high:
        return Colors.red.withValues(alpha: 0.15);
      case TaskPriority.medium:
        return Colors.orange.withValues(alpha: 0.15);
      case TaskPriority.low:
        return Colors.blue.withValues(alpha: 0.15);
      case TaskPriority.none:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Widget _buildStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case TaskStatus.inProgress:
        return const Icon(Icons.timelapse, color: Colors.orange, size: 20);
      case TaskStatus.todo:
        return const Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 20);
    }
  }
}
