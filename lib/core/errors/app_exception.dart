class AppException implements Exception {
  final String message;
  final String? sassyMessage;

  const AppException(this.message, {this.sassyMessage});

  @override
  String toString() => sassyMessage ?? message;
}

class LocationException extends AppException {
  const LocationException(super.message, {super.sassyMessage});
}

class WeatherException extends AppException {
  const WeatherException(super.message, {super.sassyMessage});
}

class QuipException extends AppException {
  const QuipException(super.message, {super.sassyMessage});
}
