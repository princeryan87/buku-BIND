import 'package:flutter/material.dart';
import '../models/lisensi_model.dart';
import '../services/buku_service.dart';
import 'home_screen.dart';
import 'aktivasi_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  String _pesan = 'Memuat buku...';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    _init();
  }

  Future<void> _init() async {
    final results = await Future.wait([
      BukuService.init((persen, pesan) {
        if (mounted) setState(() => _pesan = pesan);
      }),
      LisensiService.getStatus(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);

    if (!mounted) return;
    final status = results[1] as StatusLisensi;

    if (status == StatusLisensi.expired) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AktivasiScreen()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1A6B3C), Color(0xFF2D9B5A), Color(0xFF4DC87A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                  child: const Center(
                      child: Text('📚', style: TextStyle(fontSize: 50))),
                ),
                const SizedBox(height: 24),
                const Text('Buku Digital',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 32),
                SizedBox(width: 32, height: 32,
                  child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.8), strokeWidth: 3)),
                const SizedBox(height: 16),
                Text(_pesan,
                    style: TextStyle(fontSize: 13,
                        color: Colors.white.withOpacity(0.75))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
