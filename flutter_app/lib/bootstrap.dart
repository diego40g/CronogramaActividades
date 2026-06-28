import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import 'core/config/env/env.dart';
import 'core/di/injection.dart';
import 'core/error/error_handler.dart';
import 'firebase_options.dart';

class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _logger.d('onCreate: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('${bloc.runtimeType} Event: $event');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.d('${bloc.runtimeType} Change: $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _logger.e(
      '${bloc.runtimeType} Error',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _logger.d('onClose: ${bloc.runtimeType}');
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required String environment,
}) async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure dependency injection
  await configureDependencies(environment);

  // Configure emulators if in dev mode
  final Env env = getIt<Env>();
  if (env.useFirebaseEmulator) {
    await _configureEmulators(env);
  }

  // Setup BLoC observer (debug only)
  if (kDebugMode && env.enableLogging) {
    Bloc.observer = AppBlocObserver();
  }

  // Setup global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    ErrorHandler.logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorHandler.logError(error, stack);
    return true;
  };

  // Run the app
  runApp(await builder());
}

Future<void> _configureEmulators(Env env) async {
  try {
    FirebaseFirestore.instance.useFirestoreEmulator(
      env.firestoreEmulatorHost,
      env.firestoreEmulatorPort,
    );
    await FirebaseAuth.instance.useAuthEmulator(
      env.authEmulatorHost,
      env.authEmulatorPort,
    );
    ErrorHandler.logInfo('Firebase emulators configured');
  } catch (e) {
    ErrorHandler.logWarning('Failed to configure emulators: $e');
  }
}
