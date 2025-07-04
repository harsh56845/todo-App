import 'package:cloud_firestore/cloud_firestore.dart';

class TodoController {
  final _db = FirebaseFirestore.instance;

  // Add task
  Future<void> addTask(String uid, String title) async {
    await _db.collection('todos').doc(uid).collection('All Todos').add({
      'uid': uid,
      'title': title,
      'isChecked': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // toggle is checked
  Future<void> toggle(String docId, bool val, String uid) async {
    await _db
        .collection('todos')
        .doc(uid)
        .collection('All Todos')
        .doc(docId)
        .update({'isChecked': val});
  }

  // Edit task
  Future<void> editTask(String docId, String editTitle, String uid) async {
    await _db
        .collection('todos')
        .doc(uid)
        .collection('All Todos')
        .doc(docId)
        .update({'title': editTitle});
  }

  // delete task
  Future<void> deleteTask(String docId, String uid) async {
    await _db
        .collection('todos')
        .doc(uid)
        .collection('All Todos')
        .doc(docId)
        .delete();
  }

  //fetch all todos
  Stream<QuerySnapshot> fetchTasks(String uid) {
    return _db
        .collection('todos')
        .doc(uid)
        .collection('All Todos')
        // .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
