import '../entities/pet_booking.dart';
import '../repositories/booking_repository.dart';

class GetActiveBookingsUseCase {
  final BookingRepository _repository;

  GetActiveBookingsUseCase(this._repository);

  Future<List<PetBooking>> call() => _repository.getActiveBookings();
}
