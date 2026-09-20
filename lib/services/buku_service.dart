import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import '../models/buku_model.dart';

class BukuService {
  static const _channel = MethodChannel('com.bukudigital/assets');
  static BukuMeta? _meta;
  static const _prefix = 'buku';

  static Future<String> _readString(String relativePath) async {
    return await _channel.invokeMethod('readString', {
      'path': '$_prefix/$relativePath',
    });
  }

  static Future<Uint8List> _readBytes(String relativePath) async {
    final bytes = await _channel.invokeMethod<Uint8List>('readBytes', {
      'path': '$_prefix/$relativePath',
    });
    return bytes!;
  }

  static Future<BukuMeta> init([
    void Function(int persen, String pesan)? onProgress,
  ]) async {
    if (_meta != null) return _meta!;
    onProgress?.call(30, 'Membaca konfigurasi buku...');
    final configStr = await _readString('config.json');
    final json      = jsonDecode(configStr);
    onProgress?.call(90, 'Memuat data buku...');
    _meta = BukuMeta.fromJson(json);
    onProgress?.call(100, 'Siap!');
    return _meta!;
  }

  static Future<bool> perluEkstrak() async => false;

  static Future<Uint8List> getGambarBytes(String namaFile) async {
    return await _readBytes('assets/$namaFile');
  }

  static Future<List<String>> getGambarBab(BabModel bab) async {
    try {
      final html  = await _readString('bab/${bab.file}');
      final regex = RegExp(r'src="\.\./assets/([^"]+)"');
      return regex.allMatches(html).map((m) => m.group(1)!).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String> getKontenBab(BabModel bab) async {
    try {
      return await _readString('bab/${bab.file}');
    } catch (e) {
      return '<p>Konten tidak tersedia</p>';
    }
  }

  static void reset() => _meta = null;
}
