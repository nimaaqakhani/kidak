import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/temperature/presentation/bloc/temperature_bloc.dart';
import 'package:flutter_application_1/features/temperature/presentation/bloc/temperature_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class TemperatureLoadingView extends StatelessWidget {
  const TemperatureLoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class TemperatureErrorView extends StatelessWidget {
  final String message;

  const TemperatureErrorView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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