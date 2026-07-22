import '../../domain/entities/pet_booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/remote/booking_remote_datasource.dart';
import '../models/pet_booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _remote;

  BookingRepositoryImpl(this._remote);

  @override
  Future<List<PetBooking>> getBookings() {
    return _remote.getBookings();
  }

  @override
  Future<PetBooking> addBooking(PetBooking booking) {
    return _remote.addBooking(PetBookingModel.fromEntity(booking));
  }
}
