import '../entities/temperature_entity.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class TemperatureRepository {
  Future<void> connectAndDiscover(BluetoothDevice device); 
  
  Stream<TemperatureEntity> getTemperatureStream();
  Future<void> disconnect();
}