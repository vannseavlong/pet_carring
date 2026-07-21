import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/services/auth_deep_link_service.dart';
import '../data/datasources/local/booking_local_datasource.dart';
import '../data/datasources/local/catalog_local_datasource.dart';
import '../data/datasources/local/shop_local_datasource.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/datasources/remote/booking_remote_datasource.dart';
import '../data/datasources/remote/catalog_remote_datasource.dart';
import '../data/datasources/remote/shop_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../data/repositories/catalog_repository_impl.dart';
import '../data/repositories/shop_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/catalog_repository.dart';
import '../domain/repositories/shop_repository.dart';
import '../domain/usecases/add_booking_usecase.dart';
import '../domain/usecases/get_bookings_usecase.dart';
import '../domain/usecases/get_catalog_items_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/get_featured_catalog_items_usecase.dart';
import '../domain/usecases/get_shop_by_id_usecase.dart';
import '../domain/usecases/get_shops_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/login_with_google_token_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/booking_controller.dart';
import '../presentation/controllers/navigation_controller.dart';
import '../presentation/controllers/shop_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);

    // Auth
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetCurrentUserUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => LoginUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => RegisterUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => LogoutUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => LoginWithGoogleTokenUseCase(Get.find()), fenix: true);

    // Shops
    Get.lazyPut<ShopRemoteDataSource>(
      () => ShopRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ShopLocalDataSource>(
      () => ShopLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<ShopRepository>(
      () => ShopRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetShopsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetShopByIdUseCase(Get.find()), fenix: true);

    // Catalog items (shop-scoped services/products)
    Get.lazyPut<CatalogRemoteDataSource>(
      () => CatalogRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<CatalogLocalDataSource>(
      () => CatalogLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<CatalogRepository>(
      () => CatalogRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetCatalogItemsUseCase(Get.find()), fenix: true);
    Get.lazyPut(
      () => GetFeaturedCatalogItemsUseCase(Get.find()),
      fenix: true,
    );
    Get.lazyPut(
      () => ShopController(Get.find(), Get.find(), Get.find()),
      fenix: true,
    );

    // Bookings
    Get.lazyPut<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<BookingLocalDataSource>(
      () => BookingLocalDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<BookingRepository>(
      () => BookingRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );
    Get.lazyPut(() => GetBookingsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddBookingUseCase(Get.find()), fenix: true);

    // Controllers — auth must be eager so AuthWrapper can find it immediately
    Get.put(
      AuthController(
        Get.find(), Get.find(), Get.find(), Get.find(), Get.find(),
      ),
    );
    Get.put(AuthDeepLinkService()..init());
    Get.lazyPut(() => NavigationController(), fenix: true);
    Get.lazyPut(
      () => BookingController(Get.find(), Get.find()),
      fenix: true,
    );
  }
}
