import '../../models/pet_booking_model.dart';

abstract interface class BookingLocalDataSource {
  Future<List<PetBookingModel>> getCachedBookings();
  Future<void> cacheBookings(List<PetBookingModel> bookings);
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  // Seeded with dev mock data; cleared and replaced once API responds.
  final List<PetBookingModel> _cache = [
    PetBookingModel(
      id: '1',
      petName: 'Milo',
      petType: 'Dog',
      ownerName: 'Suntel',
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now().add(const Duration(days: 4)),
      dailyRate: 25.0,
    ),
    PetBookingModel(
      id: '2',
      petName: 'Luna',
      petType: 'Cat',
      ownerName: 'Alice',
      checkInDate: DateTime.now().subtract(const Duration(days: 10)),
      checkOutDate: DateTime.now().subtract(const Duration(days: 7)),
      dailyRate: 20.0,
      status: 'checked_out',
    ),
  ];

  @override
  Future<List<PetBookingModel>> getCachedBookings() async =>
      List.unmodifiable(_cache);

  @override
  Future<void> cacheBookings(List<PetBookingModel> bookings) async {
    _cache
      ..clear()
      ..addAll(bookings);
  }
}
