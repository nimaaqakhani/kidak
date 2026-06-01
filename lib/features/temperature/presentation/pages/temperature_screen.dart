import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../bloc/temperature_bloc.dart';
import '../bloc/temperature_event.dart';
import '../bloc/temperature_state.dart';

class TemperatureScreen extends StatefulWidget {
  @override
  _TemperatureScreenState createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) setState(() => scanResults = results);
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      if (mounted) setState(() => isScanning = scanning);
    });
  }

  Future<void> startScan() async {
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لطفاً ابتدا بلوتوث خود را روشن کنید!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primaryColor: Colors.tealAccent,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'داشبورد دماسنج',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          centerTitle: true,
          // دکمه جستجو در بالای صفحه با طراحی واضح‌تر و همراه با متن
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isScanning 
                      ? Colors.redAccent.withOpacity(0.15) 
                      : Colors.tealAccent.withOpacity(0.15),
                  foregroundColor: isScanning ? Colors.redAccent : Colors.tealAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isScanning ? Colors.redAccent : Colors.tealAccent,
                      width: 1.5,
                    ),
                  ),
                ),
                icon: Icon(isScanning ? Icons.stop_circle_outlined : Icons.radar),
                label: Text(
                  isScanning ? "توقف" : "جستجوی گجت",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: isScanning ? () => FlutterBluePlus.stopScan() : startScan,
              ),
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
          child: BlocBuilder<TemperatureBloc, TemperatureState>(
            builder: (context, state) {
              if (state is TemperatureConnecting) {
                return _buildLoadingState();
              } else if (state is TemperatureError) {
                return _buildErrorState(state.message);
              } else if (state is TemperatureConnected || state is TemperatureReading) {
                final double temp = (state is TemperatureReading) ? state.currentTemp : 0.0;
                return _buildDashboardState(context, temp);
              }

              return _buildScanList();
            },
          ),
        ),
      ),
    );
  }

  // --- ویجت‌های کمکی ---

  Widget _buildDashboardState(BuildContext context, double temp) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E293B),
              boxShadow: [
                BoxShadow(
                  color: Colors.tealAccent.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.tealAccent.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thermostat, color: Colors.tealAccent, size: 40),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temp.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        "°C",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "وضعیت: متصل",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.tealAccent.withOpacity(0.8),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.withOpacity(0.1),
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.link_off),
            label: const Text(
              "قطع اتصال دستگاه",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.read<TemperatureBloc>().add(DisconnectGadgetEvent()),
          )
        ],
      ),
    );
  }

  Widget _buildScanList() {
    // وقتی هنوز دستگاهی پیدا نشده، این صفحه نمایش داده می‌شود
    if (scanResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching, 
              size: 100, 
              color: isScanning ? Colors.tealAccent.withOpacity(0.8) : Colors.white.withOpacity(0.2)
            ),
            const SizedBox(height: 30),
            Text(
              isScanning ? "در حال جستجوی گجت‌های اطراف..." : "هنوز دستگاهی پیدا نشده است",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 40),
            
            // دکمه بزرگ و واضح وسط صفحه برای شروع (فقط وقتی اسکن متوقف است نمایش داده می‌شود)
            if (!isScanning)
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
                  onPressed: startScan,
                ),
              ),
              
            // نمایش لودینگ در صورت در حال اسکن بودن
            if (isScanning)
              const CircularProgressIndicator(color: Colors.tealAccent),
          ],
        ),
      );
    }

    // لیست دستگاه‌های پیدا شده
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
              onPressed: () {
                FlutterBluePlus.stopScan();
                context.read<TemperatureBloc>().add(ConnectGadgetEvent(device));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.tealAccent),
          const SizedBox(height: 24),
          Text(
            "در حال برقراری ارتباط امن...",
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.1),
                foregroundColor: Colors.white,
              ),
              onPressed: () => context.read<TemperatureBloc>().add(DisconnectGadgetEvent()),
              child: const Text("بازگشت"),
            )
          ],
        ),
      ),
    );
  }
}