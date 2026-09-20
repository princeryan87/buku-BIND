# Template Buku Digital APK

## Cara Buat APK Buku Baru

### Langkah 1 - Siapkan ZIP buku
Konversi PDF/DOCX menggunakan software PDF Converter.
Hasilnya adalah ZIP berisi: assets/, bab/, index.html, config.json

### Langkah 2 - Upload ke repo
1. Buat repo baru di GitHub (Private)
2. Upload SEMUA file dari folder ini ke repo
3. Upload file ZIP buku ke root repo sebagai `buku.zip`
4. Upload file soal (dibuat via Claude dari PDF buku) ke root repo sebagai `soal.json`
   - Format: `{"kodeBuku": "...", "namaBuku": "...", "soal": [{"id":1,"pertanyaan":"...","pilihan":["...","...","...","..."],"jawaban":0,"semester":1}, ...]}`
   - 100 soal untuk `semester: 1`, 100 soal untuk `semester: 2` (dipakai sebagai simulasi ujian 2 sesi)
   - Jika `soal.json` tidak diupload, aplikasi tetap build tapi menu Simulasi Ujian akan kosong

### Langkah 3 - Set Master Key
Edit `lib/models/lisensi_model.dart`:
```dart
const String masterKey = 'GANTI_DENGAN_MASTER_KEY_ANDA';
```
Harus sama persis dengan Key Generator!

### Langkah 4 - Commit & Build
Setelah commit → GitHub Actions otomatis:
- Ekstrak `buku.zip` ke assets/buku/
- Salin `soal.json` ke assets/buku/ (dipakai fitur Simulasi Ujian)
- Baca nama buku dari config.json
- Generate ikon launcher sesuai mapel (PAI, BI, IPAS, dll)
- Set nama aplikasi sesuai buku
- Build APK
- Upload ke Releases

## Fitur Simulasi Ujian
- 2 sesi: Semester 1 dan Semester 2, masing-masing 100 soal pilihan ganda
- Urutan soal & posisi pilihan jawaban diacak ulang setiap kali sesi baru dimulai
- Tidak bisa kembali ke soal sebelumnya (hanya maju)
- Keluar di tengah sesi → progres tersimpan otomatis, lanjut dari soal terakhir saat masuk lagi
- Skor akhir 0-100, dengan warna: 70-100 hijau, 40-69 kuning, 0-39 merah

### Langkah 5 - Download APK
Tab Releases → download *-arm64.apk

---

## Struktur Repo

```
buku.zip       ← Upload ZIP hasil converter di sini (root repo)
soal.json      ← Upload file soal simulasi ujian di sini (root repo)
android/
lib/
pubspec.yaml
.github/workflows/build.yml
```

## Singkatan Ikon per Mapel

| Mapel | Singkatan | Warna |
|---|---|---|
| Agama Islam | PAI | Ungu |
| Bahasa Indonesia | BI | Biru |
| IPAS | IPAS | Hijau |
| Matematika | MTK | Merah |
| Pendidikan Pancasila | PKn | Kuning |
| PJOK | PJOK | Cyan |
| Seni Budaya/Musik/Rupa/Tari | SBd/SM/SR/ST | Pink |
