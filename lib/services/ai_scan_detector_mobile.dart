// Implementasi Android / iOS — model YOLOv8n custom (botol.onnx).
// File ini HANYA dikompilasi di platform non-web.
//
// pubspec.yaml:
//   dependencies:
//     onnxruntime: ^1.1.0
//     image: ^4.1.3
//   flutter:
//     assets:
//       - assets/models/botol.onnx
//
// ─────────────────────────────────────────────────────────────────────────────
// Spesifikasi model (dari inspeksi langsung):
//   Input  : "images"  — [1, 3, 640, 640], float32, nilai pixel / 255
//   Output : "output0" — [1, 300, 6],      float32
//            NMS sudah di-apply di dalam model.
//            Per deteksi: [x1, y1, x2, y2, confidence, class_id]
//            class_id: 0 = plastik, 1 = kaca
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

import 'ai_scan_service.dart';

// ── Konstanta ────────────────────────────────────────────────────────────────
const _inputName   = 'images';
const _outputName  = 'output0';
const _inputSize   = 640;
const _maxDets     = 300;   // jumlah baris output setelah NMS
const _idxConf     = 4;     // index confidence dalam tiap deteksi [x1,y1,x2,y2,conf,cls]
const _idxClass    = 5;     // index class_id
const _clsPlastic  = 0;     // 0 = plastik
const _clsGlass    = 1;     // 1 = kaca
const _confThresh  = 0.5;  // threshold confidence minimum

// ── Singleton session ────────────────────────────────────────────────────────
OrtSession? _session;

Future<void> _initModel() async {
  if (_session != null) return;
  OrtEnv.instance.init();
  final raw   = await rootBundle.load('assets/models/botol.onnx');
  final bytes = raw.buffer.asUint8List();
  _session = OrtSession.fromBuffer(
    bytes,
    OrtSessionOptions()
      ..setInterOpNumThreads(2)
      ..setIntraOpNumThreads(2),
  );
}

// ── Public API ───────────────────────────────────────────────────────────────

Future<AiScanResult> detectBottleImpl(
  Uint8List bytes, {
  String? sourceName,
}) async {
  try {
    await _initModel();

    final inputData = _preprocessImage(bytes);
    if (inputData == null) return AiScanResult.noBottleFound();

    final inputTensor = OrtValueTensor.createTensorWithDataList(
      inputData,
      [1, 3, _inputSize, _inputSize],
    );
    final runOptions = OrtRunOptions();
    final outputs    = _session!.run(runOptions, {_inputName: inputTensor});
    inputTensor.release();
    runOptions.release();

    return _parseOutput(outputs);
  } catch (_) {
    return AiScanResult.noBottleFound();
  }
}

// ── Pre-processing ───────────────────────────────────────────────────────────

/// Resize ke 640×640 → CHW layout → normalize /255
Float32List? _preprocessImage(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  final resized = img.copyResize(
    decoded,
    width: _inputSize,
    height: _inputSize,
    interpolation: img.Interpolation.linear,
  );

  final hw     = _inputSize * _inputSize;
  final tensor = Float32List(3 * hw);

  for (var y = 0; y < _inputSize; y++) {
    for (var x = 0; x < _inputSize; x++) {
      final pixel = resized.getPixel(x, y);
      final i     = y * _inputSize + x;
      tensor[0 * hw + i] = pixel.r.toDouble() / 255.0;
      tensor[1 * hw + i] = pixel.g.toDouble() / 255.0;
      tensor[2 * hw + i] = pixel.b.toDouble() / 255.0;
    }
  }
  return tensor;
}

// ── Post-processing ──────────────────────────────────────────────────────────

/// Parse output [1, 300, 6].
/// NMS sudah dilakukan di dalam model — tinggal cari deteksi dengan
/// confidence tertinggi di antara semua baris yang valid.
AiScanResult _parseOutput(List<OrtValue?> outputs) {
  if (outputs.isEmpty || outputs.first == null) return AiScanResult.noBottleFound();

  // value: List<List<List<double>>> shape [1][300][6]
  final raw  = (outputs.first as OrtValueTensor).value;
  final dets = ((raw as List).first as List); // [300][6]

  var bestPlasticConf = 0.0;
  var bestGlassConf   = 0.0;

  for (var i = 0; i < _maxDets; i++) {
    final det  = dets[i] as List;
    final conf = (det[_idxConf] as num).toDouble();
    if (conf < _confThresh) continue;

    final cls = (det[_idxClass] as num).round();
    if (cls == _clsPlastic && conf > bestPlasticConf) bestPlasticConf = conf;
    if (cls == _clsGlass   && conf > bestGlassConf)   bestGlassConf   = conf;
  }

  if (bestPlasticConf >= bestGlassConf && bestPlasticConf >= _confThresh) {
    return AiScanResult.plasticBottle(bestPlasticConf);
  }
  if (bestGlassConf > bestPlasticConf && bestGlassConf >= _confThresh) {
    return AiScanResult.glassBottle(bestGlassConf);
  }
  return AiScanResult.noBottleFound();
}

/// Preload: inisialisasi ONNX session di background.
/// Dipanggil [AiScanService.preload] saat halaman dibuka.
Future<void> preloadImpl() async {
  try {
    await _initModel();
  } catch (_) {
    // Gagal preload tidak fatal — akan dicoba lagi saat scan pertama
  }
}
