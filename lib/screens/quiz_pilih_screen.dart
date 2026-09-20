import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/buku_model.dart';
import '../models/soal_model.dart';
import '../services/soal_service.dart';

const int jumlahSoalPerSesi = 100;

// ── Helper warna skor (dipakai bersama oleh daftar & hasil) ──
// 70-100 hijau • 40-69 kuning • 0-39 merah
Color warnaSkor(int s) {
  if (s >= 70) return const Color(0xFF2D9B5A);
  if (s >= 40) return const Color(0xFFF59E0B);
  return const Color(0xFFEF4444);
}

class _ProgressSesi {
  final List<int> urutanId;
  final int idx;
  final int benar;
  _ProgressSesi({required this.urutanId, required this.idx, required this.benar});

  factory _ProgressSesi.fromJson(Map<String, dynamic> j) => _ProgressSesi(
    urutanId: List<int>.from(j['ids'] ?? []),
    idx:      j['idx']   ?? 0,
    benar:    j['benar'] ?? 0,
  );

  Map<String, dynamic> toJson() => {'ids': urutanId, 'idx': idx, 'benar': benar};
}

String _keyProgress(int sesiIdx) => 'quiz_progress_$sesiIdx';
String _keySkor(int sesiIdx)     => 'quiz_skor_$sesiIdx';

class QuizPilihScreen extends StatefulWidget {
  final BukuMeta meta;
  const QuizPilihScreen({super.key, required this.meta});
  @override
  State<QuizPilihScreen> createState() => _QuizPilihScreenState();
}

class _QuizPilihScreenState extends State<QuizPilihScreen> {
  List<int?> _skor          = [null, null];
  List<int>  _jumlahSoal    = [0, 0];
  List<_ProgressSesi?> _progress = [null, null];
  bool       _loading       = true;
  bool       _adaSoal       = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ada   = await SoalService.adaSoal();
    final jml1  = await SoalService.jumlahSoalSemester(1);
    final jml2  = await SoalService.jumlahSoalSemester(2);

    final progress = List.generate(2, (i) {
      final raw = prefs.getString(_keyProgress(i));
      if (raw == null) return null;
      try { return _ProgressSesi.fromJson(jsonDecode(raw)); }
      catch (_) { return null; }
    });

    setState(() {
      _skor       = List.generate(2, (i) => prefs.getInt(_keySkor(i)));
      _jumlahSoal = [jml1, jml2];
      _progress   = progress;
      _adaSoal    = ada;
      _loading    = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A7BD5),
        foregroundColor: Colors.white,
        title: const Text('Simulasi Ujian',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3A7BD5)))
          : !_adaSoal
              ? _tidakAdaSoal()
              : ListView(padding: const EdgeInsets.all(16), children: [
                  _infoBox(),
                  const SizedBox(height: 16),
                  _kartuQuiz(0),
                  const SizedBox(height: 12),
                  _kartuQuiz(1),
                  const SizedBox(height: 80),
                ]),
    );
  }

  Widget _tidakAdaSoal() => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('📭', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        const Text('Soal belum tersedia',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('File soal.json tidak ditemukan di dalam paket buku ini.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center),
      ])),
  );

  Widget _infoBox() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xFFEBF3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A7BD5).withOpacity(0.3))),
    child: Row(children: [
      const Text('💡', style: TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Text(
        'Setiap sesi berisi $jumlahSoalPerSesi soal. Urutan soal & pilihan jawaban diacak setiap kali sesi baru dimulai. '
        'Tidak bisa kembali ke soal sebelumnya. Jika keluar di tengah sesi, progres akan tersimpan dan bisa dilanjutkan.',
        style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A6B)))),
    ]),
  );

  Widget _kartuQuiz(int idx) {
    final semester = idx + 1;
    final skor     = _skor[idx];
    final jml      = _jumlahSoal[idx];
    final progress = _progress[idx];
    final sedangJalan = progress != null;
    final emojis   = ['📘', '📗'];

    return GestureDetector(
      onTap: jml == 0 ? null : () async {
        await Navigator.push(context, MaterialPageRoute(
            builder: (_) => QuizSoalScreen(
                meta: widget.meta, sesiIdx: idx, semester: semester)));
        _load();
      },
      child: Opacity(
        opacity: jml == 0 ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
                  blurRadius: 10, offset: const Offset(0, 3))]),
          child: Row(children: [
            Text(emojis[idx], style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Simulasi Ujian Semester $semester',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(jml == 0 ? 'Belum ada soal'
                  : '${jml >= jumlahSoalPerSesi ? jumlahSoalPerSesi : jml} soal tersedia',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              const SizedBox(height: 8),
              if (sedangJalan)
                Row(children: [
                  const Icon(Icons.play_circle_fill, size: 15, color: Color(0xFF3A7BD5)),
                  const SizedBox(width: 4),
                  Text('Sedang berjalan: soal ${progress!.idx + 1}/${progress.urutanId.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                          color: Color(0xFF3A7BD5))),
                ])
              else if (skor != null)
                Row(children: [
                  const Text('Skor terbaik: ',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  Text('$skor / 100', style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w800, color: warnaSkor(skor))),
                ])
              else
                const Text('Belum pernah mengerjakan',
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
            ])),
            if (jml > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: (sedangJalan
                      ? const Color(0xFF3A7BD5)
                      : (skor != null ? warnaSkor(skor) : const Color(0xFF3A7BD5)))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sedangJalan
                      ? const Color(0xFF3A7BD5)
                      : (skor != null ? warnaSkor(skor) : const Color(0xFF3A7BD5))),
                ),
                child: sedangJalan
                    ? const Text('Lanjutkan\n→', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                            color: Color(0xFF3A7BD5)))
                    : (skor != null
                        ? Column(mainAxisSize: MainAxisSize.min, children: [
                            Text('$skor', style: TextStyle(fontSize: 22,
                                fontWeight: FontWeight.w900, color: warnaSkor(skor))),
                            Text('poin', style: TextStyle(fontSize: 10,
                                color: warnaSkor(skor))),
                          ])
                        : const Text('Mulai\n→', textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                color: Color(0xFF3A7BD5)))),
              ),
          ]),
        ),
      ),
    );
  }
}

class QuizSoalScreen extends StatefulWidget {
  final BukuMeta meta;
  final int sesiIdx;
  final int semester;
  const QuizSoalScreen({super.key, required this.meta,
      required this.sesiIdx, required this.semester});
  @override
  State<QuizSoalScreen> createState() => _QuizSoalScreenState();
}

class _QuizSoalScreenState extends State<QuizSoalScreen> {
  List<SoalModel> _soal      = [];
  List<int>       _urutanId  = [];
  int  _soalIdx  = 0;
  int? _dipilih;
  int  _benar    = 0;
  bool _selesai  = false;
  bool _loading  = true;
  late List<int> _urutanPilihan;
  SharedPreferences? _prefs;

  String get _key => _keyProgress(widget.sesiIdx);

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final pool  = await SoalService.getSoalSemester(widget.semester);
    final byId  = {for (final s in pool) s.id: s};

    List<int>? urutanId;
    int idx = 0, benar = 0;

    final saved = _prefs!.getString(_key);
    if (saved != null) {
      try {
        final data = _ProgressSesi.fromJson(jsonDecode(saved));
        // Pastikan semua id di progres lama masih ada di data soal saat ini
        if (data.urutanId.isNotEmpty &&
            data.urutanId.every((id) => byId.containsKey(id)) &&
            data.idx < data.urutanId.length) {
          urutanId = data.urutanId;
          idx      = data.idx;
          benar    = data.benar;
        }
      } catch (_) { /* abaikan, buat sesi baru */ }
    }

    if (urutanId == null) {
      final segar = pool.map((s) => s.id).toList()..shuffle(Random());
      urutanId = segar;
      idx = 0; benar = 0;
      await _simpanProgress(urutanId, idx, benar);
    }

    final soalUrut = urutanId.map((id) => byId[id]!).toList();
    setState(() {
      _soal     = soalUrut;
      _urutanId = urutanId!;
      _soalIdx  = idx;
      _benar    = benar;
      _loading  = false;
    });
    _acak();
  }

  Future<void> _simpanProgress(List<int> urutanId, int idx, int benar) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_key,
        jsonEncode(_ProgressSesi(urutanId: urutanId, idx: idx, benar: benar).toJson()));
  }

  Future<void> _hapusProgress() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_key);
  }

  void _acak() => _urutanPilihan = [0,1,2,3]..shuffle(Random());

  Future<void> _pilih(int idxTampil) async {
    if (_dipilih != null || _soal.isEmpty) return;
    final idxAsli = _urutanPilihan[idxTampil];
    setState(() => _dipilih = idxTampil);
    HapticFeedback.lightImpact();
    if (idxAsli == _soal[_soalIdx].jawaban) _benar++;

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    if (_soalIdx < _soal.length - 1) {
      final idxBaru = _soalIdx + 1;
      await _simpanProgress(_urutanId, idxBaru, _benar);
      setState(() { _soalIdx = idxBaru; _dipilih = null; _acak(); });
    } else {
      await _tampilHasil();
    }
  }

  Future<void> _tampilHasil() async {
    final skor  = (_benar / _soal.length * 100).round();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final lama  = prefs.getInt(_keySkor(widget.sesiIdx)) ?? 0;
    if (skor > lama) await prefs.setInt(_keySkor(widget.sesiIdx), skor);
    await _hapusProgress();
    setState(() => _selesai = true);
  }

  Future<void> _mulaiUlang() async {
    final pool  = await SoalService.getSoalSemester(widget.semester);
    final byId  = {for (final s in pool) s.id: s};
    final segar = pool.map((s) => s.id).toList()..shuffle(Random());
    await _simpanProgress(segar, 0, 0);
    setState(() {
      _urutanId = segar;
      _soal     = segar.map((id) => byId[id]!).toList();
      _soalIdx  = 0;
      _dipilih  = null;
      _benar    = 0;
      _selesai  = false;
      _acak();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(
        child: CircularProgressIndicator(color: widget.meta.warna)));
    if (_selesai) return _hasilScreen();
    if (_soal.isEmpty) return Scaffold(body: Center(child: Column(
        mainAxisSize: MainAxisSize.min, children: [
      const Text('😔', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 12),
      const Text('Tidak ada soal tersedia'),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: () => Navigator.pop(context),
          child: const Text('Kembali')),
    ])));

    final soal  = _soal[_soalIdx];
    final huruf = ['A','B','C','D'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Column(children: [
        Container(color: const Color(0xFF3A7BD5),
          child: SafeArea(bottom: false,
            child: Padding(padding: const EdgeInsets.fromLTRB(16,12,16,16),
              child: Column(children: [
                Row(children: [
                  GestureDetector(onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white)),
                  const SizedBox(width: 12),
                  Expanded(child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (_soalIdx+1)/_soal.length,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6),
                  )),
                  const SizedBox(width: 12),
                  Text('${_soalIdx+1}/${_soal.length}',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
                const SizedBox(height: 16),
                Text(soal.pertanyaan,
                    style: const TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w800, color: Colors.white,
                        height: 1.4),
                    textAlign: TextAlign.center),
              ]),
            ),
          ),
        ),
        Expanded(child: ListView(
          padding: const EdgeInsets.all(16),
          children: List.generate(4, (i) {
            final idxAsli = _urutanPilihan[i];
            final isBenar = idxAsli == soal.jawaban;
            final isSalah = _dipilih == i && !isBenar;
            Color bg  = Colors.white, bdr = Colors.transparent;
            if (_dipilih != null && isBenar) {
              bg = const Color(0xFFE8F7EF); bdr = const Color(0xFF2D9B5A);
            } else if (isSalah) {
              bg = const Color(0xFFFEF2F2); bdr = const Color(0xFFEF4444);
            }
            return GestureDetector(
              onTap: () => _pilih(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: bdr, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
                        blurRadius: 4, offset: const Offset(0,2))]),
                child: Row(children: [
                  Container(width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _dipilih != null && isBenar ? const Color(0xFF2D9B5A)
                          : isSalah ? const Color(0xFFEF4444)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text(huruf[i],
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                            color: (_dipilih != null && isBenar) || isSalah
                                ? Colors.white : const Color(0xFF374151))))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(soal.pilihan[idxAsli],
                      style: const TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w600))),
                ]),
              ),
            );
          }),
        )),
      ]),
    );
  }

  Widget _hasilScreen() {
    final skor = (_benar/_soal.length*100).round();
    String emoji='😔', pesan='Ayo Belajar Lagi!';
    if (skor>=90){emoji='🏆';pesan='Luar Biasa!';}
    else if(skor>=75){emoji='🌟';pesan='Bagus Sekali!';}
    else if(skor>=60){emoji='👍';pesan='Cukup Baik!';}
    else if(skor>=40){emoji='📚';pesan='Terus Belajar!';}

    final warna = warnaSkor(skor);

    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A6B), Color(0xFF3A7BD5)])),
      child: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 10),
          Text(pesan, style: const TextStyle(fontSize: 24,
              fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Simulasi Ujian Semester ${widget.semester}',
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(color: warna.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: warna, width: 2)),
            child: Column(children: [
              Text('$skor', style: TextStyle(fontSize: 72,
                  fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
              Text('dari 100 poin',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 24),
          Row(children: [
            _statBox('✅','$_benar','Benar'),
            const SizedBox(width: 12),
            _statBox('❌','${_soal.length-_benar}','Salah'),
          ]),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _mulaiUlang,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A7BD5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('🔄 Coba Lagi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          )),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('🏠 Kembali',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          )),
        ]),
      ))),
    ));
  }

  Widget _statBox(String ikon, String angka, String label) => Expanded(
    child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(ikon, style: const TextStyle(fontSize: 20)),
        Text(angka, style: const TextStyle(fontSize: 28,
            fontWeight: FontWeight.w900, color: Colors.white)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12)),
      ])),
  );
}
