import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies(String environment) async {
  await getIt.init(environment: environment);
}

abstract class Environment {
  static const dev = 'dev';
  static const staging = 'staging';
  static const prod = 'prod';
}
