import 'package:get/get.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/entities/pet_booking.dart';
import '../../domain/usecases/add_booking_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';

enum ViewState { idle, loading, success, error }

class BookingController extends GetxController {
  final GetBookingsUseCase _getBookings;
  final AddBookingUseCase _addBooking;

  BookingController(this._getBookings, this._addBooking);

  final RxList<PetBooking> bookings = <PetBooking>[].obs;
  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoading => state.value == ViewState.loading;

  List<PetBooking> get historicalBookings =>
      bookings.where((b) => BookingStatus.finished.contains(b.status)).toList();

  List<PetBooking> get upcomingBookings =>
      bookings.where((b) => !BookingStatus.finished.contains(b.status)).toList();

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    state.value = ViewState.loading;
    try {
      bookings.value = await _getBookings();
      state.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
    }
  }

  Future<PetBooking> createBooking(PetBooking booking) async {
    state.value = ViewState.loading;
    try {
      final created = await _addBooking(booking);
      bookings.add(created);
      state.value = ViewState.success;
      return created;
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
      rethrow;
    }
  }
}
