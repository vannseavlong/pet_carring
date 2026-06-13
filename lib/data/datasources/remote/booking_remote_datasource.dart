import 'package:dio/dio.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/pet_booking_model.dart';

abstract interface class BookingRemoteDataSource {
  Future<List<PetBookingModel>> getBookings();
  Future<PetBookingModel> addBooking(PetBookingModel booking);
  Future<void> deleteBooking(String id);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient _apiClient;

  BookingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<PetBookingModel>> getBookings() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.bookings);
      final data = response.data as List<dynamic>;
      return data
          .map((e) => PetBookingModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<PetBookingModel> addBooking(PetBookingModel booking) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.bookings,
        data: booking.toJson(),
      );
      return PetBookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteBooking(String id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.bookingById(id));
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
