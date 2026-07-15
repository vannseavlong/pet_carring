import '../entities/pet_booking.dart';

abstract interface class BookingRepository {
  Future<List<PetBooking>> getBookings();
  Future<PetBooking> addBooking(PetBooking booking);
}
