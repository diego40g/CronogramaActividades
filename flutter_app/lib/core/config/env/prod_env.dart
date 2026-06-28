import 'package:injectable/injectable.dart';

import '../../di/injection.dart' as di;
import 'env.dart';

@LazySingleton(as: Env, env: [di.Environment.prod])
class ProdEnv implements Env {
  @override
  String get name => 'production';

  @override
  bool get isProduction => true;

  @override
  bool get enableLogging => false;

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
