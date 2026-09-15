import 'package:get_it/get_it.dart';

import 'map_resources.dart';


final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await _registerMapResources();
}

Future<void> _registerMapResources() async {
  final MapResources mapResources = MapResources();
  await mapResources.preload();
  getIt.registerSingleton<MapResources>(mapResources);
}
