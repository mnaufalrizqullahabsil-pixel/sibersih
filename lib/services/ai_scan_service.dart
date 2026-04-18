import 'dart:typed_data';

import 'ai_scan_detector.dart';

enum BottleType {
  plasticBottle,
  glassBottle,
  unknown,
}

class AiScanResult {
  final bool isAccepted;
  final BottleType type;
  final String label;
  final String message;
  final String emoji;
  final int confidencePercent;

  AiScanResult({
    required this.isAccepted,
    required this.type,
    required this.label,
    required this.message,
    required this.emoji,
    required this.confidencePercent,
  });

  factory AiScanResult.noBottleFound() {
    return AiScanResult(
      isAccepted: false,
      type: BottleType.unknown,
      label: 'Botol tidak ditemukan',
      message: 'Pastikan foto menunjukkan botol plastik dengan jelas.',
      emoji: '❌',
      confidencePercent: 0,
    );
  }

  factory AiScanResult.plasticBottle(double confidence) {
    return AiScanResult(
      isAccepted: true,
      type: BottleType.plasticBottle,
      label: 'Botol plastik terdeteksi',
      message: 'Foto mengandung botol plastik dan siap dilaporkan.',
      emoji: '✅',
      confidencePercent: (confidence * 100).clamp(0, 100).round(),
    );
  }

  factory AiScanResult.glassBottle(double confidence) {
    return AiScanResult(
      isAccepted: false,
      type: BottleType.glassBottle,
      label: 'Botol kaca terdeteksi',
      message: 'Hanya botol kaca yang terdeteksi. Gunakan botol plastik.',
      emoji: '🧴',
      confidencePercent: (confidence * 100).clamp(0, 100).round(),
    );
  }
}

class AiScanService {
  AiScanService._();

  /// Panggil di initState halaman untuk memuat model ONNX di background.
  /// Saat [analyzeImage] pertama dipanggil, model sudah siap → tidak ada delay.
  static Future<void> preload() => preloadDetector();

  /// Analisis gambar dan kembalikan hasil deteksi botol.
  static Future<AiScanResult> analyzeImage(
    Uint8List bytes, {
    String? sourceName,
  }) {
    return detectBottle(bytes, sourceName: sourceName);
  }
}
