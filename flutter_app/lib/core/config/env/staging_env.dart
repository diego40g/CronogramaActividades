import 'package:injectable/injectable.dart';

import '../../di/injection.dart' as di;
import 'env.dart';

@LazySingleton(as: Env, env: [di.Environment.staging])
class StagingEnv implements Env {
  @override
  String get name => 'staging';

  @override
  bool get isProduction => false;

  @override
  bool get enableLogging => true;

  @override
  bool get useFirebaseEmulator => false;

  @override
  String get firestoreEmulatorHost => '';

  @override
  int get firestoreEmulatorPort => 0;

  @override
  String get authEmulatorHost => '';

  @override
  int get authEmulatorPort => 0;
}
