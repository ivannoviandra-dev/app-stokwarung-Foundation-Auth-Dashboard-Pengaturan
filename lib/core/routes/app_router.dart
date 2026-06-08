import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_owner_screen.dart';
import '../../features/reminder/presentation/pages/notifications_screen.dart';
import '../../features/utang/presentation/pages/buku_utang_screen.dart';
import '../../features/barang/presentation/pages/manajemen_barang_screen.dart';
import '../../features/transaksi/presentation/pages/riwayat_transaksi_screen.dart';
import '../../features/reminder/presentation/pages/perlu_perhatian_screen.dart';
import '../../features/kasir/presentation/pages/kasir_screen.dart';
import '../../features/laporan/presentation/pages/laporan_screen.dart';
import '../widgets/main_layout_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayoutScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard_owner',
              builder: (context, state) => const DashboardOwnerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/barang',
              builder: (context, state) => const ManajemenBarangScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/kasir',
              builder: (context, state) => const KasirScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/utang',
              builder: (context, state) => const BukuUtangScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/laporan',
              builder: (context, state) => const LaporanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/atur',
              builder: (context, state) => const Scaffold(body: Center(child: Text('Halaman Pengaturan (Segera Hadir)'))),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/transaksi',
      builder: (context, state) => const RiwayatTransaksiScreen(),
    ),
    GoRoute(
      path: '/perhatian',
      builder: (context, state) => const PerluPerhatianScreen(),
    ),
  ],
);

