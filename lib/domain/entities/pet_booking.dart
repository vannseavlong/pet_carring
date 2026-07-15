import 'package:equatable/equatable.dart';
import 'booking_status.dart';

class PetBooking extends Equatable {
  final String id;
  final String petName;
  final String petType;
  final String serviceId;
  final String serviceName;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final double dailyRate;
  final String status;
  final String? notes;
  final String shopId;

  const PetBooking({
    required this.id,
    required this.petName,
    required this.petType,
    required this.serviceId,
    required this.serviceName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.dailyRate,
    this.status = BookingStatus.pending,
    this.notes,
    this.shopId = '',
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
    String? serviceId,
    String? serviceName,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? dailyRate,
    String? status,
    String? notes,
    String? shopId,
  }) {
    return PetBooking(
      id: id ?? this.id,
      petName: petName ?? this.petName,
      petType: petType ?? this.petType,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      dailyRate: dailyRate ?? this.dailyRate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      shopId: shopId ?? this.shopId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    petName,
    petType,
    serviceId,
    serviceName,
    checkInDate,
    checkOutDate,
    dailyRate,
    status,
    notes,
    shopId,
  ];
}
