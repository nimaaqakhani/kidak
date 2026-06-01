import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/temperature/presentation/widgets/dashboard_view.dart';
import 'package:flutter_application_1/features/temperature/presentation/widgets/scan_list_view.dart';
import 'package:flutter_application_1/features/temperature/presentation/widgets/status_views.dart';
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
          actions: const [],
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
                return const TemperatureLoadingView();
              } else if (state is TemperatureError) {
                return TemperatureErrorView(message: state.message);
              } else if (state is TemperatureConnected || state is TemperatureReading) {
                final double temp = (state is TemperatureReading) ? state.currentTemp : 0.0;
                return DashboardView(temp: temp);
              }

              return ScanListView(
                scanResults: scanResults,
                isScanning: isScanning,
                onStartScan: startScan,
                onStopScan: () => FlutterBluePlus.stopScan(),
                onConnect: (device) {
                  FlutterBluePlus.stopScan();
                  context.read<TemperatureBloc>().add(ConnectGadgetEvent(device));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}