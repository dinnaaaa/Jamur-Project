class DetectionResult {
  final String jenisJamur;
  final String status;
  final double kepercayaan;
  final String color;
  final bool isSafe;

  DetectionResult({
    required this.jenisJamur,
    required this.status,
    required this.kepercayaan,
    required this.color,
    required this.isSafe,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      jenisJamur: json['jenis_jamur'] ?? 'unknown',
      status: json['status'] ?? 'Tidak Diketahui',
      kepercayaan: (json['kepercayaan'] ?? 0).toDouble(),
      color: json['color'] ?? 'gray',
      isSafe: json['is_safe'] ?? false,
    );
  }
}
