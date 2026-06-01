import '../../domain/entities/temperature_entity.dart';
import '../../domain/repositories/temperature_repository.dart';
import '../datasources/bluetooth_remote_data_source.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class TemperatureRepositoryImpl implements TemperatureRepository {
  final BluetoothRemoteDataSource remoteDataSource;

  TemperatureRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> connectAndDiscover(BluetoothDevice device) async {
    return await remoteDataSource.connectAndDiscover(device);
  }

  @override
  Stream<TemperatureEntity> getTemperatureStream() {
    return remoteDataSource.getRawTemperatureData().map((bytes) {
      if (bytes.isEmpty) {
        return TemperatureEntity(celsius: 0.0, rawBytes: []);
      }

      print("DEBUG: Raw bytes received: $bytes");

      double actualTemp = 0.0;

      try {
        if (bytes.length >= 2) {
          int rawValue = bytes[0] + (bytes[1] * 256);
                    actualTemp = rawValue / 10.0;
        } else {
          actualTemp = bytes[0].toDouble();
        }
      } catch (e) {
        print("Error parsing temperature: $e");
        actualTemp = 0.0;
      }

      return TemperatureEntity(
        celsius: actualTemp,
        rawBytes: bytes,
      );
    });
  }

  @override
  Future<void> disconnect() async {
    return await remoteDataSource.disconnectDevice();
  }
}