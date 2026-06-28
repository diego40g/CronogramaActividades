import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/subtask.dart';

part 'subtask_model.freezed.dart';
part 'subtask_model.g.dart';

@freezed
abstract class SubtaskModel with _$SubtaskModel {
  const SubtaskModel._();

  const factory SubtaskModel({
    required String id,
    required String taskId,
    required String title,
    @Default(false) bool isCompleted,
    required int order,
    @JsonKey(fromJson: _timestampToDateTime, toJson: _dateTimeToTimestamp)
    required DateTime createdAt,
  }) = _SubtaskModel;

  factory SubtaskModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskModelFromJson(json);

  factory SubtaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubtaskModel.fromJson({...data, 'id': doc.id});
  }

  Subtask toEntity() {
    return Subtask(
      id: id,
      taskId: taskId,
      title: title,
      isCompleted: isCompleted,
      order: order,
      createdAt: createdAt,
    );
  }

  factory SubtaskModel.fromEntity(Subtask entity) {
    return SubtaskModel(
      id: entity.id,
      taskId: entity.taskId,
      title: entity.title,
      isCompleted: entity.isCompleted,
      order: entity.order,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}

DateTime _timestampToDateTime(dynamic timestamp) {
  if (timestamp is Timestamp) return timestamp.toDate();
  if (timestamp is DateTime) return timestamp;
  return DateTime.now();
}

dynamic _dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}
