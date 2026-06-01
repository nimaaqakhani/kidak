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
    
    // ۱. مدیریت اتصال و گوش دادن به استریم
    on<ConnectGadgetEvent>((event, emit) async {
      emit(TemperatureConnecting());
      try {
        // ابتدا متصل می‌شویم
        await connectUseCase(event.device);
        emit(TemperatureConnected());
        
        // اشتراک قبلی را لغو می‌کنیم تا داده‌ها تکراری نشوند
        await _tempSubscription?.cancel();
        
        // شروع گوش دادن زنده به گجت
        _tempSubscription = getStreamUseCase().listen(
          (tempEntity) {
            // هر بار که گجت دیتا بفرستد، این رویداد فایر می‌شود
            add(TemperatureUpdatedEvent(tempEntity.celsius, tempEntity.rawBytes));
          },
          onError: (error) {
            // در صورت قطع شدن یا خطای استریم
            print("Stream error: $error");
          }
        );
      } catch (e) {
        emit(TemperatureError("خطا در اتصال: ${e.toString()}"));
      }
    });

    // ۲. مدیریت بروزرسانی دما (اینجا دیتا دقیقاً روی صفحه می‌نشیند)
    on<TemperatureUpdatedEvent>((event, emit) {
      emit(TemperatureReading(
        currentTemp: event.temperature, 
        rawBytes: event.rawBytes,
      ));
    });

    // ۳. مدیریت قطع اتصال
    on<DisconnectGadgetEvent>((event, emit) async {
      // ابتدا استریم را می‌بندیم تا دیتای جدیدی نیاید
      await _tempSubscription?.cancel();
      _tempSubscription = null;
      
      try {
        await disconnectUseCase();
      } catch (e) {
        // مدیریت خطای خاموش بودن بلوتوث هنگام قطع اتصال
        print("Disconnect error: $e");
      }
      // بازگشت به صفحه اسکن
      emit(TemperatureInitial());
    });
  }

  @override
  Future<void> close() async {
    // هنگام بسته شدن کامل اپلیکیشن یا خروج از صفحه
    await _tempSubscription?.cancel();
    try {
      await disconnectUseCase();
    } catch (_) {}
    return super.close();
  }
}