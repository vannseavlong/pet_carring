import '../../../domain/entities/booking_status.dart';
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
      petType: 'dog',
      serviceId: 'svc_bath_grm',
      serviceName: 'Bath & Grooming',
      checkInDate: DateTime.now(),
      checkOutDate: DateTime.now().add(const Duration(days: 4)),
      dailyRate: 25.0,
      status: BookingStatus.active,
    ),
    PetBookingModel(
      id: '2',
      petName: 'Luna',
      petType: 'cat',
      serviceId: 'svc_haircut',
      serviceName: 'Haircut & Styling',
      checkInDate: DateTime.now().subtract(const Duration(days: 10)),
      checkOutDate: DateTime.now().subtract(const Duration(days: 7)),
      dailyRate: 20.0,
      status: BookingStatus.completed,
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
