import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../barang/presentation/providers/barang_provider.dart';
import '../../../../core/services/notification_service.dart';

class NotifikasiScreen extends ConsumerStatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  ConsumerState<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends ConsumerState<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    // Kirim notifikasi ke HP saat layar ini dibuka
    _sendPhoneNotifications();
  }

  Future<void> _sendPhoneNotifications() async {
    final dashboard = ref.read(dashboardProvider);
    if (dashboard.perluPerhatian.isEmpty) return;

    final alerts = dashboard.perluPerhatian.map((item) {
      return <String, String>{
        'title': item.title,
        'body': item.subtitle,
        'type': item.type,
      };
    }).toList();

    await NotificationService().sendAlertNotifications(alerts: alerts);
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'stok_kritis':
        return Icons.error_outline;
      case 'stok_rendah':
        return Icons.warning_amber_rounded;
      case 'kadaluarsa_hampir':
        return Icons.schedule;
      case 'kadaluarsa_kritis':
        return Icons.dangerous_outlined;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(AppColors c, String type) {
    switch (type) {
      case 'stok_kritis':
      case 'kadaluarsa_kritis':
        return c.statusCritical;
      case 'stok_rendah':
      case 'kadaluarsa_hampir':
        return c.statusWarning;
      default:
        return c.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dashboard = ref.watch(dashboardProvider);
    final perhatian = dashboard.perluPerhatian;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: c.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: c.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: c.outlineVariant, height: 1.0),
        ),
      ),
      body: perhatian.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: c.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none, size: 40, color: c.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: c.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semua stok aman dan tidak ada\nbarang yang mendekati kedaluwarsa.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: c.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: perhatian.length,
              itemBuilder: (context, index) {
                final item = perhatian[index];
                final iconColor = _getColor(c, item.type);
                final icon = _getIcon(item.type);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.onSurface,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
