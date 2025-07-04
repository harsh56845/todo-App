import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController {
  final _db = FirebaseFirestore.instance;
  Future<void> createProfile(String uid, String userName) async {
    await _db.collection('todos').doc(uid).collection('profile').add({
      'username': userName,
    });
  }

  //fetch profile
  Stream<QuerySnapshot> fetchProfile(String uid) {
    return _db.collection('todos').doc(uid).collection('profile').snapshots();
  }
}
