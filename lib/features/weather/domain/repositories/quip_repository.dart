import '../entities/weather.dart';

abstract class QuipRepository {
  Future<String> getQuip({required Weather weather, required String cityName});
}
