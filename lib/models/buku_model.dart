import 'package:flutter/material.dart';

class BukuMeta {
  final String namaBuku;
  final String kodeBuku;
  final String kelas;
  final String mapel;
  final String semester;
  final String warnaTema;
  final int    totalBab;
  final int    totalHalaman;
  final List<BabModel> bab;

  BukuMeta({
    required this.namaBuku,
    required this.kodeBuku,
    required this.kelas,
    required this.mapel,
    required this.semester,
    required this.warnaTema,
    required this.totalBab,
    required this.totalHalaman,
    required this.bab,
  });

  factory BukuMeta.fromJson(Map<String, dynamic> j) => BukuMeta(
    namaBuku:     j['namaBuku']     ?? '',
    kodeBuku:     j['kodeBuku']     ?? '',
    kelas:        j['kelas']        ?? '',
    mapel:        j['mapel']        ?? '',
    semester:     j['semester']     ?? '',
    warnaTema:    j['warnaTema']    ?? '#2D9B5A',
    totalBab:     j['totalBab']     ?? 0,
    totalHalaman: j['totalHalaman'] ?? 0,
    bab: (j['bab'] as List? ?? []).map((b) => BabModel.fromJson(b)).toList(),
  );

  Color get warna {
    try {
      final hex = warnaTema.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2D9B5A);
    }
  }
}

class BabModel {
  final int    id;
  final String judul;
  final String file;
  final int    semester;
  final String tipe;

  BabModel({
    required this.id,
    required this.judul,
    required this.file,
    required this.semester,
    this.tipe = 'gambar',
  });

  factory BabModel.fromJson(Map<String, dynamic> j) => BabModel(
    id:       j['id']       ?? 0,
    judul:    j['judul']    ?? '',
    file:     j['file']     ?? '',
    semester: j['semester'] ?? 1,
    tipe:     j['tipe']     ?? 'gambar',
  );
}
