import '../../core/errors/app_exception.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/entities/pet_booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/local/booking_local_datasource.dart';
import '../datasources/remote/booking_remote_datasource.dart';
import '../models/pet_booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;
  final BookingLocalDataSource _local;

  BookingRepositoryImpl(this._remote, this._local);

  @override
  Future<List<PetBooking>> getBookings() async {
    try {
      final bookings = await _remote.getBookings();
      await _local.cacheBookings(bookings);
      return bookings;
    } on AppException {
      // Fall back to local cache when offline or API unavailable.
      return _local.getCachedBookings();
    }
  }

  @override
  Future<List<PetBooking>> getActiveBookings() async {
    try {
      return await _remote.getActiveBookings();
    } on AppException {
      final cached = await _local.getCachedBookings();
      return cached
          .where((b) =>
              b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.active)
          .toList();
    }
  }

  @override
  Future<PetBooking> addBooking(PetBooking booking) {
    return _remote.addBooking(PetBookingModel.fromEntity(booking));
  }
}
