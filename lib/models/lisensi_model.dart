import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String masterKey   = 'BukuDigital-2025-RahasiaSaya';
const String kodeBukuIni = 'MTK-K6';

bool verifikasiKode(String deviceId, String kodeInput) {
  final payload = '${deviceId.trim().toUpperCase()}::${kodeBukuIni.trim().toUpperCase()}';
  final digest  = Hmac(sha256, utf8.encode(masterKey)).convert(utf8.encode(payload));
  final raw     = digest.toString().toUpperCase().substring(0, 16);
  final benar   = '${raw.substring(0,4)}-${raw.substring(4,8)}-${raw.substring(8,12)}-${raw.substring(12,16)}';
  return kodeInput.trim().toUpperCase().replaceAll('-','') == benar.replaceAll('-','');
}

enum StatusLisensi { freeview, aktif, expired }

class LisensiService {
  static const _keyInstall  = 'install_time';
  static const _keyAktif    = 'lisensi_aktif';
  static const _keyDeviceId = 'device_id';
  static const _freeviewHari = 3;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_keyInstall)) {
      await prefs.setInt(_keyInstall, DateTime.now().millisecondsSinceEpoch);
    }
    if (!prefs.containsKey(_keyDeviceId)) {
      await prefs.setString(_keyDeviceId, _generateDeviceId());
    }
  }

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId) ?? _generateDeviceId();
  }

  static Future<StatusLisensi> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyAktif) == true) return StatusLisensi.aktif;
    final installTime  = prefs.getInt(_keyInstall) ?? 0;
    final selisihHari  = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(installTime)).inDays;
    return selisihHari < _freeviewHari ? StatusLisensi.freeview : StatusLisensi.expired;
  }

  static Future<int> sisaHariFreeview() async {
    final prefs       = await SharedPreferences.getInstance();
    final installTime = prefs.getInt(_keyInstall) ?? 0;
    final selisih     = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(installTime)).inDays;
    return (_freeviewHari - selisih).clamp(0, _freeviewHari);
  }

  static Future<bool> aktivasi(String kodeInput) async {
    final deviceId = await getDeviceId();
    if (verifikasiKode(deviceId, kodeInput)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyAktif, true);
      return true;
    }
    return false;
  }

  static String _generateDeviceId() {
    final now  = DateTime.now().millisecondsSinceEpoch;
    final hash = Hmac(sha256, utf8.encode('device'))
        .convert(utf8.encode(now.toString()))
        .toString().toUpperCase().substring(0, 12);
    return '${hash.substring(0,4)}-${hash.substring(4,8)}-${hash.substring(8,12)}';
  }
}
