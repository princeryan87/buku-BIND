import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/lisensi_model.dart';
import 'home_screen.dart';

class AktivasiScreen extends StatefulWidget {
  const AktivasiScreen({super.key});
  @override
  State<AktivasiScreen> createState() => _AktivasiScreenState();
}

class _AktivasiScreenState extends State<AktivasiScreen> {
  final _kodeCtrl = TextEditingController();
  String _deviceId = '';
  bool   _loading  = false;
  bool   _error    = false;

  @override
  void initState() { super.initState(); _loadDeviceId(); }

  @override
  void dispose() { _kodeCtrl.dispose(); super.dispose(); }

  Future<void> _loadDeviceId() async {
    final id = await LisensiService.getDeviceId();
    setState(() => _deviceId = id);
  }

  Future<void> _aktivasi() async {
    final kode = _kodeCtrl.text.trim();
    if (kode.isEmpty) return;
    setState(() { _loading = true; _error = false; });
    HapticFeedback.mediumImpact();
    final ok = await LisensiService.aktivasi(kode);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      HapticFeedback.vibrate();
      setState(() { _loading = false; _error = true; });
    }
  }

  void _copyDeviceId() {
    Clipboard.setData(ClipboardData(text: _deviceId));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Device ID disalin!'),
      backgroundColor: const Color(0xFF2D9B5A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                      child: Text('🔒', style: TextStyle(fontSize: 40))),
                ),
                const SizedBox(height: 16),
                const Text('Masa Percobaan Habis',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                        color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Text('Masukkan kode lisensi untuk membuka akses penuh',
                    style: TextStyle(fontSize: 14,
                        color: Colors.white.withOpacity(0.75)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),

                // Kartu
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24, offset: const Offset(0, 8),
                    )],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // Device ID
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('📱 Device ID Perangkat Ini',
                            style: TextStyle(fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6B7280))),
                        const SizedBox(height: 6),
                        Row(children: [
                          Expanded(child: Text(_deviceId,
                              style: const TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1A6B3C),
                                  letterSpacing: 2,
                                  fontFamily: 'monospace'))),
                          GestureDetector(
                            onTap: _copyDeviceId,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D9B5A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.copy,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        const Text('Kirim ke pengembang via WhatsApp',
                            style: TextStyle(fontSize: 11,
                                color: Color(0xFF9CA3AF))),
                      ]),
                    ),
                    const SizedBox(height: 18),

                    // Input kode
                    const Text('Kode Lisensi',
                        style: TextStyle(fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _kodeCtrl,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(fontFamily: 'monospace',
                          fontSize: 18, fontWeight: FontWeight.w700,
                          letterSpacing: 2, color: Color(0xFF1E2A1E)),
                      decoration: InputDecoration(
                        hintText: 'XXXX-XXXX-XXXX-XXXX',
                        hintStyle: const TextStyle(
                            color: Color(0xFFD1D5DB), letterSpacing: 1),
                        filled: true, fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB), width: 1.5)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: _error
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFE5E7EB),
                                width: 1.5)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Color(0xFF2D9B5A), width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      onChanged: (v) {
                        final clean = v.toUpperCase()
                            .replaceAll(RegExp(r'[^A-Z0-9]'), '');
                        String fmt = clean;
                        if (clean.length > 4)
                          fmt = '${clean.substring(0,4)}-${clean.substring(4)}';
                        if (clean.length > 8)
                          fmt = '${clean.substring(0,4)}-${clean.substring(4,8)}-${clean.substring(8)}';
                        if (clean.length > 12)
                          fmt = '${clean.substring(0,4)}-${clean.substring(4,8)}-${clean.substring(8,12)}-${clean.substring(12)}';
                        final r = fmt.substring(0, fmt.length > 19 ? 19 : fmt.length);
                        if (r != v) {
                          _kodeCtrl.value = TextEditingValue(
                              text: r,
                              selection: TextSelection.collapsed(offset: r.length));
                        }
                        if (_error) setState(() => _error = false);
                      },
                    ),

                    if (_error) ...[
                      const SizedBox(height: 6),
                      const Text('❌ Kode tidak valid untuk perangkat ini',
                          style: TextStyle(fontSize: 12,
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _aktivasi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D9B5A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text('✅ Aktifkan Sekarang',
                                style: TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                          'Hubungi pengembang via WhatsApp\nuntuk mendapatkan kode lisensi\n@musliminjuni87 (WA)',
                          style: TextStyle(fontSize: 12,
                              color: Color(0xFF9CA3AF)),
                          textAlign: TextAlign.center),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
