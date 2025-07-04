import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;

  // signUp
  Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // login
  Future<User?> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  // logOur
  Future<void> logout() => _auth.signOut();

  // current user uid
  String? get currentUID => _auth.currentUser?.uid;

  // current user email
  String? get currentEmail => _auth.currentUser?.email;

  //
}
