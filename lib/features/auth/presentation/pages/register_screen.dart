import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  final _formKey = GlobalKey<FormState>();
  final _namaTokoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _namaTokoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Password strength: 0 = empty, 1 = weak, 2 = medium, 3 = strong
  int _getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%\^&\*\(\)\-_=\+]'))) score++;
    if (score <= 1) return 1;
    if (score <= 2) return 2;
    return 3;
  }

  String _strengthLabel(int strength) {
    switch (strength) {
      case 1:
        return 'Lemah';
      case 2:
        return 'Sedang';
      case 3:
        return 'Kuat';
      default:
        return '';
    }
  }

  Color _strengthColor(int strength) {
    switch (strength) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF10B981);
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final primaryGreen = c.primaryGreen;
    final bgColor = c.background;
    final darkText = c.darkText;
    final greyText = c.greyText;

    final passwordStrength = _getPasswordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Logo
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined, color: primaryGreen, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'StokWarung',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Circular Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Center(
                    child: Text(
                      'Buat Akun Baru',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Daftarkan warung Anda dan mulai kelola stok dengan mudah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: greyText,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: c.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama Toko
                          Text(
                            'Nama Toko',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _namaTokoController,
                            textCapitalization: TextCapitalization.words,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nama toko tidak boleh kosong';
                              }
                              if (val.trim().length < 3) {
                                return 'Nama toko minimal 3 karakter';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.storefront_outlined, color: greyText),
                              hintText: 'Warung Maju Jaya',
                              hintStyle: TextStyle(color: greyText, fontSize: 14),
                              filled: true,
                              fillColor: c.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryGreen),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email
                          Text(
                            'Email',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(val.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline, color: greyText),
                              hintText: 'nama@warung.com',
                              hintStyle: TextStyle(color: greyText, fontSize: 14),
                              filled: true,
                              fillColor: c.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryGreen),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password
                          Text(
                            'Password',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: (_) => setState(() {}),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (val.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: greyText),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: greyText,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              hintText: 'Minimal 6 karakter',
                              hintStyle: TextStyle(color: greyText, fontSize: 14),
                              filled: true,
                              fillColor: c.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryGreen),
                              ),
                            ),
                          ),

                          // Password Strength Indicator
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: passwordStrength / 3,
                                      backgroundColor: c.outlineVariant,
                                      color: _strengthColor(passwordStrength),
                                      minHeight: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _strengthLabel(passwordStrength),
                                  style: TextStyle(
                                    color: _strengthColor(passwordStrength),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Konfirmasi Password
                          Text(
                            'Konfirmasi Password',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Konfirmasi password tidak boleh kosong';
                              }
                              if (val != _passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline, color: greyText),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: greyText,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirm = !_obscureConfirm;
                                  });
                                },
                              ),
                              hintText: 'Ulangi password',
                              hintStyle: TextStyle(color: greyText, fontSize: 14),
                              filled: true,
                              fillColor: c.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: c.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: primaryGreen),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Terms Checkbox
                          InkWell(
                            onTap: () {
                              setState(() {
                                _agreeTerms = !_agreeTerms;
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      onChanged: (val) {
                                        setState(() {
                                          _agreeTerms = val ?? false;
                                        });
                                      },
                                      activeColor: primaryGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: greyText,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                        children: [
                                          const TextSpan(text: 'Saya menyetujui '),
                                          TextSpan(
                                            text: 'Syarat & Ketentuan',
                                            style: TextStyle(
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const TextSpan(text: ' serta '),
                                          TextSpan(
                                            text: 'Kebijakan Privasi',
                                            style: TextStyle(
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const TextSpan(text: ' StokWarung.'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Register Button
                          Consumer(
                            builder: (context, ref, child) {
                              final authState = ref.watch(authProvider);

                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: (authState.isLoading || !_agreeTerms)
                                      ? null
                                      : () async {
                                          if (!_formKey.currentState!.validate()) {
                                            return;
                                          }
                                          final success = await ref
                                              .read(authProvider.notifier)
                                              .register(
                                                namaToko: _namaTokoController.text.trim(),
                                                email: _emailController.text.trim(),
                                                password: _passwordController.text,
                                              );

                                          if (success) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Registrasi berhasil! Silakan login.'),
                                                  backgroundColor: const Color(0xFF10B981),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                              context.go('/login');
                                            }
                                          } else if (ref.read(authProvider).error != null) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(ref.read(authProvider).error!),
                                                  backgroundColor: Colors.red,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: primaryGreen.withValues(alpha: 0.4),
                                    disabledForegroundColor: Colors.white70,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              color: Colors.white, strokeWidth: 2),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Daftar Sekarang',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_outlined, size: 20),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Divider ATAU
                          Row(
                            children: [
                              Expanded(child: Divider(color: c.outlineVariant)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'ATAU',
                                  style: TextStyle(
                                    color: greyText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: c.outlineVariant)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Login Link
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Sudah punya akun?',
                                  style: TextStyle(color: greyText, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Masuk di Sini',
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Help Banner (same as login)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: c.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: c.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.support_agent_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Butuh Bantuan?',
                                style: TextStyle(
                                  color: c.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Hubungi tim CS kami 24/7',
                                style: TextStyle(
                                  color: c.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
