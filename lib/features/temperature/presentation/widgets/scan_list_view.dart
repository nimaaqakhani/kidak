import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanListView extends StatelessWidget {
  final List<ScanResult> scanResults;
  final bool isScanning;
  final VoidCallback onStartScan;
  final VoidCallback onStopScan;
  final Function(BluetoothDevice) onConnect;

  const ScanListView({
    Key? key,
    required this.scanResults,
    required this.isScanning,
    required this.onStartScan,
    required this.onStopScan,
    required this.onConnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scanResults.isEmpty && !isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bluetooth_searching, size: 100, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 30),
            const Text(
              "هنوز گجتی پیدا نشده است",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 55,
              width: 220,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 10,
                  shadowColor: Colors.tealAccent.withOpacity(0.4),
                ),
                icon: const Icon(Icons.search, size: 28),
                label: const Text(
                  "شروع جستجو",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: onStartScan,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isScanning ? "در حال جستجو..." : "پایان جستجو",
                style: TextStyle(
                  color: isScanning ? Colors.tealAccent : Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: isScanning ? Colors.redAccent : Colors.tealAccent,
                ),
                icon: Icon(isScanning ? Icons.stop_circle_outlined : Icons.refresh),
                label: Text(isScanning ? "توقف اسکن" : "اسکن مجدد"),
                onPressed: isScanning ? onStopScan : onStartScan,
              )
            ],
          ),
        ),
        if (isScanning && scanResults.isEmpty)
          const Expanded(
            child: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final device = scanResults[index].device;
                return Card(
                  color: Colors.white.withOpacity(0.05),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.tealAccent,
                      child: Icon(Icons.bluetooth, color: Color(0xFF0F172A)),
                    ),
                    title: Text(
                      device.platformName.isNotEmpty ? device.platformName : "دستگاه ناشناس",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      device.remoteId.toString(),
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('اتصال', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => onConnect(device),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}