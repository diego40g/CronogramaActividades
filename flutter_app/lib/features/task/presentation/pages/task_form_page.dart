import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_list/task_list_bloc.dart';

@RoutePage()
class TaskFormPage extends StatefulWidget {
  final String? taskId;

  const TaskFormPage({
    super.key,
    @PathParam('taskId') this.taskId,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  TaskPriority _priority = TaskPriority.none;
  TaskStatus _status = TaskStatus.todo;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isAllDay = false;

  bool get isEditing => widget.taskId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
              ),
              validator: Validators.taskTitle,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description (optional)',
              ),
              validator: Validators.taskDescription,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            _buildPrioritySelector(),
            const SizedBox(height: 24),
            _buildDateTimeSection(),
            const SizedBox(height: 24),
            if (isEditing) _buildStatusSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<TaskPriority>(
          segments: TaskPriority.values.map((priority) {
            return ButtonSegment(
              value: priority,
              label: Text(_priorityLabel(priority)),
              icon: Icon(
                Icons.flag,
                color: _priorityColor(priority),
                size: 18,
              ),
            );
          }).toList(),
          selected: {_priority},
          onSelectionChanged: (selected) {
            setState(() => _priority = selected.first);
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('All day'),
          value: _isAllDay,
          onChanged: (value) {
            setState(() => _isAllDay = value);
          },
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today),
          title: const Text('Start'),
          subtitle: Text(
            _startTime?.toString() ?? 'Not set',
          ),
          onTap: () => _selectDateTime(isStart: true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.calendar_today),
          title: const Text('End'),
          subtitle: Text(
            _endTime?.toString() ?? 'Not set',
          ),
          onTap: () => _selectDateTime(isStart: false),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<TaskStatus>(
          segments: TaskStatus.values.map((status) {
            return ButtonSegment(
              value: status,
              label: Text(_statusLabel(status)),
            );
          }).toList(),
          selected: {_status},
          onSelectionChanged: (selected) {
            setState(() => _status = selected.first);
          },
        ),
      ],
    );
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (date == null || !mounted) return;

    if (_isAllDay) {
      setState(() {
        if (isStart) {
          _startTime = date;
        } else {
          _endTime = date;
        }
      });
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = dateTime;
      } else {
        _endTime = dateTime;
      }
    });
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // Validate date range
    if (_startTime != null && _endTime != null) {
      if (_endTime!.isBefore(_startTime!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    context.read<TaskListBloc>().add(TaskListEvent.taskCreated(
          title: _titleController.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          priority: _priority,
          startTime: _startTime,
          endTime: _endTime,
          isAllDay: _isAllDay,
        ));

    context.router.maybePop();
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.none:
        return 'None';
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
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

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}
