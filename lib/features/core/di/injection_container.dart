import 'package:flutter_application_1/features/temperature/data/datasources/bluetooth_remote_data_source.dart';
import 'package:flutter_application_1/features/temperature/data/repositories/temperature_repository_impl.dart'
    hide BluetoothRemoteDataSource, BluetoothRemoteDataSourceImpl;
import 'package:flutter_application_1/features/temperature/domain/repositories/temperature_repository.dart';
import 'package:flutter_application_1/features/temperature/domain/usecases/temperature_usecases.dart';
import 'package:flutter_application_1/features/temperature/presentation/bloc/temperature_bloc.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void init() {
  // Bloc
  sl.registerFactory(
    () => TemperatureBloc(
      connectUseCase: sl(),
      getStreamUseCase: sl(),
      disconnectUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => ConnectToDeviceUseCase(sl()));
  sl.registerLazySingleton(() => GetTemperatureStreamUseCase(sl()));
  sl.registerLazySingleton(() => DisconnectDeviceUseCase(sl()));

  // Repository
  sl.registerLazySingleton<TemperatureRepository>(
    () => TemperatureRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<BluetoothRemoteDataSource>(
    () => BluetoothRemoteDataSourceImpl(),
  );
}
