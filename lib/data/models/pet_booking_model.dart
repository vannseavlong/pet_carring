import '../../domain/entities/pet_booking.dart';

class PetBookingModel extends PetBooking {
  const PetBookingModel({
    required super.id,
    required super.petName,
    required super.petType,
    required super.serviceId,
    required super.serviceName,
    required super.checkInDate,
    required super.checkOutDate,
    required super.dailyRate,
    super.status,
    super.notes,
    super.shopId,
  });

  factory PetBookingModel.fromJson(Map<String, dynamic> json) {
    return PetBookingModel(
      id: json['booking_id'] as String,
      petName: json['pet_name'] as String,
      petType: json['pet_type'] as String,
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String? ?? '',
      checkInDate: DateTime.parse(json['start_date'] as String),
      checkOutDate: DateTime.parse(json['end_date'] as String),
      dailyRate: (json['daily_rate'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      shopId: json['shop_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'pet_name': petName,
        'pet_type': petType,
        // Every booking in this app now originates from a shop's catalog
        // (ShopDetailScreen), never the legacy flat `services` table — so
        // this always sends `item_id`, never `service_id`. The backend
        // derives `shop_id` server-side from the item; it's not an
        // accepted field on create (see FLUTTER_GUIDE.md § Bookings).
        'item_id': serviceId,
        'start_date': checkInDate.toIso8601String().split('T').first,
        'end_date': checkOutDate.toIso8601String().split('T').first,
        'daily_rate': dailyRate,
        if (notes != null) 'notes': notes,
      };

  factory PetBookingModel.fromEntity(PetBooking entity) {
    return PetBookingModel(
      id: entity.id,
      petName: entity.petName,
      petType: entity.petType,
      serviceId: entity.serviceId,
      serviceName: entity.serviceName,
      checkInDate: entity.checkInDate,
      checkOutDate: entity.checkOutDate,
      dailyRate: entity.dailyRate,
      status: entity.status,
      notes: entity.notes,
      shopId: entity.shopId,
    );
  }
}
