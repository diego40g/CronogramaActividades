abstract class Env {
  String get name;
  bool get isProduction;
  bool get enableLogging;
  bool get useFirebaseEmulator;
  String get firestoreEmulatorHost;
  int get firestoreEmulatorPort;
  String get authEmulatorHost;
  int get authEmulatorPort;
}
