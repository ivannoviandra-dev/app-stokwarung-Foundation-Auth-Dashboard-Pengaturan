import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key, required this.navigationShell});
  
  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
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
