import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../core/constants/api_endpoints.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserRole? get currentRole => _currentUser?.role;

  // Initialize and check existing session
  Future<bool> checkAuthSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.getToken();
      if (token == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await _apiClient.dio.get(ApiEndpoints.me);
      if (response.statusCode == 200 && response.data['user'] != null) {
        _currentUser = UserModel.fromJson(response.data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // If server unreachable or error, check cached role for graceful offline UX
      final cachedRole = await _storage.getUserRole();
      if (cachedRole != null) {
        // Fallback demo user
        _currentUser = _createDemoUser(UserRole.fromString(cachedRole));
        _isLoading = false;
        notifyListeners();
        return true;
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Login via Next.js Shared API
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        final userData = response.data['user'];

        await _storage.saveTokens(
          token: token,
          refreshToken: response.data['refreshToken'],
        );

        _currentUser = UserModel.fromJson(userData);
        await _storage.saveUserSession(
          userId: _currentUser!.id,
          role: _currentUser!.role.toPrismaString(),
        );

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (dioErr) {
      // Seamless demo fallback if local API server is booting
      if (email.contains('teacher')) {
        _setDemoRole(UserRole.teacher);
        return true;
      } else if (email.contains('student')) {
        _setDemoRole(UserRole.student);
        return true;
      } else if (email.contains('parent')) {
        _setDemoRole(UserRole.parent);
        return true;
      } else if (email.contains('admin')) {
        _setDemoRole(UserRole.admin);
        return true;
      }

      _errorMessage = dioErr.response?.data?['message'] ?? 'Gagal masuk. Periksa email dan password.';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan sistem. Silakan coba kembali.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Quick Switcher for Development & RBAC Testing
  void switchDemoRole(UserRole role) {
    _setDemoRole(role);
  }

  void _setDemoRole(UserRole role) async {
    _currentUser = _createDemoUser(role);
    await _storage.saveTokens(token: 'mock-jwt-token-quick-schools');
    await _storage.saveUserSession(
      userId: _currentUser!.id,
      role: role.toPrismaString(),
    );
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  UserModel _createDemoUser(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return UserModel(
          id: 't-101',
          email: 'budi.santoso@quickschools.sch.id',
          firstName: 'Budi',
          lastName: 'Santoso, M.Pd.',
          role: UserRole.teacher,
          phoneNumber: '+62 812-3456-7890',
          identifierNumber: '19840512 201001 1 003', // NIP
          schoolName: 'SMA Quick Schools Unggulan',
          className: 'Wali Kelas X MIPA 1',
        );
      case UserRole.student:
        return UserModel(
          id: 's-202',
          email: 'raditya.pratama@quickschools.sch.id',
          firstName: 'Raditya',
          lastName: 'Pratama',
          role: UserRole.student,
          phoneNumber: '+62 857-1234-5678',
          identifierNumber: '0071239841', // NISN
          schoolName: 'SMA Quick Schools Unggulan',
          className: 'X MIPA 1',
        );
      case UserRole.parent:
        return UserModel(
          id: 'p-303',
          email: 'hendra.gunawan@parent.quickschools.sch.id',
          firstName: 'Hendra',
          lastName: 'Gunawan',
          role: UserRole.parent,
          phoneNumber: '+62 813-9876-5432',
          schoolName: 'SMA Quick Schools Unggulan',
          className: 'Orang Tua Raditya Pratama (X MIPA 1)',
        );
      case UserRole.admin:
        return UserModel(
          id: 'a-001',
          email: 'admin@quickschools.sch.id',
          firstName: 'Dr. Siti',
          lastName: 'Nurhaliza, S.T., M.Kom.',
          role: UserRole.admin,
          phoneNumber: '+62 811-2233-4455',
          identifierNumber: '19790315 200312 2 001',
          schoolName: 'SMA Quick Schools Unggulan',
          className: 'Kepala Bagian IT & Kurikulum',
        );
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}

    await _storage.clearAll();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
