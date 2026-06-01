import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class TemperatureEvent {}

class ConnectGadgetEvent extends TemperatureEvent {
  final BluetoothDevice device;
  ConnectGadgetEvent(this.device);
}

class TemperatureUpdatedEvent extends TemperatureEvent {
  final double temperature;
  final List<int> rawBytes;
  TemperatureUpdatedEvent(this.temperature, this.rawBytes);
}

class DisconnectGadgetEvent extends TemperatureEvent {}