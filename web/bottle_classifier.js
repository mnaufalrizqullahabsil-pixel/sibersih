/**
 * bottle_classifier.js  —  YOLOv8n botol.onnx (2 kelas: plastik / kaca)
 * Taruh di: web/bottle_classifier.js
 *
 * Tambahkan di web/index.html SEBELUM <script src="main.dart.js">:
 *   <script src="https://cdn.jsdelivr.net/npm/onnxruntime-web@1.17.1/dist/ort.min.js"></script>
 *   <script src="bottle_classifier.js"></script>
 *
 * ────────────────────────────────────────────────────────────────────────────
 * Spesifikasi model (dari inspeksi langsung):
 *   Input  : "images"  — [1, 3, 640, 640], float32, pixel/255
 *   Output : "output0" — [1, 300, 6],      float32
 *            NMS sudah di-apply di dalam model.
 *            Per deteksi: [x1, y1, x2, y2, confidence, class_id]
 *            class_id: 0 = plastik,  1 = kaca
 * ────────────────────────────────────────────────────────────────────────────
 */

(function () {
  "use strict";

  const INPUT_NAME  = "images";
  const OUTPUT_NAME = "output0";
  const INPUT_SIZE  = 640;
  const MAX_DETS    = 300;   // baris output setelah NMS
  const IDX_CONF    = 4;     // index confidence dalam [x1,y1,x2,y2,conf,cls]
  const IDX_CLASS   = 5;     // index class_id
  const CLS_PLASTIC = 0;
  const CLS_GLASS   = 1;
  const CONF_THRESH = 0.25;

  // ── Session singleton (load di background saat script dijalankan) ──────────
  let _sessionPromise = null;

  function _getSession() {
    if (_sessionPromise) return _sessionPromise;
    _sessionPromise = ort.InferenceSession.create(
      "assets/models/botol.onnx",
      { executionProviders: ["wasm"], graphOptimizationLevel: "all" }
    ).catch((e) => { _sessionPromise = null; throw e; });
    return _sessionPromise;
  }

  // Mulai load model segera
  _getSession().catch(() => {});

  // ── Pre-processing ─────────────────────────────────────────────────────────

  async function _preprocessImage(uint8Array) {
    const blob   = new Blob([uint8Array]);
    const bitmap = await createImageBitmap(blob);

    const canvas = new OffscreenCanvas(INPUT_SIZE, INPUT_SIZE);
    const ctx    = canvas.getContext("2d");
    ctx.drawImage(bitmap, 0, 0, INPUT_SIZE, INPUT_SIZE);
    bitmap.close();

    const { data: px } = ctx.getImageData(0, 0, INPUT_SIZE, INPUT_SIZE);
    const hw     = INPUT_SIZE * INPUT_SIZE;
    const tensor = new Float32Array(3 * hw);

    for (let i = 0; i < hw; i++) {
      tensor[0 * hw + i] = px[i * 4]     / 255.0;  // R
      tensor[1 * hw + i] = px[i * 4 + 1] / 255.0;  // G
      tensor[2 * hw + i] = px[i * 4 + 2] / 255.0;  // B
    }
    return tensor;
  }

  // ── Post-processing ────────────────────────────────────────────────────────

  /**
   * Output [1, 300, 6] → data flat, row-major.
   * det[i] = data[i*6 .. i*6+5] = [x1, y1, x2, y2, conf, class_id]
   */
  function _parseOutput(data) {
    let bestPlastic = 0.0;
    let bestGlass   = 0.0;

    for (let i = 0; i < MAX_DETS; i++) {
      const base = i * 6;
      const conf = data[base + IDX_CONF];
      if (conf < CONF_THRESH) continue;

      const cls = Math.round(data[base + IDX_CLASS]);
      if (cls === CLS_PLASTIC && conf > bestPlastic) bestPlastic = conf;
      if (cls === CLS_GLASS   && conf > bestGlass)   bestGlass   = conf;
    }

    return { bestPlastic, bestGlass };
  }

  // ── Public ─────────────────────────────────────────────────────────────────

  window.classifyBottle = async function (uint8Array) {
    try {
      const session   = await _getSession();
      const floatData = await _preprocessImage(uint8Array);

      const inputTensor = new ort.Tensor("float32", floatData, [
        1, 3, INPUT_SIZE, INPUT_SIZE,
      ]);

      const results      = await session.run({ [INPUT_NAME]: inputTensor });
      const outputTensor = results[OUTPUT_NAME] ?? results[Object.keys(results)[0]];
      if (!outputTensor) return JSON.stringify({ error: "no output tensor" });

      const { bestPlastic, bestGlass } = _parseOutput(outputTensor.data);

      return JSON.stringify({ plastic: bestPlastic, glass: bestGlass });

    } catch (err) {
      return JSON.stringify({ error: String(err) });
    }
  };

})();
