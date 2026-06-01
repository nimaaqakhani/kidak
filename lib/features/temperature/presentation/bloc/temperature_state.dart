abstract class TemperatureState {}

class TemperatureInitial extends TemperatureState {}

class TemperatureConnecting extends TemperatureState {}

class TemperatureConnected extends TemperatureState {}

class TemperatureReading extends TemperatureState {
  final double currentTemp;
  final List<int> rawBytes;
  TemperatureReading({required this.currentTemp, required this.rawBytes});
}

class TemperatureError extends TemperatureState {
  final String message;
  TemperatureError(this.message);
}