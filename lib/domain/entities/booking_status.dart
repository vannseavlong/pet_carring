abstract final class BookingStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const active = 'active';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const finished = [completed, cancelled];
}
