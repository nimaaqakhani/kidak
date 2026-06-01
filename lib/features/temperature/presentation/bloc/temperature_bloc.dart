import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/temperature_usecases.dart';
import 'temperature_event.dart';
import 'temperature_state.dart';

class TemperatureBloc extends Bloc<TemperatureEvent, TemperatureState> {
  final ConnectToDeviceUseCase connectUseCase;
  final GetTemperatureStreamUseCase getStreamUseCase;
  final DisconnectDeviceUseCase disconnectUseCase;
  
  StreamSubscription? _tempSubscription;

  TemperatureBloc({
    required this.connectUseCase,
    required this.getStreamUseCase,
    required this.disconnectUseCase,
  }) : super(TemperatureInitial()) {
    
    on<ConnectGadgetEvent>((event, emit) async {
      emit(TemperatureConnecting());
      try {
        await connectUseCase(event.device);
        emit(TemperatureConnected());
        
        await _tempSubscription?.cancel();
                _tempSubscription = getStreamUseCase().listen(
          (tempEntity) {
            add(TemperatureUpdatedEvent(tempEntity.celsius, tempEntity.rawBytes));
          },
          onError: (error) {
          }
        );
      } catch (e) {
        emit(TemperatureError("خطا در اتصال: ${e.toString()}"));
      }
    });

    on<TemperatureUpdatedEvent>((event, emit) {
      emit(TemperatureReading(
        currentTemp: event.temperature, 
        rawBytes: event.rawBytes,
      ));
    });

    on<DisconnectGadgetEvent>((event, emit) async {
      await _tempSubscription?.cancel();
      _tempSubscription = null;
      
      try {
        await disconnectUseCase();
      } catch (e) {
        print("Disconnect error: $e");
      }
      emit(TemperatureInitial());
    });
  }

  @override
  Future<void> close() async {
    await _tempSubscription?.cancel();
    try {
      await disconnectUseCase();
    } catch (_) {}
    return super.close();
  }
}