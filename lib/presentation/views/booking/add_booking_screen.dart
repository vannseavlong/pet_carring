import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/pet_types.dart';
import '../../../domain/entities/pet_booking.dart';
import '../../../domain/entities/service.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/service_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

// The form only surfaces the 4 types from the approved mockup; "other" still
// exists in PetTypes for displaying bookings created with an unlisted type.
final _formPetTypes = PetTypes.all.where((t) => t.value != 'other').toList();

class AddBookingScreen extends StatefulWidget {
  final Service? initialService;

  const AddBookingScreen({super.key, this.initialService});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rateCtrl = TextEditingController(text: '25.00');
  final _notesCtrl = TextEditingController();

  String _petType = _formPetTypes.first.value;
  Service? _selectedService;
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 4));

  BookingController get _bookings => Get.find<BookingController>();
  ServiceController get _services => Get.find<ServiceController>();

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
    );
    if (range != null) {
      setState(() {
        _checkIn = range.start;
        _checkOut = range.end;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final service = _selectedService;
    if (service == null) return;

    final booking = PetBooking(
      id: '',
      petName: _nameCtrl.text.trim(),
      petType: _petType,
      serviceId: service.serviceId,
      serviceName: service.name,
      checkInDate: _checkIn,
      checkOutDate: _checkOut,
      dailyRate: double.parse(_rateCtrl.text),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    try {
      await _bookings.createBooking(booking);
      Get.back();
    } catch (_) {
      Get.snackbar(
        'Booking failed',
        _bookings.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: AppColors.ink,
        margin: const EdgeInsets.all(AppSpacing.md),
        borderRadius: 12,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWarm,
      appBar: AppBar(
        backgroundColor: AppColors.creamWarm,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: _BackButton(onTap: Get.back),
        ),
        centerTitle: true,
        title: Text(
          'New Booking',
          style: AppTypography.display.copyWith(fontSize: 26),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Service'),
                Obx(() {
                  final services = _services.services;
                  if (_services.isLoading && services.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: LinearProgressIndicator(color: AppColors.sageMid),
                    );
                  }
                  if (_selectedService != null &&
                      !services.contains(_selectedService)) {
                    _selectedService = null;
                  }
                  return DropdownButtonFormField<Service>(
                    initialValue: _selectedService,
                    decoration: _inputDeco('Select a service'),
                    items: services
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              '${s.name} · \$${s.priceFrom.toStringAsFixed(0)}',
                              style: AppTypography.bodyLarge,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (s) => setState(() => _selectedService = s),
                    validator: (v) => v != null ? null : 'Select a service',
                  );
                }),
                const SizedBox(height: AppSpacing.lg),

                _label('Pet Name'),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDeco('e.g. Buddy'),
                  validator: (v) => v != null && v.trim().isNotEmpty
                      ? null
                      : 'Enter a pet name',
                ),
                const SizedBox(height: AppSpacing.lg),

                _label('Pet Type'),
                Row(
                  children: [
                    for (final type in _formPetTypes) ...[
                      Expanded(
                        child: _PetTypeOption(
                          type: type,
                          selected: _petType == type.value,
                          onTap: () => setState(() => _petType = type.value),
                        ),
                      ),
                      if (type != _formPetTypes.last)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                _label('Stay Duration'),
                _DateRangeField(
                  checkIn: _checkIn,
                  checkOut: _checkOut,
                  onTap: _pickDateRange,
                ),
                const SizedBox(height: AppSpacing.lg),

                _label('Daily Rate'),
                TextFormField(
                  controller: _rateCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDeco('0.00').copyWith(prefixText: r'$  '),
                  validator: (v) {
                    final value = double.tryParse(v ?? '');
                    return value != null && value > 0
                        ? null
                        : 'Enter a valid rate';
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                _label('Notes (optional)'),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 4,
                  decoration: _inputDeco('Any special care instructions...'),
                ),
                const SizedBox(height: AppSpacing.xl),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _bookings.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sageDeep,
                        disabledBackgroundColor: AppColors.mist,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _bookings.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Confirm Booking',
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: AppTypography.micro.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.mist),
    filled: true,
    fillColor: AppColors.blushSoft,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.mist),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.mist.withValues(alpha: 0.6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.sageMid, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade300),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.blushSoft,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.chevron_left, color: AppColors.ink),
      ),
    );
  }
}

class _PetTypeOption extends StatelessWidget {
  final PetTypeOption type;
  final bool selected;
  final VoidCallback onTap;

  const _PetTypeOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.sageDeep : AppColors.blushSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.sageDeep : AppColors.mist,
          ),
        ),
        child: Column(
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              type.label,
              style: AppTypography.bodyMedium.copyWith(
                color: selected ? AppColors.creamWarm : AppColors.sageMid,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangeField extends StatelessWidget {
  final DateTime checkIn;
  final DateTime checkOut;
  final VoidCallback onTap;

  const _DateRangeField({
    required this.checkIn,
    required this.checkOut,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.blushSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mist),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.sageMid,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(_fmt(checkIn), style: AppTypography.dataMono),
            const Spacer(),
            const Icon(Icons.arrow_forward, size: 16, color: AppColors.mist),
            const Spacer(),
            Text(_fmt(checkOut), style: AppTypography.dataMono),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.mist,
            ),
          ],
        ),
      ),
    );
  }
}
