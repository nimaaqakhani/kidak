class TemperatureEntity {
  final double celsius;
  final List<int> rawBytes; // بایت‌های خام رو هم نگه می‌داریم تا در UI برای دیباگ نشون بدیم

  TemperatureEntity({
    required this.celsius,
    required this.rawBytes,
  });
}