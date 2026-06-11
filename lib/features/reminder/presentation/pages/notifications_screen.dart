import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          title: Text(
            'Notifikasi',
            style: TextStyle(
              color: c.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(color: c.primary),
          bottom: TabBar(
            labelColor: c.primary,
            unselectedLabelColor: c.greyText,
            indicatorColor: c.primary,
            tabs: const [
              Tab(text: 'Stok Rendah'),
              Tab(text: 'Kedaluwarsa'),
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
            Icon(
              type == 'stok' ? Icons.inventory_2_outlined : Icons.event_available_outlined,
              size: 64,
              color: c.greyText.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: TextStyle(color: c.greyText, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isKritis = item.type.endsWith('_kritis');
        final badgeColor = isKritis ? c.statusCritical.withOpacity(0.1) : c.statusWarning.withOpacity(0.1);
        final badgeTextColor = isKritis ? c.statusCritical : c.statusWarning;
        final icon = type == 'stok' ? Icons.inventory_2_outlined : Icons.event_busy_outlined;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.outlineVariant.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
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
                  color: isKritis ? c.statusCritical.withOpacity(0.05) : c.statusWarning.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: isKritis ? c.statusCritical : c.statusWarning),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: c.darkText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: c.greyText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.badgeText,
                  style: TextStyle(
                    color: badgeTextColor,
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
}
