import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_provider.dart';

class PengaturanScreen extends ConsumerWidget {
  const PengaturanScreen({super.key});

  // Colors are now provided by AppColors.of(context)

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

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Pengaturan Owner',
          style: TextStyle(
            color: primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      Icon(Icons.help_outline, color: primary),
                      const SizedBox(width: 8),
                      const Text('Bantuan'),
                    ],
                  ),
                  content: const Text(
                    'Halaman ini digunakan untuk mengatur profil toko, '
                    'tampilan aplikasi, keamanan akun, serta pengaturan '
                    'notifikasi stok dan kedaluwarsa barang.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Mengerti', style: TextStyle(color: primary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: outlineVariant, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.store, color: primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.namaToko,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'v1.2.0 • Premium',
                          style: TextStyle(
                            fontSize: 14,
                            color: onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: primary),
                    onPressed: () {
                      _showEditDialog(
                        context,
                        title: 'Edit Nama Toko',
                        currentValue: settings.namaToko,
                        onSave: (val) => notifier.updateNamaToko(val),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // PROFIL TOKO
            _buildSectionLabel('PROFIL TOKO', c),
            const SizedBox(height: 8),
            _buildSettingsGroup(c, [
              _buildNavItem(
                c: c,
                icon: Icons.store,
                title: 'Nama Toko',
                subtitle: settings.namaToko,
                showDivider: true,
                onTap: () {
                  _showEditDialog(
                    context,
                    title: 'Edit Nama Toko',
                    currentValue: settings.namaToko,
                    onSave: (val) => notifier.updateNamaToko(val),
                  );
                },
              ),
              _buildNavItem(
                c: c,
                icon: Icons.location_on,
                title: 'Alamat',
                subtitle: settings.alamat,
                showDivider: true,
                onTap: () {
                  _showEditDialog(
                    context,
                    title: 'Edit Alamat',
                    currentValue: settings.alamat,
                    onSave: (val) => notifier.updateAlamat(val),
                  );
                },
              ),
              _buildNavItem(
                c: c,
                icon: Icons.phone,
                title: 'Nomor HP',
                subtitle: settings.nomorHp,
                showDivider: false,
                onTap: () {
                  _showEditDialog(
                    context,
                    title: 'Edit Nomor HP',
                    currentValue: settings.nomorHp,
                    onSave: (val) => notifier.updateNomorHp(val),
                    keyboardType: TextInputType.phone,
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),

            // TAMPILAN
            _buildSectionLabel('TAMPILAN', c),
            const SizedBox(height: 8),
            _buildSettingsGroup(c, [
              Padding(
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
            ]),
            const SizedBox(height: 24),

            // MANAJEMEN
            _buildSectionLabel('MANAJEMEN', c),
            const SizedBox(height: 8),
            _buildSettingsGroup(c, [
              _buildNavItem(
                c: c,
                icon: Icons.badge,
                title: 'Manajemen Kasir',
                subtitle: '3 Akun Aktif',
                showDivider: false,
                onTap: () {
                  _showManajemenKasirSheet(context);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // KEAMANAN
            _buildSectionLabel('KEAMANAN', c),
            const SizedBox(height: 8),
            _buildSettingsGroup(c, [
              _buildNavItem(
                c: c,
                icon: Icons.lock,
                title: 'Ubah Password',
                showDivider: false,
                onTap: () {
                  _showChangePasswordDialog(context, ref);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // REMINDER & NOTIFIKASI
            _buildSectionLabel('REMINDER & NOTIFIKASI', c),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stok Minimum Default
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stok Minimum Default',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        '${settings.stokMinimum} Pcs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: primary,
                      inactiveTrackColor: surfaceContainerHighest,
                      thumbColor: primary,
                      overlayColor: primary.withValues(alpha: 0.12),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      value: settings.stokMinimum.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      onChanged: (val) => notifier.updateStokMinimum(val.round()),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1 Pc', style: TextStyle(fontSize: 10, color: onSurfaceVariant)),
                      Text('20 Pcs', style: TextStyle(fontSize: 10, color: onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Notifikasi Kedaluwarsa
                  Text(
                    'Notifikasi Kedaluwarsa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['H-7', 'H-3', 'H-1'].map((label) {
                      final isSelected = settings.selectedExpiry.contains(label);
                      return GestureDetector(
                        onTap: () => notifier.toggleExpiry(label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryContainer.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? primary : outlineVariant,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: isSelected ? primary : onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Keluar Akun Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: statusCritical,
                side: BorderSide(color: statusCritical, width: 2),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

            // Version Footer
            Text(
              'StokWarung Versi 1.2.0 (Build 2024-05)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: onSurfaceVariant),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─── Helper Builders ──────────────────────────────────────────────

  Widget _buildSectionLabel(String label, AppColors c) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: c.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(AppColors c, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: c.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildNavItem({
    required AppColors c,
    required IconData icon,
    required String title,
    String? subtitle,
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: c.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 14, color: c.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.outlineVariant),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: c.outlineVariant),
      ],
    );
  }

  // ─── Dialogs ──────────────────────────────────────────────────────

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String currentValue,
    required ValueChanged<String> onSave,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final c = AppColors.of(context);
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: c.onSurface)),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: c.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: c.primary, width: 2),
            ),
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
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title berhasil disimpan'),
                    backgroundColor: c.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
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
                      SnackBar(
                        content: const Text('Semua field harus diisi'),
                        backgroundColor: c.statusCritical,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                    return;
                  }

                  if (newPass != confirmPass) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password baru tidak sama'),
                        backgroundColor: c.statusCritical,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                    return;
                  }

                  if (newPass.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Password minimal 6 karakter'),
                        backgroundColor: c.statusCritical,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                    return;
                  }

                  final success = ref.read(settingsProvider.notifier).changePassword(oldPass, newPass);
                  Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Password berhasil diubah!'
                          : 'Password lama salah'),
                      backgroundColor: success ? c.primary : c.statusCritical,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  void _showManajemenKasirSheet(BuildContext context) {
    final c = AppColors.of(context);
    final List<Map<String, dynamic>> kasirList = [
      {'nama': 'Admin Utama', 'role': 'Owner', 'aktif': true},
      {'nama': 'Siti Rahayu', 'role': 'Kasir', 'aktif': true},
      {'nama': 'Budi Santoso', 'role': 'Kasir', 'aktif': true},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            builder: (_, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: c.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Manajemen Kasir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: c.onSurface,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            setSheetState(() {
                              kasirList.add({
                                'nama': 'Kasir Baru ${kasirList.length}',
                                'role': 'Kasir',
                                'aktif': true,
                              });
                            });
                          },
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Tambah'),
                          style: FilledButton.styleFrom(
                            backgroundColor: c.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: kasirList.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: c.outlineVariant),
                        itemBuilder: (_, index) {
                          final kasir = kasirList[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: c.primaryContainer.withValues(alpha: 0.2),
                              child: Text(
                                kasir['nama'].toString().substring(0, 1).toUpperCase(),
                                style: TextStyle(color: c.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              kasir['nama'],
                              style: TextStyle(fontWeight: FontWeight.w600, color: c.onSurface),
                            ),
                            subtitle: Text(
                              kasir['role'],
                              style: TextStyle(color: c.onSurfaceVariant, fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kasir['aktif']
                                        ? c.primaryContainer.withValues(alpha: 0.2)
                                        : c.outlineVariant.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    kasir['aktif'] ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: kasir['aktif'] ? c.primary : c.outline,
                                    ),
                                  ),
                                ),
                                if (kasir['role'] != 'Owner')
                                  IconButton(
                                    icon: Icon(Icons.more_vert, color: c.outline, size: 20),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: ctx2,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                        ),
                                        builder: (ctx3) => SafeArea(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  kasir['aktif'] ? Icons.person_off : Icons.person,
                                                  color: c.primary,
                                                ),
                                                title: Text(kasir['aktif'] ? 'Nonaktifkan' : 'Aktifkan'),
                                                onTap: () {
                                                  Navigator.pop(ctx3);
                                                  setSheetState(() {
                                                    kasirList[index]['aktif'] = !kasirList[index]['aktif'];
                                                  });
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(Icons.delete_outline, color: c.statusCritical),
                                                title: Text('Hapus Akun', style: TextStyle(color: c.statusCritical)),
                                                onTap: () {
                                                  Navigator.pop(ctx3);
                                                  setSheetState(() {
                                                    kasirList.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
