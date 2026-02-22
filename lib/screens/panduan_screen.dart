import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class PanduanScreen extends StatelessWidget {
  const PanduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.info, Color(0xFF60A5FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            "Panduan Identifikasi",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            "Pelajari cara mengenali jamur dengan aman",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          _InfoCard(
            backgroundColor: AppColors.accentGreen,
            headerColor: AppColors.success,
            title: "Jamur Aman",
            icon: Icons.check_circle_rounded,
            items: const [
              "Warna cerah dan konsisten",
              "Tidak berlendir atau lengket",
              "Aroma tidak menyengat",
              "Tumbuh di tempat yang bersih",
              "Bentuk yang utuh dan tidak cacat",
            ],
          ),

          const SizedBox(height: 16),

          _InfoCard(
            backgroundColor: AppColors.accentRed,
            headerColor: AppColors.danger,
            title: "Jamur Beracun",
            icon: Icons.dangerous_rounded,
            items: const [
              "Warna mencolok atau tidak natural",
              "Permukaan berlendir",
              "Aroma busuk atau aneh",
              "Tumbuh di tempat kotor",
              "Bentuk yang tidak biasa",
            ],
          ),

          const SizedBox(height: 16),

          _InfoCard(
            backgroundColor: AppColors.accentYellow,
            headerColor: AppColors.warning,
            title: "Peringatan Penting",
            icon: Icons.warning_rounded,
            items: const [
              "Jangan pernah makan jamur liar tanpa kepastian",
              "Konsultasi dengan ahli mycology",
              "Aplikasi ini hanya bantuan, bukan keputusan final",
              "Gejala keracunan bisa muncul berjam-jam kemudian",
            ],
          ),

          const SizedBox(height: 16),

          _InfoCard(
            backgroundColor: AppColors.accentBlue,
            headerColor: AppColors.info,
            title: "Langkah Keamanan",
            icon: Icons.security_rounded,
            items: const [
              "Selalu cuci tangan setelah menyentuh jamur",
              "Jangan biarkan anak-anak bermain dengan jamur liar",
              "Simpan foto jamur untuk referensi dokter",
              "Hubungi rumah sakit jika merasa tidak enak badan",
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Color backgroundColor;
  final Color headerColor;
  final String title;
  final IconData icon;
  final List<String> items;

  const _InfoCard({
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
          // Header
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
          
          // Content
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
                          style: TextStyle(
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
