import '../entities/pet_booking.dart';

abstract interface class BookingRepository {
  Future<List<PetBooking>> getBookings();
  Future<List<PetBooking>> getActiveBookings();
  Future<PetBooking> addBooking(PetBooking booking);
}
