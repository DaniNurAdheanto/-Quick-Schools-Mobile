import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:quick_schools_mobile/core/theme/app_theme.dart';
import 'package:quick_schools_mobile/models/user_model.dart';
import 'package:quick_schools_mobile/providers/academic_provider.dart';
import 'package:quick_schools_mobile/providers/attendance_provider.dart';
import 'package:quick_schools_mobile/providers/auth_provider.dart';
import 'package:quick_schools_mobile/providers/theme_provider.dart';
import 'package:quick_schools_mobile/screens/attendance/attendance_screen.dart';
import 'package:quick_schools_mobile/screens/dashboard/dashboard_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets(
      'Home dashboard removes Presensi Kehadiran Siswa, and AttendanceScreen renders it',
      (tester) async {
    final authProvider = AuthProvider();
    authProvider.switchDemoRole(UserRole.student);

    final attendanceProvider = AttendanceProvider();
    // Fetch seed data
    await attendanceProvider.fetchAttendance();

    final academicProvider = AcademicProvider();
    await academicProvider.fetchAllAcademicData();

    // 1. Test Dashboard Home: Presensi Kehadiran Siswa is NOT present on Home
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<AttendanceProvider>.value(
              value: attendanceProvider),
          ChangeNotifierProvider<AcademicProvider>.value(
              value: academicProvider),
          ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Presensi Kehadiran Siswa is REMOVED from Home
    expect(find.text('Presensi Kehadiran Siswa'), findsNothing);

    // 2. Test AttendanceScreen: Presensi Kehadiran Siswa is present on Attendance Page
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<AttendanceProvider>.value(
              value: attendanceProvider),
          ChangeNotifierProvider<AcademicProvider>.value(
              value: academicProvider),
          ChangeNotifierProvider<ThemeProvider>(
              create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AttendanceScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Presensi Kehadiran Siswa Header is present on AttendanceScreen
    expect(find.text('Presensi Kehadiran Siswa'), findsOneWidget);

    // Verify Status Hari Ini section is present
    expect(find.text('Status Hari Ini:'), findsOneWidget);

    // Verify Status badge displays Alpa (- WIB) initially when not checked in
    expect(find.text('Alpa (- WIB)'), findsOneWidget);

    // Verify 5 metric labels are present
    expect(find.text('Hadir'), findsWidgets);
    expect(find.text('Terlambat'), findsWidgets);
    expect(find.text('Izin'), findsWidgets);
    expect(find.text('Sakit'), findsWidgets);
    expect(find.text('Alpa'), findsWidgets);

    // Verify counts matching seed data: 3 Hadir, 2 Terlambat, 0 Izin, 0 Sakit, 8 Alpa
    expect(attendanceProvider.presentCount, equals(3));
    expect(attendanceProvider.lateCount, equals(2));
    expect(attendanceProvider.permissionCount, equals(0));
    expect(attendanceProvider.sickCount, equals(0));
    expect(attendanceProvider.absentCount, equals(8));
  });
}
