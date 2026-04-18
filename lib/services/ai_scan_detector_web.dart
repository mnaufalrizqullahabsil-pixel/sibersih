// Implementasi Flutter Web menggunakan ONNX Runtime Web via JS interop.
// File ini HANYA dikompilasi di Flutter Web.
//
// Setup web/index.html — tambahkan SEBELUM <script src="main.dart.js">:
//   <script src="https://cdn.jsdelivr.net/npm/onnxruntime-web@1.17.1/dist/ort.min.js"></script>
//   <script src="bottle_classifier.js"></script>
//
// Format model sama seperti versi mobile (YOLOv8n, 2 kelas).

// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:convert';

import 'ai_scan_service.dart';

// ── Public API ───────────────────────────────────────────────────────────────

Future<AiScanResult> detectBottleImpl(
  Uint8List bytes, {
  String? sourceName,
}) async {
  try {
    if (!globalContext.has('classifyBottle')) {
      // Script JS belum dimuat (jaringan lambat / error CDN)
      return AiScanResult.noBottleFound();
    }

    final jsPromise = globalContext.callMethod<JSPromise<JSString>>(
      'classifyBottle'.toJS,
      bytes.toJS,
    );

    final jsResult   = await jsPromise.toDart;
    final jsonString = jsResult.toDart;

    return _parseResult(jsonString);
  } catch (_) {
    return AiScanResult.noBottleFound();
  }
}

// ── Post-processing ──────────────────────────────────────────────────────────

/// Parse JSON dari JS:
/// ```json
/// { "plastic": 0.91, "glass": 0.05 }
/// ```
AiScanResult _parseResult(String jsonStr) {
  try {
    final map     = jsonDecode(jsonStr) as Map<String, dynamic>;
    if (map.containsKey('error')) return AiScanResult.noBottleFound();

    final plastic = (map['plastic'] as num?)?.toDouble() ?? 0.0;
    final glass   = (map['glass']   as num?)?.toDouble() ?? 0.0;

    const threshold = 0.5;

    if (plastic >= glass && plastic >= threshold) return AiScanResult.plasticBottle(plastic);
    if (glass > plastic  && glass   >= threshold) return AiScanResult.glassBottle(glass);

    return AiScanResult.noBottleFound();
  } catch (_) {
    return AiScanResult.noBottleFound();
  }
}

/// Preload: trigger JS model load di background.
/// Dipanggil [AiScanService.preload] saat halaman dibuka.
Future<void> preloadImpl() async {
  try {
    if (!globalContext.has('classifyBottle')) return;
    // Panggil JS preload jika tersedia — bottle_classifier.js sudah
    // mulai load model secara otomatis saat script dijalankan.
    // Tidak perlu aksi tambahan di sini.
  } catch (_) {}
}
