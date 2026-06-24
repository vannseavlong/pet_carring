import '../entities/pet_booking.dart';
import '../repositories/booking_repository.dart';

class AddBookingUseCase {
  final BookingRepository _repository;

  AddBookingUseCase(this._repository);

  Future<PetBooking> call(PetBooking booking) => _repository.addBooking(booking);
}
