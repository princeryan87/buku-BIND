class SoalModel {
  final int         id;
  final String      pertanyaan;
  final List<String> pilihan;
  final int         jawaban;
  final int         semester;

  SoalModel({
    required this.id,
    required this.pertanyaan,
    required this.pilihan,
    required this.jawaban,
    required this.semester,
  });

  factory SoalModel.fromJson(Map<String, dynamic> j) => SoalModel(
    id:         j['id']         ?? 0,
    pertanyaan: j['pertanyaan'] ?? '',
    pilihan:    List<String>.from(j['pilihan'] ?? []),
    jawaban:    j['jawaban']    ?? 0,
    semester:   j['semester']   ?? 1,
  );
}
