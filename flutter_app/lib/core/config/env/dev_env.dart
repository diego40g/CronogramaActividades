import 'package:injectable/injectable.dart';

import '../../di/injection.dart' as di;
import 'env.dart';

@LazySingleton(as: Env, env: [di.Environment.dev])
class DevEnv implements Env {
  @override
  String get name => 'development';

  @override
  bool get isProduction => false;

  @override
  bool get enableLogging => true;

  @override
  bool get useFirebaseEmulator => true;

  @override
  String get firestoreEmulatorHost => 'localhost';

  @override
  int get firestoreEmulatorPort => 8080;

  @override
  String get authEmulatorHost => 'localhost';

  @override
  int get authEmulatorPort => 9099;
}
