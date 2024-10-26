import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Registrasi pengguna baru dan simpan data di Firestore
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      // Simpan data pengguna ke Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'uid': user.uid,
          'created_at': Timestamp.now(),
        });
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi login
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fungsi hapus akun
  Future<void> deleteAccount(String uid) async {
    try {
      // Menghapus data pengguna dari Firestore
      await _firestore.collection('users').doc(uid).delete();

      // Menghapus pengguna dari Firebase Authentication
      User? user = _auth.currentUser;

      // Jika pengguna yang sedang login adalah yang akan dihapus
      if (user != null && user.uid == uid) {
        await user.delete();
      }
    } catch (e) {
      print("Error deleting user: $e");
      throw e;
    }
  }
}
