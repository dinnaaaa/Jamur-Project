import 'package:flutter/material.dart';
import '../models/detection_result.dart';

class DetectionResultCard extends StatelessWidget {
  final DetectionResult result;

  const DetectionResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isGreen = result.isSafe;
    final bgColor = isGreen ? Colors.green[50] : Colors.red[50];
    final borderColor = isGreen ? Colors.green : Colors.red;
    final iconColor = isGreen ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: iconColor),
              const SizedBox(width: 8),
              const Text(
                'Hasil Deteksi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow('Jenis Jamur:', result.jenisJamur),
          _buildResultRow('Status:', result.status),
          _buildResultRow('Kepercayaan:', '${result.kepercayaan}%'),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
