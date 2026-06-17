abstract final class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String googleAuth = '/auth/google';

  // Bookings
  static const String bookings = '/bookings';
  static String bookingById(String id) => '/bookings/$id';

  // Services
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
}
