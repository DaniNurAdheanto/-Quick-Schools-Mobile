/// Shared API Endpoints connecting to Next.js Backend
class ApiEndpoints {
  // Base configuration
  static const String defaultBaseUrl = 'https://ais-dev-m7rrvexq7qrkdxm6ovm745-538110963549.asia-east1.run.app/api';
  
  // Authentication & Session
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String refreshToken = '/auth/refresh';
  
  // Academic & Master Data
  static const String dashboard = '/dashboard';
  static const String students = '/students';
  static const String teachers = '/teachers';
  static const String classes = '/classes';
  static const String subjects = '/subjects';
  static const String schedules = '/schedules';
  static const String attendance = '/attendance';
  static const String markAttendance = '/attendance/mark';
  static const String grades = '/grades';
  static const String announcements = '/announcements';
  static const String notifications = '/notifications';
}
