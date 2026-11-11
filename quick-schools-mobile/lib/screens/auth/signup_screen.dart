import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/academic_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';
import 'widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = true;
  String _passwordValue = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _identifierLabel {
    switch (_selectedRole) {
      case UserRole.student:
        return 'NISN (Opsional)';
      case UserRole.teacher:
        return 'NIP / NUPTK (Opsional)';
      case UserRole.parent:
        return 'NISN Anak (Opsional)';
      case UserRole.admin:
        return 'ID Pegawai';
    }
  }

  String get _identifierHint {
    switch (_selectedRole) {
      case UserRole.student:
        return 'Contoh: 0071239841';
      case UserRole.teacher:
        return 'Contoh: 198405122010011003';
      case UserRole.parent:
        return 'Nomor induk siswa yang diampu';
      case UserRole.admin:
        return 'ID Administrator';
    }
  }

  double get _passwordStrength {
    if (_passwordValue.isEmpty) return 0.0;
    double score = 0.0;
    if (_passwordValue.length >= 6) score += 0.35;
    if (_passwordValue.length >= 8) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(_passwordValue)) score += 0.2;
    if (RegExp(r'[A-Z!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordValue)) {
      score += 0.2;
    }
    return score.clamp(0.0, 1.0);
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.4) return AppColors.danger;
    if (_passwordStrength < 0.75) return AppColors.warning;
    return AppColors.success;
  }

  String get _strengthLabel {
    if (_passwordValue.isEmpty) return '';
    if (_passwordStrength < 0.4) return 'Lemah';
    if (_passwordStrength < 0.75) return 'Sedang';
    return 'Kuat';
  }

  void _navigateToLogin() {
    Provider.of<AuthProvider>(context, listen: false).clearError();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Silakan setujui Syarat & Ketentuan terlebih dahulu.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      identifierNumber: _identifierController.text.trim(),
    );

    if (success && mounted) {
      Provider.of<AttendanceProvider>(context, listen: false).fetchAttendance();
      Provider.of<AcademicProvider>(context, listen: false)
          .fetchAllAcademicData();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return AuthScaffold(
      title: 'Buat Akun Baru',
      subtitle: 'Bergabung ke portal akademik digital sekolah Anda.',
      isSignUp: true,
      onToggleMode: _navigateToLogin,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Sudah memiliki akun? ',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondaryLight,
            ),
          ),
          GestureDetector(
            onTap: _navigateToLogin,
            child: const Text(
              'Masuk di sini',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (auth.errorMessage != null) ...[
              AuthErrorBanner(message: auth.errorMessage!),
              const SizedBox(height: 16),
            ],

            // Role Selector
            const Text(
              'Daftar Sebagai',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleSelector(
                  role: UserRole.student,
                  label: 'Siswa',
                  icon: Icons.person_outline_rounded,
                ),
                const SizedBox(width: 8),
                _buildRoleSelector(
                  role: UserRole.teacher,
                  label: 'Guru',
                  icon: Icons.cast_for_education_rounded,
                ),
                const SizedBox(width: 8),
                _buildRoleSelector(
                  role: UserRole.parent,
                  label: 'Orang Tua',
                  icon: Icons.family_restroom_rounded,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Full Name
            AuthTextField(
              label: 'Nama Lengkap',
              hint: 'Contoh: Raditya Pratama',
              controller: _nameController,
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().length < 3) {
                  return 'Nama lengkap minimal 3 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            AuthTextField(
              label: 'Alamat Email',
              hint: 'nama@quickschools.sch.id',
              controller: _emailController,
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || !val.contains('@') || !val.contains('.')) {
                  return 'Masukkan format email yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Identifier (NISN / NIP)
            AuthTextField(
              label: _identifierLabel,
              hint: _identifierHint,
              controller: _identifierController,
              icon: Icons.numbers_rounded,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Password
            AuthTextField(
              label: 'Kata Sandi',
              hint: 'Minimal 6 karakter',
              controller: _passwordController,
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              onChanged: (val) => setState(() => _passwordValue = val),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) {
                if (val == null || val.length < 6) {
                  return 'Kata sandi minimal 6 karakter';
                }
                return null;
              },
            ),

            // Password Strength Indicator
            if (_passwordValue.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        minHeight: 5,
                        backgroundColor: AppColors.borderLight,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_strengthColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _strengthLabel,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _strengthColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Confirm Password
            AuthTextField(
              label: 'Konfirmasi Kata Sandi',
              hint: 'Ulangi kata sandi Anda',
              controller: _confirmPasswordController,
              icon: Icons.verified_user_outlined,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19,
                  color: AppColors.textSecondaryLight,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (val) {
                if (val != _passwordController.text) {
                  return 'Konfirmasi kata sandi tidak cocok';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Terms checkbox
            InkWell(
              onTap: () => setState(() => _agreeTerms = !_agreeTerms),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _agreeTerms,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (v) =>
                            setState(() => _agreeTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi portal Quick Schools.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            AuthPrimaryButton(
              text: 'Buat Akun Sekarang',
              isLoading: auth.isLoading,
              onPressed: _handleSignUp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySubtle : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

