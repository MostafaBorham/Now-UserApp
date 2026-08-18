import 'package:get_it/get_it.dart';

import 'map_resources.dart';


/// App-wide service locator. Resolve shared, app-lifetime dependencies through
/// this (e.g. `getIt<MapResources>()`).
final GetIt getIt = GetIt.instance;

/// Wires up dependency injection. Called from `main` before `runApp`, so any
/// resource that must be ready before the first frame is loaded here.
Future<void> setupServiceLocator() async {
  await _registerMapResources();
}

/// Registers the map's immutable resources as one app-lifetime instance, with
/// the size-independent pieces (style JSON + parsed marker vector) preloaded so
/// the first map screen never reads the asset or parses the SVG.
Future<void> _registerMapResources() async {
  final MapResources mapResources = MapResources();
  await mapResources.preload();
  getIt.registerSingleton<MapResources>(mapResources);
}
