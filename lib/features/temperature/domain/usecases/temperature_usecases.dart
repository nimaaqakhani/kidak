import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../entities/temperature_entity.dart';
import '../repositories/temperature_repository.dart';

class ConnectToDeviceUseCase {
  final TemperatureRepository repository;
  ConnectToDeviceUseCase(this.repository);

  Future<void> call(BluetoothDevice device) {
    return repository.connectAndDiscover(device);
  }
}

class GetTemperatureStreamUseCase {
  final TemperatureRepository repository;
  GetTemperatureStreamUseCase(this.repository);

  Stream<TemperatureEntity> call() {
    return repository.getTemperatureStream();
  }
}

class DisconnectDeviceUseCase {
  final TemperatureRepository repository;
  DisconnectDeviceUseCase(this.repository);

  Future<void> call() {
    return repository.disconnect();
  }
}