import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../services/notification_service.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key, required this.navigationShell});
  
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  bool _notificationsSent = false;

  @override
  void initState() {
    super.initState();
    // Kirim notifikasi otomatis saat pertama kali masuk ke dashboard
    _triggerAutoNotifications();
  }

  Future<void> _triggerAutoNotifications() async {
    if (_notificationsSent) return;
    _notificationsSent = true;

    // Tunggu provider siap
    await Future.delayed(const Duration(seconds: 2));
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

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        backgroundColor: c.navBarBg,
        indicatorColor: c.navIndicator,
        surfaceTintColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: c.greyText),
            selectedIcon: Icon(Icons.home, color: c.primaryGreen),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined, color: c.greyText),
            selectedIcon: Icon(Icons.inventory_2, color: c.primaryGreen),
            label: 'Barang',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined, color: c.greyText),
            selectedIcon: Icon(Icons.point_of_sale, color: c.primaryGreen),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined, color: c.greyText),
            selectedIcon: Icon(Icons.receipt_long, color: c.primaryGreen),
            label: 'Utang',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined, color: c.greyText),
            selectedIcon: Icon(Icons.analytics, color: c.primaryGreen),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: c.greyText),
            selectedIcon: Icon(Icons.settings, color: c.primaryGreen),
            label: 'Atur',
          ),
        ],
      ),
    );
  }
}
