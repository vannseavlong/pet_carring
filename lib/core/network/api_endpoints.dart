abstract final class ApiEndpoints {
  // Auth
  static const String login = '/user/auth/login';
  static const String register = '/user/auth/register';
  static const String me = '/user/auth/me';
  static const String googleAuth = '/user/auth/google';

  // Bookings
  static const String bookings = '/user/bookings';
  static String bookingById(String id) => '/user/bookings/$id';

  // Shops
  static const String shops = '/user/shops';
  static String shopById(String id) => '/user/shops/$id';
  static String shopCatalogItems(String shopId) =>
      '/user/shops/$shopId/catalog-items';
}
