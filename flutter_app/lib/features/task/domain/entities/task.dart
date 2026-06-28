import 'package:equatable/equatable.dart';

enum TaskStatus { todo, inProgress, done }
enum TaskPriority { none, low, medium, high }
enum RecurrenceRule { none, daily, weekly, monthly }

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final List<String> tags;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAllDay;
  final String? googleEventId;
  final String? googleCalendarId;
  final Recurrence? recurrence;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.none,
    this.tags = const [],
    this.startTime,
    this.endTime,
    this.isAllDay = false,
    this.googleEventId,
    this.googleCalendarId,
    this.recurrence,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isScheduled => startTime != null && endTime != null;
  bool get isSyncedWithGoogle => googleEventId != null;
  bool get isRecurring => recurrence != null && recurrence!.rule != RecurrenceRule.none;
  bool get isCompleted => status == TaskStatus.done;
  bool get isOverdue {
    if (endTime == null) return false;
    return !isCompleted && endTime!.isBefore(DateTime.now());
  }

  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    List<String>? tags,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    String? googleEventId,
    String? googleCalendarId,
    Recurrence? recurrence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      googleEventId: googleEventId ?? this.googleEventId,
      googleCalendarId: googleCalendarId ?? this.googleCalendarId,
      recurrence: recurrence ?? this.recurrence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        tags,
        startTime,
        endTime,
        isAllDay,
        googleEventId,
        googleCalendarId,
        recurrence,
        createdAt,
        updatedAt,
      ];
}

class Recurrence extends Equatable {
  final RecurrenceRule rule;
  final DateTime? until;

  const Recurrence({
    this.rule = RecurrenceRule.none,
    this.until,
  });

  Recurrence copyWith({
    RecurrenceRule? rule,
    DateTime? until,
  }) {
    return Recurrence(
      rule: rule ?? this.rule,
      until: until ?? this.until,
    );
  }

  @override
  List<Object?> get props => [rule, until];
}
