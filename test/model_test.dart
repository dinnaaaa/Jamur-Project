import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

// Konfigurasi
const int inputSize = 224;
const List<String> labels = ['edible', 'poisonous'];
const String testDir = '../jamur/test';
const String modelPath = 'assets/models/mobilenetv3_jamur.tflite';

// Resize image dengan padding (SAMA seperti training)
img.Image resizeWithPad(img.Image image, int targetSize) {
  final int origWidth = image.width;
  final int origHeight = image.height;

  final double scale = (origWidth > origHeight)
      ? targetSize / origWidth
      : targetSize / origHeight;

  final int newWidth = (origWidth * scale).round();
  final int newHeight = (origHeight * scale).round();

  final resized = img.copyResize(
    image,
    width: newWidth,
    height: newHeight,
    interpolation: img.Interpolation.linear,
  );

  final padded = img.Image(width: targetSize, height: targetSize);

  // Fill with black
  for (int y = 0; y < targetSize; y++) {
    for (int x = 0; x < targetSize; x++) {
      padded.setPixel(x, y, img.ColorRgb8(0, 0, 0));
    }
  }

  final int offsetX = (targetSize - newWidth) ~/ 2;
  final int offsetY = (targetSize - newHeight) ~/ 2;

  for (int y = 0; y < newHeight; y++) {
    for (int x = 0; x < newWidth; x++) {
      final pixel = resized.getPixel(x, y);
      padded.setPixel(offsetX + x, offsetY + y, pixel);
    }
  }

  return padded;
}

// Preprocess image
Float32List preprocessImage(img.Image image) {
  final resized = resizeWithPad(image, inputSize);
  final input = Float32List(inputSize * inputSize * 3);
  int pixelIndex = 0;

  for (int y = 0; y < inputSize; y++) {
    for (int x = 0; x < inputSize; x++) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();

      // MobileNetV3 preprocess: scale to [-1, 1]
      input[pixelIndex++] = (r / 127.5) - 1.0;
      input[pixelIndex++] = (g / 127.5) - 1.0;
      input[pixelIndex++] = (b / 127.5) - 1.0;
    }
  }

  return input;
}

void main() async {
  print('=' * 60);
  print('       TEST MODEL TFLITE DENGAN DATA JAMUR');
  print('=' * 60);

  // Load model
  print('\n[1] Loading model...');
  final modelFile = File(modelPath);

  Interpreter interpreter;

  if (await modelFile.exists()) {
    final bytes = await modelFile.readAsBytes();
    interpreter = Interpreter.fromBuffer(bytes);
    print('    Model loaded: $modelPath');
  } else {
    // Try alternative path
    final altPath = 'D:/DEVILDA/Jamur/mobilenetv3_jamur.tflite';
    final altFile = File(altPath);
    if (await altFile.exists()) {
      final bytes = await altFile.readAsBytes();
      interpreter = Interpreter.fromBuffer(bytes);
      print('    Model loaded: $altPath');
    } else {
      print('    ERROR: Model not found!');
      print('    Tried: $modelPath');
      print('    Tried: $altPath');
      return;
    }
  }

  // Get input/output details
  final inputShape = interpreter.getInputTensor(0).shape;
  final outputShape = interpreter.getOutputTensor(0).shape;
  print('    Input shape: $inputShape');
  print('    Output shape: $outputShape');

  // Load test images
  print('\n[2] Loading test images...');

  final testDirAbs = 'D:/DEVILDA/Jamur/jamur/test';
  final testDirectory = Directory(testDirAbs);

  if (!await testDirectory.exists()) {
    print('    ERROR: Test directory not found: $testDirAbs');
    return;
  }

  List<Map<String, dynamic>> testData = [];

  for (int classIdx = 0; classIdx < labels.length; classIdx++) {
    final className = labels[classIdx];
    final classDir = Directory('$testDirAbs/$className');

    if (await classDir.exists()) {
      final files = classDir.listSync().whereType<File>().where((f) {
        final ext = f.path.toLowerCase();
        return ext.endsWith('.jpg') ||
            ext.endsWith('.jpeg') ||
            ext.endsWith('.png');
      }).toList();

      for (final file in files) {
        testData.add({
          'path': file.path,
          'label': classIdx,
          'className': className,
        });
      }
      print('    $className: ${files.length} images');
    }
  }

  print('    Total: ${testData.length} images');

  // Run inference
  print('\n[3] Running inference...');

  int correct = 0;
  int total = 0;
  List<int> yTrue = [];
  List<int> yPred = [];
  List<Map<String, dynamic>> wrongPredictions = [];

  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < testData.length; i++) {
    final data = testData[i];
    final imagePath = data['path'] as String;
    final trueLabel = data['label'] as int;
    final className = data['className'] as String;

    try {
      // Load and decode image
      final bytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        print('    Warning: Could not decode ${imagePath}');
        continue;
      }

      // Preprocess
      final input = preprocessImage(image);
      final inputTensor = input.reshape([1, inputSize, inputSize, 3]);

      // Output
      var output = List<List<double>>.generate(
        1,
        (_) => List<double>.filled(2, 0.0),
      );

      // Run inference
      interpreter.run(inputTensor, output);

      // Get prediction
      final predLabel = output[0][0] > output[0][1] ? 0 : 1;
      final confidence = output[0][predLabel];

      yTrue.add(trueLabel);
      yPred.add(predLabel);
      total++;

      if (predLabel == trueLabel) {
        correct++;
      } else {
        wrongPredictions.add({
          'path': imagePath,
          'true': className,
          'pred': labels[predLabel],
          'confidence': confidence,
        });
      }

      // Progress
      if ((i + 1) % 20 == 0 || i == testData.length - 1) {
        print('    Processed ${i + 1}/${testData.length} images...');
      }
    } catch (e) {
      print('    Error processing $imagePath: $e');
    }
  }

  stopwatch.stop();

  // Results
  print('\n' + '=' * 60);
  print('                      RESULTS');
  print('=' * 60);

  final accuracy = total > 0 ? (correct / total * 100) : 0.0;
  print('\nAccuracy: ${accuracy.toStringAsFixed(2)}% ($correct/$total)');
  print('Total time: ${stopwatch.elapsedMilliseconds}ms');
  print(
      'Avg per image: ${(stopwatch.elapsedMilliseconds / total).toStringAsFixed(2)}ms');

  // Confusion Matrix
  print('\n--- Confusion Matrix ---');
  List<List<int>> confMatrix = [
    [0, 0],
    [0, 0],
  ];

  for (int i = 0; i < yTrue.length; i++) {
    confMatrix[yTrue[i]][yPred[i]]++;
  }

  print('                 Predicted');
  print('                 ${labels[0].padRight(10)} ${labels[1]}');
  print(
      'Actual ${labels[0].padRight(10)} ${confMatrix[0][0].toString().padLeft(5)}      ${confMatrix[0][1]}');
  print(
      '       ${labels[1].padRight(10)} ${confMatrix[1][0].toString().padLeft(5)}      ${confMatrix[1][1]}');

  // Per-class metrics
  print('\n--- Per-Class Metrics ---');
  for (int c = 0; c < labels.length; c++) {
    final tp = confMatrix[c][c];
    final fn = confMatrix[c].reduce((a, b) => a + b) - tp;
    final fp = confMatrix.map((row) => row[c]).reduce((a, b) => a + b) - tp;

    final precision = tp + fp > 0 ? tp / (tp + fp) : 0.0;
    final recall = tp + fn > 0 ? tp / (tp + fn) : 0.0;
    final f1 = precision + recall > 0
        ? 2 * precision * recall / (precision + recall)
        : 0.0;

    print('${labels[c]}:');
    print('  Precision: ${(precision * 100).toStringAsFixed(2)}%');
    print('  Recall:    ${(recall * 100).toStringAsFixed(2)}%');
    print('  F1-Score:  ${(f1 * 100).toStringAsFixed(2)}%');
  }

  // Wrong predictions
  if (wrongPredictions.isNotEmpty) {
    print('\n--- Wrong Predictions (first 10) ---');
    for (int i = 0; i < wrongPredictions.length && i < 10; i++) {
      final wp = wrongPredictions[i];
      final fileName = wp['path'].toString().split(Platform.pathSeparator).last;
      print('${i + 1}. $fileName');
      print(
          '   True: ${wp['true']}, Pred: ${wp['pred']} (${(wp['confidence'] * 100).toStringAsFixed(1)}%)');
    }

    if (wrongPredictions.length > 10) {
      print('   ... and ${wrongPredictions.length - 10} more');
    }
  }

  print('\n' + '=' * 60);
  print('                    TEST COMPLETE');
  print('=' * 60);

  interpreter.close();
}
