import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk mengubah kata sandi pengguna
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Masukkan kata sandi lama untuk memverifikasi pengguna
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        // Re-authenticate pengguna
        await user.reauthenticateWithCredential(cred);

        // Mengubah kata sandi
        await user.updatePassword(newPassword);
      } else {
        throw "Pengguna tidak ditemukan";
      }
    } catch (e) {
      print("Error changing password: $e");
      throw e;
    }
  }

  // Fungsi registrasi pengguna
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

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
      await _firestore.collection('users').doc(uid).delete();

      User? user = _auth.currentUser;

      if (user != null && user.uid == uid) {
        await user.delete();
      }
    } catch (e) {
      print("Error deleting user: $e");
      throw e;
    }
  }
}
