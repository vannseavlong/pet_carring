import 'package:get/get.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/entities/shop.dart';
import '../views/booking/add_booking_screen.dart';
import '../views/booking/booking_confirmation_screen.dart';
import '../views/browse/browse_screen.dart';
import '../views/search/search_screen.dart';
import '../views/shop/shop_detail_screen.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.search, page: () => const SearchScreen()),
    GetPage(
      name: AppRoutes.browse,
      page: () => BrowseScreen(initialCategory: Get.arguments as String?),
    ),
    GetPage(
      name: AppRoutes.shopDetail,
      page: () => ShopDetailScreen(shop: Get.arguments as Shop),
    ),
    GetPage(
      name: AppRoutes.booking,
      page: () {
        final args = Get.arguments as ({Shop shop, CatalogItem item});
        return AddBookingScreen(shop: args.shop, item: args.item);
      },
    ),
    GetPage(
      name: AppRoutes.bookingConfirmation,
      page: () {
        final args = Get.arguments as BookingConfirmationArgs;
        return BookingConfirmationScreen(booking: args.booking, shop: args.shop);
      },
    ),
  ];
}
