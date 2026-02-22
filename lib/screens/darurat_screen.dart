import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_theme.dart';

class DaruratScreen extends StatelessWidget {
  const DaruratScreen({super.key});

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Emergency Header
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.danger, Color(0xFFFF6B6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.emergency_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Darurat Keracunan",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.danger,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            "Informasi penting saat mengalami keracunan jamur",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Emergency Call Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.danger.withValues(alpha: 0.1),
                  AppColors.accentRed,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Hubungi Segera",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dangerDark,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _EmergencyButton(
                        icon: Icons.local_hospital_rounded,
                        label: "Ambulans",
                        number: "118",
                        onTap: () => _makeCall("118"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EmergencyButton(
                        icon: Icons.emergency_rounded,
                        label: "Darurat",
                        number: "119",
                        onTap: () => _makeCall("119"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _EmergencyCard(
            backgroundColor: AppColors.accentRed,
            headerColor: AppColors.danger,
            title: "Gejala Keracunan",
            icon: Icons.sick_rounded,
            items: const [
              "Mual dan muntah",
              "Diare dan kram perut",
              "Pusing dan sakit kepala",
              "Demam dan kedinginan",
              "Kesulitan bernapas",
              "Halusinasi (pada kasus tertentu)",
            ],
          ),

          const SizedBox(height: 16),

          _EmergencyCard(
            backgroundColor: AppColors.accentYellow,
            headerColor: AppColors.warning,
            title: "Pertolongan Pertama",
            icon: Icons.healing_rounded,
            items: const [
              "Segera hubungi rumah sakit",
              "Jangan memuntahkan paksa",
              "Minum air putih secukupnya",
              "Simpan sisa jamur untuk analisis",
              "Catat waktu konsumsi jamur",
            ],
          ),

          const SizedBox(height: 16),

          _EmergencyCard(
            backgroundColor: AppColors.accentBlue,
            headerColor: AppColors.info,
            title: "Informasi untuk Dokter",
            icon: Icons.assignment_rounded,
            items: const [
              "Waktu konsumsi jamur",
              "Jumlah yang dikonsumsi",
              "Jenis jamur (jika diketahui)",
              "Gejala yang dialami",
              "Obat yang sudah diminum",
            ],
          ),

          const SizedBox(height: 16),

          // Emergency Numbers Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.lightShadow,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.phone_rounded, color: AppColors.success, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Nomor Darurat",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.successDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _PhoneRow(label: "Ambulans", number: "118 / 119", onTap: () => _makeCall("118")),
                      const Divider(height: 20),
                      _PhoneRow(label: "Polisi", number: "110", onTap: () => _makeCall("110")),
                      const Divider(height: 20),
                      _PhoneRow(label: "Pemadam", number: "113", onTap: () => _makeCall("113")),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String number;
  final VoidCallback onTap;

  const _EmergencyButton({
    required this.icon,
    required this.label,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.danger,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                number,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final Color backgroundColor;
  final Color headerColor;
  final String title;
  final IconData icon;
  final List<String> items;

  const _EmergencyCard({
    required this.backgroundColor,
    required this.headerColor,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.lightShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: headerColor, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < items.length - 1 ? 10 : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: headerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final String label;
  final String number;
  final VoidCallback onTap;

  const _PhoneRow({
    required this.label,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            Row(
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
