import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    @Default('') String description,
    @Default('todo') String status,
    @Default(0) int priority,
    @Default([]) List<String> tags,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    DateTime? startTime,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    DateTime? endTime,
    @Default(false) bool isAllDay,
    String? googleEventId,
    String? googleCalendarId,
    RecurrenceModel? recurrence,
    @JsonKey(fromJson: _timestampToDateTimeRequired, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
    @JsonKey(fromJson: _timestampToDateTimeRequired, toJson: _dateTimeToTimestamp)
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel.fromJson({...data, 'id': doc.id});
  }

  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      status: _parseStatus(status),
      priority: _parsePriority(priority),
      tags: tags,
      startTime: startTime,
      endTime: endTime,
      isAllDay: isAllDay,
      googleEventId: googleEventId,
      googleCalendarId: googleCalendarId,
      recurrence: recurrence?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TaskModel.fromEntity(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status.name,
      priority: entity.priority.index,
      tags: entity.tags,
      startTime: entity.startTime,
      endTime: entity.endTime,
      isAllDay: entity.isAllDay,
      googleEventId: entity.googleEventId,
      googleCalendarId: entity.googleCalendarId,
      recurrence: entity.recurrence != null
          ? RecurrenceModel.fromEntity(entity.recurrence!)
          : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  static TaskStatus _parseStatus(String status) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => TaskStatus.todo,
    );
  }

  static TaskPriority _parsePriority(int priority) {
    return TaskPriority.values[priority.clamp(0, 3)];
  }
}

@freezed
abstract class RecurrenceModel with _$RecurrenceModel {
  const RecurrenceModel._();

  const factory RecurrenceModel({
    @Default('none') String rule,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    DateTime? until,
  }) = _RecurrenceModel;

  factory RecurrenceModel.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceModelFromJson(json);

  Recurrence toEntity() {
    return Recurrence(
      rule: RecurrenceRule.values.firstWhere(
        (e) => e.name == rule,
        orElse: () => RecurrenceRule.none,
      ),
      until: until,
    );
  }

  factory RecurrenceModel.fromEntity(Recurrence entity) {
    return RecurrenceModel(
      rule: entity.rule.name,
      until: entity.until,
    );
  }
}

DateTime? _timestampToDateTime(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is DateTime) return timestamp;
  return null;
}

DateTime _timestampToDateTimeRequired(dynamic timestamp) {
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is DateTime) return timestamp;
  return DateTime.now();
}

dynamic _dateTimeToTimestamp(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}
