abstract final class ApiEndpoints {
  // Auth
  static const String login = '/user/auth/login';
  static const String register = '/user/auth/register';
  static const String me = '/user/auth/me';
  static const String googleAuth = '/user/auth/google';

  // Bookings
  static const String bookings = '/user/bookings';
  static String bookingById(String id) => '/user/bookings/$id';

  // Shops — assumed contract, mirrors the /user/services convention;
  // backend endpoints are landing in parallel (see paw_sheetDB TODO.md).
  // Falls back to local mock data (see ShopLocalDataSource) until live.
  static const String shops = '/user/shops';
  static String shopById(String id) => '/user/shops/$id';
  static String shopCatalogItems(String shopId) =>
      '/user/shops/$shopId/catalog-items';
}
