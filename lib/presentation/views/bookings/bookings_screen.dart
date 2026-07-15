import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/booking_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/booking_card.dart';
import '../booking/pet_detail_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _segment = 0; // 0 = Upcoming, 1 = Past

  BookingController get _bookings => Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _SegmentedControl(
              value: _segment,
              labels: const ['Upcoming', 'Past'],
              onChanged: (i) => setState(() => _segment = i),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_bookings.isLoading && _bookings.bookings.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.sageMid),
                );
              }
              final list = _segment == 0
                  ? _bookings.upcomingBookings
                  : _bookings.historicalBookings;

              if (list.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _bookings.fetchBookings,
                  child: ListView(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _segment == 0 ? '🐾' : '📋',
                                style: const TextStyle(fontSize: 48),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                _segment == 0
                                    ? 'No upcoming bookings'
                                    : 'No past bookings',
                                style: AppTypography.sectionHeader,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _segment == 0
                                    ? 'Book a shop from Browse to see it here'
                                    : 'Completed stays will appear here',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.mist,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: _bookings.fetchBookings,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final booking = list[index];
                    return BookingCard(
                      booking: booking,
                      onTap: () => Get.to(() => PetDetailScreen(booking: booking)),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final int value;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({
    required this.value,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.blushSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: value == i ? AppColors.sageDeep : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: AppTypography.bodyMedium.copyWith(
                      color: value == i ? Colors.white : AppColors.sageMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
