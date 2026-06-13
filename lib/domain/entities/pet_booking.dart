import 'package:equatable/equatable.dart';

class PetBooking extends Equatable {
  final String id;
  final String petName;
  final String petType;
  final String ownerName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double dailyRate;
  final String status;

  const PetBooking({
    required this.id,
    required this.petName,
    required this.petType,
    required this.ownerName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.dailyRate,
    this.status = 'active',
  });

  int get totalDays {
    final days = checkOutDate.difference(checkInDate).inDays;
    return days == 0 ? 1 : days;
  }

  double get totalCharge => totalDays * dailyRate;

  PetBooking copyWith({
    String? id,
    String? petName,
    String? petType,
    String? ownerName,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? dailyRate,
    String? status,
  }) {
    return PetBooking(
      id: id ?? this.id,
      petName: petName ?? this.petName,
      petType: petType ?? this.petType,
      ownerName: ownerName ?? this.ownerName,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      dailyRate: dailyRate ?? this.dailyRate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, petName, petType, ownerName, checkInDate, checkOutDate, dailyRate, status];
}
