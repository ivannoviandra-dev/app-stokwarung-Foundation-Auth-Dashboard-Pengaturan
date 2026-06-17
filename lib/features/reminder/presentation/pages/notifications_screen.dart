import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _notificationsSent = false;

  @override
  void initState() {
    super.initState();
    _sendPhoneNotifications();
  }

  Future<void> _sendPhoneNotifications() async {
    if (_notificationsSent) return;
    _notificationsSent = true;

    // Tunggu sebentar agar provider sudah siap
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dashboardData = ref.watch(dashboardProvider);
    final perhatianList = dashboardData.perluPerhatian;

    final stokList = perhatianList.where((item) => item.type.startsWith('stok_')).toList();
    final kedaluwarsaList = perhatianList.where((item) => item.type.startsWith('kadaluarsa_')).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Row(
            children: [
              Icon(Icons.notifications_active, color: c.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Notifikasi',
                style: TextStyle(
                  color: c.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (perhatianList.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: c.statusCritical.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${perhatianList.length}',
                    style: TextStyle(
                      color: c.statusCritical,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          iconTheme: IconThemeData(color: c.primary),
          bottom: TabBar(
            labelColor: c.primary,
            unselectedLabelColor: c.greyText,
            indicatorColor: c.primary,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Stok (${stokList.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text('Kedaluwarsa (${kedaluwarsaList.length})'),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationList(context, c, stokList, 'stok'),
            _buildNotificationList(context, c, kedaluwarsaList, 'kadaluarsa'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(
      BuildContext context, AppColors c, List<AttentionItem> items, String type) {
    if (items.isEmpty) {
      return Center(
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
              child: Icon(
                type == 'stok' ? Icons.inventory_2_outlined : Icons.event_available_outlined,
                size: 40,
                color: c.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              type == 'stok'
                  ? 'Semua stok aman! 🎉'
                  : 'Tidak ada barang kedaluwarsa! ✅',
              style: TextStyle(
                color: c.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type == 'stok'
                  ? 'Tidak ada barang dengan stok rendah atau habis.'
                  : 'Semua barang masih jauh dari tanggal kedaluwarsa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isKritis = item.type.endsWith('_kritis');
        final badgeColor = isKritis ? c.statusCritical : c.statusWarning;
        final icon = _getIcon(item.type);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: badgeColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: c.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: c.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
}
