import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MushroomClassifier {
  static Interpreter? _interpreter;
  static const int inputSize = 224;
  static const List<String> labels = ['edible', 'poisonous'];
  static const Map<String, String> statusMap = {
    'edible': 'Aman Dimakan',
    'poisonous': 'Beracun',
    'unknown': 'Tidak Dikenali',
  };

  /// Threshold minimum untuk confidence
  /// Jika confidence tertinggi di bawah threshold ini, gambar dianggap bukan jamur
  static const double confidenceThreshold = 0.70; // 70%

  /// Minimum gap antara dua class untuk dianggap valid
  /// Jika gap terlalu kecil, model tidak yakin
  static const double minimumGap = 0.20; // 20%

  /// Initialize the TFLite interpreter
  static Future<void> initialize() async {
    if (_interpreter != null) return;

    try {
      final modelData = await rootBundle
          .load('assets/models/Mobilenetv3_FINAL_HYBRID.tflite');
      final bytes = modelData.buffer.asUint8List();
      _interpreter = Interpreter.fromBuffer(bytes);
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error loading TFLite model: $e');
      rethrow;
    }
  }

  /// Resize image with padding to preserve aspect ratio (SAMA dengan training)
  static img.Image _resizeWithPad(img.Image image, int targetSize) {
    final int origWidth = image.width;
    final int origHeight = image.height;

    // Calculate scale to fit within target size while preserving aspect ratio
    final double scale = (origWidth > origHeight)
        ? targetSize / origWidth
        : targetSize / origHeight;

    final int newWidth = (origWidth * scale).round();
    final int newHeight = (origHeight * scale).round();

    // Resize image dengan bilinear interpolation (SAMA seperti tf.image.resize)
    final resized = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.linear, // Bilinear seperti TensorFlow
    );

    // Create padded image with black background
    final padded = img.Image(width: targetSize, height: targetSize);

    // Fill with black (padding)
    for (int y = 0; y < targetSize; y++) {
      for (int x = 0; x < targetSize; x++) {
        padded.setPixel(x, y, img.ColorRgb8(0, 0, 0));
      }
    }

    // Calculate offset to center the image
    final int offsetX = (targetSize - newWidth) ~/ 2;
    final int offsetY = (targetSize - newHeight) ~/ 2;

    // Copy resized image to center
    for (int y = 0; y < newHeight; y++) {
      for (int x = 0; x < newWidth; x++) {
        final pixel = resized.getPixel(x, y);
        padded.setPixel(offsetX + x, offsetY + y, pixel);
      }
    }

    return padded;
  }

  /// Preprocess image for MobileNetV3
  /// PENTING: Model ini ditraining dengan data 0-255 (preprocess_input MobileNetV3
  /// di Keras versi baru TIDAK melakukan normalisasi!)
  static Float32List _preprocessImage(img.Image image) {
    // Resize dengan padding (SAMA seperti training)
    final resized = _resizeWithPad(image, inputSize);

    // Create Float32List for input tensor [1, 224, 224, 3]
    final input = Float32List(inputSize * inputSize * 3);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);

        // Get RGB values - TANPA normalisasi, langsung 0-255
        // Karena model ditraining dengan data 0-255 (preprocess_input tidak normalisasi)
        input[pixelIndex++] = pixel.r.toDouble();
        input[pixelIndex++] = pixel.g.toDouble();
        input[pixelIndex++] = pixel.b.toDouble();
      }
    }

    return input;
  }

  /// Classify mushroom from file
  static Future<Map<String, dynamic>> classify(File imageFile) async {
    if (_interpreter == null) {
      try {
        await initialize();
      } catch (e) {
        return {'error': 'Model tidak dapat dimuat: $e'};
      }
    }

    if (_interpreter == null) {
      return {'error': 'Model belum terinisialisasi'};
    }

    try {
      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      var image = img.decodeImage(bytes);

      if (image == null) {
        return {'error': 'Gagal membaca gambar'};
      }

      // PENTING: Apply EXIF orientation untuk gambar dari kamera
      // Gambar dari kamera HP sering punya metadata rotation
      image = img.bakeOrientation(image);

      print('Image size: ${image.width}x${image.height}');

      // Preprocess
      final input = _preprocessImage(image);

      // Debug: print first few values
      print(
          'Input sample: [${input[0].toStringAsFixed(3)}, ${input[1].toStringAsFixed(3)}, ${input[2].toStringAsFixed(3)}]');

      // Reshape input to [1, 224, 224, 3]
      final inputTensor = input.reshape([1, inputSize, inputSize, 3]);

      // Output tensor shape: [1, 2]
      var output = List<List<double>>.generate(
        1,
        (_) => List<double>.filled(2, 0.0),
      );

      // Run inference
      _interpreter!.run(inputTensor, output);

      // Get results - output sudah softmax dari model
      final score0 = output[0][0];
      final score1 = output[0][1];

      print('=== MODEL OUTPUT (RAW) ===');
      print('Output[0] (index 0): ${(score0 * 100).toStringAsFixed(2)}%');
      print('Output[1] (index 1): ${(score1 * 100).toStringAsFixed(2)}%');
      print('==========================');

      // CATATAN: Cek urutan label dari training model
      // Jika folder training: edible/ dan poisonous/ (alphabetical)
      // Maka: index 0 = edible, index 1 = poisonous
      //
      // Jika hasil selalu "beracun", coba swap label order dibawah ini

      // Default assumption: index 0 = edible, index 1 = poisonous
      final edibleScore = score0;
      final poisonousScore = score1;

      // UNCOMMENT INI JIKA LABEL TERBALIK:
      // final edibleScore = score1;
      // final poisonousScore = score0;

      print('Edible (Aman): ${(edibleScore * 100).toStringAsFixed(2)}%');
      print(
          'Poisonous (Beracun): ${(poisonousScore * 100).toStringAsFixed(2)}%');

      // Hitung confidence maksimum dan gap antara kedua class
      final maxConfidence =
          edibleScore > poisonousScore ? edibleScore : poisonousScore;
      final gap = (edibleScore - poisonousScore).abs();

      print('Max Confidence: ${(maxConfidence * 100).toStringAsFixed(2)}%');
      print('Gap: ${(gap * 100).toStringAsFixed(2)}%');
      print('Threshold: ${(confidenceThreshold * 100).toStringAsFixed(2)}%');
      print('Min Gap Required: ${(minimumGap * 100).toStringAsFixed(2)}%');

      // Cek apakah gambar terdeteksi sebagai jamur
      // 1. Confidence harus di atas threshold
      // 2. Gap antara kedua class harus cukup besar
      if (maxConfidence < confidenceThreshold || gap < minimumGap) {
        print('=== REJECTED: Gambar tidak dikenali sebagai jamur ===');
        return {
          'jenis_jamur': 'unknown',
          'status': statusMap['unknown'],
          'confidence': maxConfidence,
          'edible_score': edibleScore,
          'poisonous_score': poisonousScore,
          'is_mushroom': false,
          'rejection_reason': maxConfidence < confidenceThreshold
              ? 'Confidence terlalu rendah (${(maxConfidence * 100).toStringAsFixed(1)}%)'
              : 'Model tidak yakin (gap: ${(gap * 100).toStringAsFixed(1)}%)',
        };
      }

      // Determine result based on higher score
      final isEdible = edibleScore > poisonousScore;
      final label = isEdible ? 'edible' : 'poisonous';
      final status = statusMap[label]!;
      final confidence = isEdible ? edibleScore : poisonousScore;

      return {
        'jenis_jamur': label,
        'status': status,
        'confidence': confidence,
        'edible_score': edibleScore,
        'poisonous_score': poisonousScore,
        'is_mushroom': true,
      };
    } catch (e) {
      print('Classification error: $e');
      return {'error': 'Terjadi kesalahan: $e'};
    }
  }

  /// Dispose interpreter
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
