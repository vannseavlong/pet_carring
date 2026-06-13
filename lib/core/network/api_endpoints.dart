abstract final class ApiEndpoints {
  static const String baseUrl = 'https://api.yourpetapp.com/v1';

  static const String bookings = '/bookings';
  static String bookingById(String id) => '/bookings/$id';
}
