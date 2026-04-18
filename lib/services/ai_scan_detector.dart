import 'dart:typed_data';

import 'ai_scan_service.dart';

// Mobile (onnxruntime) secara default.
// Flutter Web otomatis pakai ai_scan_detector_web.dart.
import 'ai_scan_detector_mobile.dart'
    if (dart.library.html) 'ai_scan_detector_web.dart';

/// Muat model ONNX di background tanpa perlu gambar.
/// Dipanggil [AiScanService.preload] dari initState halaman.
Future<void> preloadDetector() => preloadImpl();

/// Deteksi botol dari bytes gambar.
Future<AiScanResult> detectBottle(
  Uint8List bytes, {
  String? sourceName,
}) =>
    detectBottleImpl(bytes, sourceName: sourceName);
