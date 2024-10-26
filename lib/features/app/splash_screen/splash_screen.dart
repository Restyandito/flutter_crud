import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({Key? key, this.child}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController untuk efek fade-in
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Inisialisasi animasi fade-in
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Mulai animasi
    _controller.forward();

    // Navigasi ke layar berikutnya setelah 3 detik
    Future.delayed(
      Duration(seconds: 3),
          () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => widget.child!),
              (route) => false,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Hentikan controller ketika layar beralih
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Animasi (gunakan logo aplikasi Anda)
                Icon(
                  Icons.flutter_dash,
                  color: Colors.white,
                  size: 80,
                ),
                SizedBox(height: 20),
                // Teks yang Menarik
                Text(
                  "Welcome To Flutter Firebase",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
