import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseCrashlyticsConfiguration {
  static FirebaseCrashlyticsConfiguration? instance;

  factory FirebaseCrashlyticsConfiguration.initialize() {
    if (instance == null) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      Isolate.current.addErrorListener(
        RawReceivePort((pair) async {
          final List<dynamic> errorAndStacktrace = pair;
          await FirebaseCrashlytics.instance.recordError(
            errorAndStacktrace.first,
            errorAndStacktrace.last,
            fatal: true,
          );
        }).sendPort,
      );
      const enableIfNotInDevelopment = kReleaseMode;
      FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(enableIfNotInDevelopment);

      instance = const FirebaseCrashlyticsConfiguration._();
    }

    return instance!;
  }

  const FirebaseCrashlyticsConfiguration._();

  void log({String? title, String? description, String? data}) {
    FirebaseCrashlytics.instance.log('''
         Error Title: $title !\n
         Data: $data\n
         Description: $description,
      ''');
  }
}
