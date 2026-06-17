import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/services/auth_deep_link_service.dart';
import '../data/datasources/local/booking_local_datasource.dart';
import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/datasources/remote/booking_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/usecases/add_booking_usecase.dart';
import '../domain/usecases/get_bookings_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/login_with_google_token_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/booking_controller.dart';
import '../presentation/controllers/navigation_controller.dart';

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
    Get.lazyPut(() => BookingController(Get.find(), Get.find()), fenix: true);
  }
}
