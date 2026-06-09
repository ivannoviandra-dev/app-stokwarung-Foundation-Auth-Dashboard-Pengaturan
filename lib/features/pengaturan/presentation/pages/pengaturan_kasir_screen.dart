import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class PengaturanKasirScreen extends ConsumerWidget {
  const PengaturanKasirScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final c = AppColors.of(context);
    final surface = c.surface;
    final onSurface = c.onSurface;
    final primary = c.primary;
    final primaryContainer = c.primaryContainer;
    final outlineVariant = c.outlineVariant;
    final onSurfaceVariant = c.onSurfaceVariant;
    final surfaceContainerHighest = c.surfaceContainerHighest;
    final statusCritical = c.statusCritical;

    final user = Supabase.instance.client.auth.currentUser;
    final namaKasir = user?.userMetadata?['nama_kasir'] as String? ?? 'Kasir';
    final roleKasir = user?.userMetadata?['role'] as String? ?? 'Kasir';

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Pengaturan',
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: primary),
            onPressed: () {
              // Bantuan action
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: outlineVariant, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: c.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryContainer, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: c.surfaceContainerHighest,
                      child: Icon(Icons.person, size: 48, color: c.greyText),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    namaKasir,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    roleKasir.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      color: onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 14, color: primaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          'Aktif',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // TAMPILAN
            _buildSectionLabel('TAMPILAN', c),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: c.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
              ),
              child: InkWell(
                onTap: () => notifier.toggleDarkMode(!settings.darkMode),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode, color: primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Mode Gelap',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ),
                      Switch(
                        value: settings.darkMode,
                        onChanged: (val) => notifier.toggleDarkMode(val),
                        activeColor: primaryContainer,
                        activeTrackColor: primaryContainer.withValues(alpha: 0.4),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Keamanan
            _buildSectionLabel('Keamanan', c),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: c.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
              ),
              child: _buildNavItem(
                c: c,
                icon: Icons.lock,
                title: 'Ubah Password',
                showDivider: false,
                onTap: () {
                  _showChangePasswordDialog(context, ref);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Bantuan
            _buildSectionLabel('Bantuan', c),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: c.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
              ),
              child: Column(
                children: [
                  _buildNavItem(
                    c: c,
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    showDivider: true,
                    trailingIcon: Icons.open_in_new,
                    onTap: () {},
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Versi Aplikasi',
                          style: TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
                          ),
                        ),
                        Text(
                          'v1.2.0-cashier',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Section
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.tertiaryContainer,
                foregroundColor: c.onTertiaryContainer,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Keluar Akun'),
                    content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Batal', style: TextStyle(color: onSurfaceVariant)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: statusCritical,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.go('/login');
                        },
                        child: const Text('Keluar'),
                      ),
                    ],
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text(
                    'Keluar Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sesi akan berakhir otomatis dalam 8 jam',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.outline,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: c.onSurface,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required AppColors c,
    required IconData icon,
    required String title,
    bool showDivider = true,
    IconData trailingIcon = Icons.chevron_right,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: c.onSurfaceVariant),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: c.onSurface,
                    ),
                  ),
                ),
                Icon(trailingIcon, color: c.outline),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: c.outlineVariant),
      ],
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final c = AppColors.of(context);
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) {
          return AlertDialog(
            backgroundColor: c.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.lock_outline, color: c.primary),
                const SizedBox(width: 8),
                Text('Ubah Password', style: TextStyle(color: c.onSurface)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: oldPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Lama',
                      filled: true,
                      fillColor: c.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      filled: true,
                      fillColor: c.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.primary, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPassController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      filled: true,
                      fillColor: c.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: c.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal', style: TextStyle(color: c.onSurfaceVariant)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final oldPass = oldPassController.text;
                  final newPass = newPassController.text;
                  final confirmPass = confirmPassController.text;

                  if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Semua field harus diisi'), backgroundColor: c.statusCritical),
                    );
                    return;
                  }

                  if (newPass != confirmPass) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Password baru tidak sama'), backgroundColor: c.statusCritical),
                    );
                    return;
                  }

                  if (newPass.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Password minimal 6 karakter'), backgroundColor: c.statusCritical),
                    );
                    return;
                  }

                  final success = ref.read(settingsProvider.notifier).changePassword(oldPass, newPass);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Password berhasil diubah!' : 'Password lama salah'),
                      backgroundColor: success ? c.primary : c.statusCritical,
                    ),
                  );
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }
}
