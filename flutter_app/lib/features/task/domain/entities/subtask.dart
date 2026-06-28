import 'package:equatable/equatable.dart';

class Subtask extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int order;
  final DateTime createdAt;

  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    required this.order,
    required this.createdAt,
  });

  Subtask copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    int? order,
    DateTime? createdAt,
  }) {
    return Subtask(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Subtask toggle() => copyWith(isCompleted: !isCompleted);

  @override
  List<Object?> get props => [id, taskId, title, isCompleted, order, createdAt];
}
