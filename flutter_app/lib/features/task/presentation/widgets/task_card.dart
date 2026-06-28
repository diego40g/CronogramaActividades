import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/date_time_ext.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final void Function(TaskStatus)? onStatusChanged;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: Card(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusCheckbox(context),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildPriorityIndicator(),
                    ],
                  ),
                  if (task.isScheduled) ...[
                    const SizedBox(height: 12),
                    _buildScheduleInfo(context),
                  ],
                  if (task.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildTags(context),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCheckbox(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final nextStatus = switch (task.status) {
          TaskStatus.todo => TaskStatus.inProgress,
          TaskStatus.inProgress => TaskStatus.done,
          TaskStatus.done => TaskStatus.todo,
        };
        onStatusChanged?.call(nextStatus);
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _statusColor(task.status),
            width: 2,
          ),
          color: task.isCompleted ? _statusColor(task.status) : null,
        ),
        child: task.isCompleted
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    if (task.priority == TaskPriority.none) {
      return const SizedBox.shrink();
    }

    return Icon(
      Icons.flag,
      size: 18,
      color: _priorityColor(task.priority),
    );
  }

  Widget _buildScheduleInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          task.isAllDay ? Icons.calendar_today : Icons.access_time,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          task.isAllDay
              ? task.startTime!.relativeDate
              : '${task.startTime!.relativeDate} ${task.startTime!.timeOnly}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        if (task.isOverdue) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Overdue',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: task.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        );
      }).toList(),
    );
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  Color _priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return AppColors.priorityNone;
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
    }
  }
}
