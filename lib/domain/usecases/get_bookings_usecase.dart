import '../entities/pet_booking.dart';
import '../repositories/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository _repository;

  GetBookingsUseCase(this._repository);

  Future<List<PetBooking>> call() => _repository.getBookings();
}
