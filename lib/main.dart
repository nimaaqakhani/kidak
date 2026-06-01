import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/core/di/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/temperature/presentation/bloc/temperature_bloc.dart';
import 'features/temperature/presentation/pages/temperature_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  di.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth Temperature',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => di.sl<TemperatureBloc>(),
        child: TemperatureScreen(),
      ),
    );
  }
}