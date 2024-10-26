import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_crud/features/user_auth/presentation/pages/login_page.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk menghapus akun pengguna tertentu
  Future<void> _deleteAccount(String uid) async {
    try {
      await _authService.deleteAccount(uid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Akun berhasil dihapus"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal menghapus akun: $e"),
        backgroundColor: Colors.red,
      ));
    }
    setState(() {}); // Refresh data setelah penghapusan
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    try {
      await _authService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Logout berhasil"),
        backgroundColor: Colors.green,
      ));
      // Arahkan kembali ke halaman login dan bersihkan semua rute sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal logout: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  // Fungsi untuk menghapus akun yang sedang login
  Future<void> _deleteCurrentUserAccount() async {
    try {
      await _authService.deleteAccount(widget.user.uid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Akun Anda berhasil dihapus"),
        backgroundColor: Colors.green,
      ));
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Gagal menghapus akun: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Daftar Akun Pengguna",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Konfirmasi Hapus Akun"),
                    content: Text("Apakah Anda yakin ingin menghapus akun Anda sendiri?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text("Hapus"),
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete) {
                _deleteCurrentUserAccount();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada akun yang tersedia"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'];
              final uid = user['uid'];

              return Card(
                color: Colors.blue.shade50,
                shadowColor: Colors.blueAccent,
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    email,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("UID: $uid"),
                  trailing: widget.user.uid != uid
                      ? IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Konfirmasi Hapus Akun"),
                            content: Text("Apakah Anda yakin ingin menghapus akun ini?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text("Hapus"),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirmDelete) {
                        _deleteAccount(uid);
                      }
                    },
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
