import 'package:intl/intl.dart';

/// Cached [DateFormat] instances to avoid repeated locale resolution
/// and pattern parsing on every build/paint frame.
class AppDateFormats {
  AppDateFormats._();

  /// `1:30 PM`
  static final hmma = DateFormat('h:mm a');

  /// `1PM` (no space)
  static final ha = DateFormat('ha');

  /// `1 PM` (with space)
  static final hSpaceA = DateFormat('h a');

  /// `Jan 5`
  static final mmmD = DateFormat('MMM d');

  /// `Monday`
  static final eeee = DateFormat('EEEE');

  /// `Jan 5, 1:30 PM`
  static final mmmDhmma = DateFormat('MMM d, h:mm a');

  /// `1:30PM` (no space)
  static final hmmaPeriod = DateFormat('h:mma');
}
