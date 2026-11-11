import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/academic_provider.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'raditya.pratama@quickschools.sch.id');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginSuccess() {
    Provider.of<AttendanceProvider>(context, listen: false).fetchAttendance();
    Provider.of<AcademicProvider>(context, listen: false).fetchAllAcademicData();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  Future<void> _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      _onLoginSuccess();
    }
  }

  void _selectDemoAccount(UserRole role) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.switchDemoRole(role);
    _onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Brand Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.school_rounded, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),
              const Text(
                'Selamat Datang di\nQuick Schools',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masuk menggunakan akun portal sekolah terpadu Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),

              if (auth.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          auth.errorMessage!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              const Text(
                'Email / NISN / NIP',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'nama@quickschools.sch.id',
                  prefixIcon: Icon(Icons.mail_outline_rounded, size: 20, color: AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(height: 18),

              // Password field
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.textSecondaryLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Primary Login Button
              CustomButton(
                text: 'Masuk Sekarang',
                isLoading: auth.isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 36),

              // Quick RBAC Role Demo Switcher
              Center(
                child: Column(
                  children: [
                    const Text(
                      'UJI COBA ROLE-BASED ACCESS (RBAC)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildRoleChip(
                          label: '👨‍🎓 Siswa',
                          role: UserRole.student,
                          subtitle: 'Raditya',
                        ),
                        _buildRoleChip(
                          label: '👩‍🏫 Guru',
                          role: UserRole.teacher,
                          subtitle: 'Pak Budi',
                        ),
                        _buildRoleChip(
                          label: '👨‍👩‍👧 Orang Tua',
                          role: UserRole.parent,
                          subtitle: 'Pak Hendra',
                        ),
                        _buildRoleChip(
                          label: '🛡️ Admin',
                          role: UserRole.admin,
                          subtitle: 'Dr. Siti',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip({
    required String label,
    required UserRole role,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () => _selectDemoAccount(role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
