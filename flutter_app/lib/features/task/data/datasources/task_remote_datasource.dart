import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/subtask_model.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<List<TaskModel>> getTasksByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  );
  Future<List<TaskModel>> getTasksForDate(String userId, DateTime date);
  Future<TaskModel> getTaskById(String userId, String taskId);
  Future<TaskModel> createTask(String userId, TaskModel task);
  Future<TaskModel> updateTask(String userId, TaskModel task);
  Future<void> deleteTask(String userId, String taskId);
  Stream<List<TaskModel>> watchTasks(String userId);
  Stream<List<TaskModel>> watchTasksForDate(String userId, DateTime date);

  // Subtasks
  Future<List<SubtaskModel>> getSubtasks(String userId, String taskId);
  Future<SubtaskModel> addSubtask(String userId, String taskId, SubtaskModel subtask);
  Future<SubtaskModel> updateSubtask(String userId, String taskId, SubtaskModel subtask);
  Future<void> toggleSubtask(String userId, String taskId, String subtaskId);
  Future<void> deleteSubtask(String userId, String taskId, String subtaskId);
  Future<void> reorderSubtasks(String userId, String taskId, List<String> subtaskIds);
}

@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  TaskRemoteDataSourceImpl(this._firestore);

  CollectionReference<Map<String, dynamic>> _tasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _subtasksRef(
    String userId,
    String taskId,
  ) {
    return _tasksRef(userId).doc(taskId).collection('subtasks');
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await _tasksRef(userId)
          .orderBy('startTime', descending: false)
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch tasks');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snapshot = await _tasksRef(userId)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startTime', isLessThan: Timestamp.fromDate(end))
          .orderBy('startTime')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch tasks');
    }
  }

  @override
  Future<List<TaskModel>> getTasksForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getTasksByDateRange(userId, startOfDay, endOfDay);
  }

  @override
  Future<TaskModel> getTaskById(String userId, String taskId) async {
    try {
      final doc = await _tasksRef(userId).doc(taskId).get();

      if (!doc.exists) {
        throw const NotFoundException(message: 'Task not found');
      }

      return TaskModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch task');
    }
  }

  @override
  Future<TaskModel> createTask(String userId, TaskModel task) async {
    try {
      final docRef = await _tasksRef(userId).add(task.toFirestore());
      final doc = await docRef.get();
      return TaskModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to create task');
    }
  }

  @override
  Future<TaskModel> updateTask(String userId, TaskModel task) async {
    try {
      await _tasksRef(userId).doc(task.id).update(task.toFirestore());
      return task;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update task');
    }
  }

  @override
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      // Delete all subtasks first
      final subtasks = await _subtasksRef(userId, taskId).get();
      final batch = _firestore.batch();
      for (final doc in subtasks.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_tasksRef(userId).doc(taskId));
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete task');
    }
  }

  @override
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _tasksRef(userId).orderBy('startTime').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Stream<List<TaskModel>> watchTasksForDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _tasksRef(userId)
        .where('startTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<List<SubtaskModel>> getSubtasks(String userId, String taskId) async {
    try {
      final snapshot =
          await _subtasksRef(userId, taskId).orderBy('order').get();
      return snapshot.docs
          .map((doc) => SubtaskModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch subtasks');
    }
  }

  @override
  Future<SubtaskModel> addSubtask(
    String userId,
    String taskId,
    SubtaskModel subtask,
  ) async {
    try {
      final docRef =
          await _subtasksRef(userId, taskId).add(subtask.toFirestore());
      final doc = await docRef.get();
      return SubtaskModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to add subtask');
    }
  }

  @override
  Future<SubtaskModel> updateSubtask(
    String userId,
    String taskId,
    SubtaskModel subtask,
  ) async {
    try {
      await _subtasksRef(userId, taskId)
          .doc(subtask.id)
          .update(subtask.toFirestore());
      return subtask;
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to update subtask');
    }
  }

  @override
  Future<void> toggleSubtask(
    String userId,
    String taskId,
    String subtaskId,
  ) async {
    try {
      final doc = await _subtasksRef(userId, taskId).doc(subtaskId).get();
      if (!doc.exists) {
        throw const NotFoundException(message: 'Subtask not found');
      }

      final data = doc.data()!;
      final isCompleted = data['isCompleted'] as bool? ?? false;
      await _subtasksRef(userId, taskId)
          .doc(subtaskId)
          .update({'isCompleted': !isCompleted});
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to toggle subtask');
    }
  }

  @override
  Future<void> deleteSubtask(
    String userId,
    String taskId,
    String subtaskId,
  ) async {
    try {
      await _subtasksRef(userId, taskId).doc(subtaskId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to delete subtask');
    }
  }

  @override
  Future<void> reorderSubtasks(
    String userId,
    String taskId,
    List<String> subtaskIds,
  ) async {
    try {
      final batch = _firestore.batch();
      for (var i = 0; i < subtaskIds.length; i++) {
        batch.update(
          _subtasksRef(userId, taskId).doc(subtaskIds[i]),
          {'order': i},
        );
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(
          message: e.message ?? 'Failed to reorder subtasks');
    }
  }
}
