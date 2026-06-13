import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../data/datasources/local/booking_local_datasource.dart';
import '../data/datasources/remote/booking_remote_datasource.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/usecases/add_booking_usecase.dart';
import '../domain/usecases/get_bookings_usecase.dart';
import '../presentation/controllers/booking_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Core
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);

    // Data sources
    Get.lazyPut<BookingRemoteDataSource>(
      () => BookingRemoteDataSourceImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<BookingLocalDataSource>(
      () => BookingLocalDataSourceImpl(),
      fenix: true,
    );

    // Repository
    Get.lazyPut<BookingRepository>(
      () => BookingRepositoryImpl(Get.find(), Get.find()),
      fenix: true,
    );

    // Use cases
    Get.lazyPut(() => GetBookingsUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => AddBookingUseCase(Get.find()), fenix: true);

    // Controllers
    Get.lazyPut(() => BookingController(Get.find(), Get.find()), fenix: true);
  }
}
