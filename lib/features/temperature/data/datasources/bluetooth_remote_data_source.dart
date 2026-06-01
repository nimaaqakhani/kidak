import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BluetoothRemoteDataSource {
  Future<void> connectAndDiscover(BluetoothDevice device);
  Stream<List<int>> getRawTemperatureData();
  Future<void> disconnectDevice();
}

class BluetoothRemoteDataSourceImpl implements BluetoothRemoteDataSource {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _tempCharacteristic;

  @override
  Future<void> connectAndDiscover(BluetoothDevice device) async {
    _device = device;
        await _device!.connect(
      autoConnect: false,
    );
    
    List<BluetoothService> services = await _device!.discoverServices();
    
    for (var service in services) {
      for (var char in service.characteristics) {
        if (char.properties.notify) {
          _tempCharacteristic = char;
          await char.setNotifyValue(true);
          print('✅ Target Characteristic Found: ${char.uuid}');
          return; 
        }
      }
    }
    throw Exception("هیچ مشخصه قابل اشتراکی (Notify) در این گجت یافت نشد.");
  }

  @override
  Stream<List<int>> getRawTemperatureData() {
    if (_tempCharacteristic == null) {
      throw Exception("ابتدا باید به دستگاه متصل شوید.");
    }
    return _tempCharacteristic!.lastValueStream;
  }

  @override
  Future<void> disconnectDevice() async {
    if (_tempCharacteristic != null) {
      try {
        await _tempCharacteristic!.setNotifyValue(false);
      } catch (e) {
        print("Error disabling notify: $e");
      }
    }
    
    if (_device != null) {
      await _device!.disconnect();
    }
    
    _tempCharacteristic = null;
    _device = null;
  }
}