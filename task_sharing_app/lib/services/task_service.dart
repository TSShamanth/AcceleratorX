import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get the reference to a user's specific tasks collection
  CollectionReference _tasksRef(String userId) {
    return _db.collection('users').doc(userId).collection('tasks');
  }

  // Stream of tasks for a specific user
  Stream<List<Task>> getTasks(String userId) {
    return _tasksRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
    });
  }

  // Add a new task for a specific user
  Future<void> addTask(String title, String userId) async {
    await _tasksRef(userId).add({
      'userId': userId,
      'title': title,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update task status
  Future<void> updateTaskStatus(String userId, String taskId, bool isCompleted) async {
    await _tasksRef(userId).doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  // Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    await _tasksRef(userId).doc(taskId).delete();
  }
}
