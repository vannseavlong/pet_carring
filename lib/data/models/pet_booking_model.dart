import '../../domain/entities/pet_booking.dart';

class PetBookingModel extends PetBooking {
  const PetBookingModel({
    required super.id,
    required super.petName,
    required super.petType,
    required super.ownerName,
    required super.checkInDate,
    required super.checkOutDate,
    required super.dailyRate,
    super.status,
  });

  factory PetBookingModel.fromJson(Map<String, dynamic> json) {
    return PetBookingModel(
      id: json['id'] as String,
      petName: json['pet_name'] as String,
      petType: json['pet_type'] as String,
      ownerName: json['owner_name'] as String,
      checkInDate: DateTime.parse(json['check_in_date'] as String),
      checkOutDate: DateTime.parse(json['check_out_date'] as String),
      dailyRate: (json['daily_rate'] as num).toDouble(),
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pet_name': petName,
        'pet_type': petType,
        'owner_name': ownerName,
        'check_in_date': checkInDate.toIso8601String().split('T').first,
        'check_out_date': checkOutDate.toIso8601String().split('T').first,
        'daily_rate': dailyRate,
        'status': status,
      };

  factory PetBookingModel.fromEntity(PetBooking entity) {
    return PetBookingModel(
      id: entity.id,
      petName: entity.petName,
      petType: entity.petType,
      ownerName: entity.ownerName,
      checkInDate: entity.checkInDate,
      checkOutDate: entity.checkOutDate,
      dailyRate: entity.dailyRate,
      status: entity.status,
    );
  }
}
