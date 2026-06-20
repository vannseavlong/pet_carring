import 'package:get/get.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/entities/pet_booking.dart';
import '../../domain/usecases/add_booking_usecase.dart';
import '../../domain/usecases/get_active_bookings_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';

enum ViewState { idle, loading, success, error }

class BookingController extends GetxController {
  final GetBookingsUseCase _getBookings;
  final AddBookingUseCase _addBooking;
  final GetActiveBookingsUseCase _getActiveBookings;

  BookingController(
    this._getBookings,
    this._addBooking,
    this._getActiveBookings,
  );

  final RxList<PetBooking> bookings = <PetBooking>[].obs;
  final Rx<ViewState> state = ViewState.idle.obs;
  final RxString errorMessage = ''.obs;

  final RxList<PetBooking> activeStays = <PetBooking>[].obs;
  final Rx<ViewState> activeState = ViewState.idle.obs;

  bool get isLoading => state.value == ViewState.loading;
  bool get isLoadingActiveStays => activeState.value == ViewState.loading;

  List<PetBooking> get historicalBookings =>
      bookings.where((b) => BookingStatus.finished.contains(b.status)).toList();

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
    fetchActiveStays();
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

  Future<void> fetchActiveStays() async {
    activeState.value = ViewState.loading;
    try {
      activeStays.value = await _getActiveBookings();
      activeState.value = ViewState.success;
    } catch (e) {
      errorMessage.value = e.toString();
      activeState.value = ViewState.error;
    }
  }

  Future<void> createBooking(PetBooking booking) async {
    state.value = ViewState.loading;
    try {
      final created = await _addBooking(booking);
      bookings.add(created);
      state.value = ViewState.success;
      fetchActiveStays();
    } catch (e) {
      errorMessage.value = e.toString();
      state.value = ViewState.error;
      rethrow;
    }
  }
}
