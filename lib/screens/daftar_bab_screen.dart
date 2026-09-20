import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/buku_model.dart';
import '../services/buku_service.dart';

// ════════════════════════════════════════
// DAFTAR BAB
// ════════════════════════════════════════
class DaftarBabScreen extends StatelessWidget {
  final BukuMeta meta;
  const DaftarBabScreen({super.key, required this.meta});

  @override
  Widget build(BuildContext context) {
    final sem1 = meta.bab.where((b) => b.semester == 1).toList();
    final sem2 = meta.bab.where((b) => b.semester == 2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: meta.warna,
        foregroundColor: Colors.white,
        title: const Text('Daftar Bab',
            style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (sem1.isNotEmpty) ...[
            _header('📚 Semester 1'),
            ...sem1.map((b) => _babItem(context, b)),
          ],
          if (sem2.isNotEmpty) ...[
            const SizedBox(height: 8),
            _header('📚 Semester 2'),
            ...sem2.map((b) => _babItem(context, b)),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _header(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
            color: Color(0xFF6B7280), letterSpacing: 1)),
  );

  Widget _babItem(BuildContext context, BabModel bab) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) =>
              BacaBabScreen(meta: meta, bab: bab))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: meta.warna.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(child: Text('${bab.id}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
                    color: meta.warna))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bab ${bab.id}',
                style: const TextStyle(fontSize: 11,
                    color: Color(0xFF6B7280))),
            Text(bab.judul,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════
// BACA BAB
// ════════════════════════════════════════
class BacaBabScreen extends StatefulWidget {
  final BukuMeta meta;
  final BabModel bab;
  const BacaBabScreen({super.key, required this.meta, required this.bab});

  @override
  State<BacaBabScreen> createState() => _BacaBabScreenState();
}

class _BacaBabScreenState extends State<BacaBabScreen> {
  List<String> _gambar  = [];
  bool         _loading = true;
  bool         _isTeks  = false;
  double       _zoom    = 1.0;

  static const double _zoomMin = 1.0;
  static const double _zoomMax = 4.0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    _isTeks = widget.bab.tipe == 'teks';
    if (!_isTeks) {
      final g = await BukuService.getGambarBab(widget.bab);
      if (mounted) setState(() { _gambar = g; _loading = false; });
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isTeks ? Colors.white : const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: widget.meta.warna,
        foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bab ${widget.bab.id}',
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
          Text(widget.bab.judul,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
        elevation: 0,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: widget.meta.warna))
          : _isTeks
              ? _viewTeks()
              : Column(children: [
                  _zoomBar(),
                  Expanded(child: _viewGambar()),
                ]),
    );
  }

  // ── Bar kontrol zoom (khusus mode gambar/statis) ──
  Widget _zoomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: Colors.white,
      child: Row(children: [
        Icon(Icons.zoom_out, size: 20, color: widget.meta.warna),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _zoom,
              min: _zoomMin,
              max: _zoomMax,
              divisions: 6, // langkah 0.5x
              activeColor: widget.meta.warna,
              inactiveColor: widget.meta.warna.withOpacity(0.2),
              label: '${_zoom.toStringAsFixed(1)}x',
              onChanged: (v) => setState(() => _zoom = v),
            ),
          ),
        ),
        Icon(Icons.zoom_in, size: 20, color: widget.meta.warna),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.meta.warna.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('${_zoom.toStringAsFixed(1)}x',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                  color: widget.meta.warna)),
        ),
      ]),
    );
  }

  // ── Mode teks (DOCX) ──
  Widget _viewTeks() {
    return FutureBuilder<String>(
      future: BukuService.getKontenBab(widget.bab),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator(
              color: widget.meta.warna));
        }
        final segments = _parseHTML(snap.data!, widget.meta.warna);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: segments.length,
          itemBuilder: (_, i) => segments[i],
        );
      },
    );
  }

  // ── Mode gambar (PDF) ──
  Widget _viewGambar() {
    if (_gambar.isEmpty) {
      return const Center(child: Text('Tidak ada halaman'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _gambar.length,
      itemBuilder: (_, i) => _GambarWidget(
          namaFile: _gambar[i], warna: widget.meta.warna, zoom: _zoom),
    );
  }

  List<Widget> _parseHTML(String html, Color warna) {
    final widgets  = <Widget>[];
    final bodyMatch = RegExp(r'<body[^>]*>(.*?)<\/body>', dotAll: true)
        .firstMatch(html);
    final body = bodyMatch?.group(1) ?? html;
    final imgRegex = RegExp(
        r'<img[^>]+src="[^"]*assets/([^"]+)"[^>]*>', dotAll: true);

    int lastEnd = 0;
    for (final m in imgRegex.allMatches(body)) {
      final teks = body.substring(lastEnd, m.start);
      if (teks.trim().isNotEmpty) {
        widgets.add(_TeksWidget(html: teks, warna: warna));
      }
      widgets.add(_GambarNativeWidget(namaFile: m.group(1)!));
      lastEnd = m.end;
    }

    if (lastEnd < body.length) {
      final sisa = body.substring(lastEnd);
      if (sisa.trim().isNotEmpty) {
        widgets.add(_TeksWidget(html: sisa, warna: warna));
      }
    }

    if (widgets.isEmpty) {
      widgets.add(_TeksWidget(html: body, warna: warna));
    }

    return widgets;
  }
}

// ── Widget teks HTML ──
class _TeksWidget extends StatelessWidget {
  final String html;
  final Color  warna;
  const _TeksWidget({required this.html, required this.warna});

  @override
  Widget build(BuildContext context) {
    final isH1 = html.contains('<h1') || html.contains('<H1');
    final isH2 = html.contains('<h2') || html.contains('<H2');

    final cleaned = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&amp;'),  '&')
        .replaceAll(RegExp(r'&lt;'),   '<')
        .replaceAll(RegExp(r'&gt;'),   '>')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();

    if (cleaned.isEmpty) return const SizedBox.shrink();

    if (isH1) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12, top: 8),
        padding: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: warna, width: 4))),
        child: Text(cleaned, style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900,
          color: warna, height: 1.3)),
      );
    } else if (isH2) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 6),
        child: Text(cleaned, style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w800, color: warna)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(cleaned, style: const TextStyle(
        fontSize: 15, height: 1.8, color: Color(0xFF1a1a1a)),
        textAlign: TextAlign.justify),
    );
  }
}

// ── Widget gambar dari native assets (mode teks) ──
class _GambarNativeWidget extends StatefulWidget {
  final String namaFile;
  const _GambarNativeWidget({required this.namaFile});
  @override
  State<_GambarNativeWidget> createState() => _GambarNativeWidgetState();
}

class _GambarNativeWidgetState extends State<_GambarNativeWidget> {
  Uint8List? _bytes;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final b = await BukuService.getGambarBytes(widget.namaFile);
      if (mounted) setState(() => _bytes = b);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return const SizedBox(height: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(_bytes!, fit: BoxFit.fitWidth,
            width: double.infinity),
      ),
    );
  }
}

// ── Widget gambar halaman (mode PDF) ──
class _GambarWidget extends StatefulWidget {
  final String namaFile;
  final Color  warna;
  final double zoom;
  const _GambarWidget({
    required this.namaFile,
    required this.warna,
    this.zoom = 1.0,
  });
  @override
  State<_GambarWidget> createState() => _GambarWidgetState();
}

class _GambarWidgetState extends State<_GambarWidget> {
  Uint8List? _bytes;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final b = await BukuService.getGambarBytes(widget.namaFile);
      if (mounted) setState(() => _bytes = b);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes == null) {
      return Container(
        height: 200, margin: const EdgeInsets.only(bottom: 8),
        color: Colors.grey.shade100,
        child: Center(child: CircularProgressIndicator(
            color: widget.warna, strokeWidth: 2)),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width - 16; // dikurangi padding ListView
    final double zoom = widget.zoom.clamp(1.0, 4.0).toDouble();
    final double imgWidth = screenWidth * zoom;
    final zoomed = zoom > 1.01;

    final gambar = Image.memory(_bytes!, width: imgWidth, fit: BoxFit.fitWidth);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
            blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: zoomed
            ? Stack(children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: gambar,
                ),
                // Petunjuk kecil bahwa halaman bisa digeser saat diperbesar
                Positioned(
                  right: 6, bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.swipe, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Geser', style: TextStyle(
                          fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ])
            : gambar,
      ),
    );
  }
}
