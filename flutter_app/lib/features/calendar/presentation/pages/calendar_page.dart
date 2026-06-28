import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../task/domain/entities/task.dart';
import '../../../task/presentation/bloc/task_list/task_list_bloc.dart';
import '../../../task/presentation/widgets/task_card.dart';

@RoutePage()
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.calendarToday.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.calendarSelected,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const Divider(),
          Expanded(
            child: _selectedDay != null
                ? BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (context, state) {
                      final tasksForDay = _getTasksForDay(state.tasks, _selectedDay!);

                      if (tasksForDay.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks for this day',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasksForDay.length,
                        itemBuilder: (context, index) {
                          final task = tasksForDay[index];
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
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Select a day to view tasks',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Task> _getTasksForDay(List<Task> tasks, DateTime day) {
    return tasks.where((task) {
      if (task.startTime == null) return false;
      return isSameDay(task.startTime!, day);
    }).toList();
  }
}
