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
      // بررسی ایمنی برای لیست‌های خالی
      if (bytes.isEmpty) {
        return TemperatureEntity(celsius: 0.0, rawBytes: []);
      }

      // لاگ جهت بررسی در محیط توسعه (می‌توانید در نسخه نهایی کامنت کنید)
      print("DEBUG: Raw bytes received: $bytes");

      double actualTemp = 0.0;

      try {
        if (bytes.length >= 2) {
          // فرمول قطعی استخراج دما (Little Endian)
          // بایت اول + (بایت دوم * ۲۵۶)
          int rawValue = bytes[0] + (bytes[1] * 256);
          
          // تقسیم بر ۱۰ برای رسیدن به عدد اعشاری درست (مثلا ۲۸۲ -> ۲۸.۲)
          actualTemp = rawValue / 10.0;
        } else {
          // در صورتی که فقط یک بایت دریافت شد
          actualTemp = bytes[0].toDouble();
        }
      } catch (e) {
        // مدیریت خطاهای احتمالی در تبدیل
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