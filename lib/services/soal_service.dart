import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/soal_model.dart';

class SoalService {
  static const _channel = MethodChannel('com.bukudigital/assets');
  static List<SoalModel>? _semuaSoal;

  // ── Load soal dari native assets ──
  static Future<List<SoalModel>> loadSoal() async {
    if (_semuaSoal != null) return _semuaSoal!;

    try {
      final jsonStr = await _channel.invokeMethod<String>('readString', {
        'path': 'buku/soal.json',
      });

      final data     = jsonDecode(jsonStr!);
      final soalList = (data['soal'] as List)
          .map((s) => SoalModel.fromJson(s))
          .toList();

      _semuaSoal = soalList;
      return _semuaSoal!;
    } catch (e) {
      // Fallback: kembalikan list kosong jika soal.json tidak ada
      print('soal.json tidak ditemukan: $e');
      _semuaSoal = [];
      return _semuaSoal!;
    }
  }

  // ── Ambil semua soal milik satu semester (urutan asli, tidak diacak) ──
  static Future<List<SoalModel>> getSoalSemester(int semester) async {
    final semua = await loadSoal();
    return semua.where((s) => s.semester == semester).toList();
  }

  // ── Cek apakah soal tersedia ──
  static Future<bool> adaSoal() async {
    final semua = await loadSoal();
    return semua.isNotEmpty;
  }

  // ── Jumlah soal per semester ──
  static Future<int> jumlahSoalSemester(int semester) async {
    final semua = await loadSoal();
    return semua.where((s) => s.semester == semester).length;
  }

  static void reset() => _semuaSoal = null;
}
