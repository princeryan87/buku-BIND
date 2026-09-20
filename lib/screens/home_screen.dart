import 'package:flutter/material.dart';
import '../models/lisensi_model.dart';
import '../models/buku_model.dart';
import '../services/buku_service.dart';
import 'daftar_bab_screen.dart';
import 'quiz_pilih_screen.dart';
import 'aktivasi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BukuMeta?      _meta;
  StatusLisensi? _status;
  int            _sisaHari = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final meta   = await BukuService.init();
    final status = await LisensiService.getStatus();
    final sisa   = await LisensiService.sisaHariFreeview();
    if (mounted) setState(() { _meta = meta; _status = status; _sisaHari = sisa; });
  }

  Color get _warna => _meta?.warna ?? const Color(0xFF2D9B5A);

  @override
  Widget build(BuildContext context) {
    if (_meta == null) {
      return Scaffold(body: Center(
          child: CircularProgressIndicator(color: _warna)));
    }

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220, pinned: true,
          backgroundColor: _warna,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [
                    HSLColor.fromColor(_warna).withLightness(0.25).toColor(),
                    _warna,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _badgeStatus(),
                      const SizedBox(height: 12),
                      Text(_meta!.namaBuku,
                          style: const TextStyle(fontSize: 24,
                              fontWeight: FontWeight.w900, color: Colors.white,
                              height: 1.2)),
                      const SizedBox(height: 6),
                      Text('Kelas ${_meta!.kelas} · ${_meta!.mapel}',
                          style: TextStyle(fontSize: 13,
                              color: Colors.white.withOpacity(0.75))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([
            if (_status == StatusLisensi.freeview) ...[
              _bannerFreeview(), const SizedBox(height: 20),
            ],

            const Text('Menu Utama',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7280), letterSpacing: 1)),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(child: _kartuMenu(
                ikon: '📖', judul: 'Baca Buku',
                sub: '${_meta!.totalBab} bab', warna: _warna,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => DaftarBabScreen(meta: _meta!))),
              )),
              const SizedBox(width: 12),
              Expanded(child: _kartuMenu(
                ikon: '🎯', judul: 'Latihan Quiz',
                sub: '2 sesi', warna: const Color(0xFF3A7BD5),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => QuizPilihScreen(meta: _meta!))),
              )),
            ]),
            const SizedBox(height: 24),

            const Text('Informasi Buku',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7280), letterSpacing: 1)),
            const SizedBox(height: 12),
            _infoCard(),
            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }

  Widget _badgeStatus() {
    if (_status == StatusLisensi.aktif) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Text('✅ Lisensi Aktif',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: Colors.white)),
      );
    }
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AktivasiScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.25),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: Text('⏳ Percobaan · Sisa $_sisaHari hari',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }

  Widget _bannerFreeview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(children: [
        const Text('⏳', style: TextStyle(fontSize: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Masa percobaan: $_sisaHari hari lagi',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: Color(0xFF92600A))),
          const Text('Beli lisensi untuk akses tanpa batas',
              style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
        ])),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AktivasiScreen())),
          style: TextButton.styleFrom(
              foregroundColor: Colors.orange.shade700),
          child: const Text('Aktivasi',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _kartuMenu({
    required String ikon, required String judul,
    required String sub, required Color warna,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: warna.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(ikon,
                style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 12),
          Text(judul, style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(sub, style: const TextStyle(fontSize: 12,
              color: Color(0xFF6B7280))),
        ]),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(children: [
        _infoRow('📚', 'Total Bab',      '${_meta!.totalBab} bab'),
        _infoRow('📄', 'Total Halaman',  '${_meta!.totalHalaman} halaman'),
        _infoRow('🏫', 'Kelas',          'Kelas ${_meta!.kelas}'),
        _infoRow('📖', 'Mata Pelajaran', _meta!.mapel),
      ]),
    );
  }

  Widget _infoRow(String ikon, String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Text(ikon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 13,
            color: Color(0xFF6B7280))),
        const Spacer(),
        Text(nilai, style: const TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
