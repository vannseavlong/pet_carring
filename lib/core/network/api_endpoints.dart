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

  // Catalog items (cross-shop)
  static String catalogItems({String? type, int? limit}) {
    final params = <String, String>{'type': ?type, 'limit': ?limit?.toString()};
    if (params.isEmpty) return '/user/catalog-items';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '/user/catalog-items?$query';
  }

  // Categories
  static const String categories = '/user/categories';
}
