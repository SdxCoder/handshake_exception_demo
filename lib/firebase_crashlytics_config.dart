import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class FirebaseCrashlyticsConfiguration {
  @factoryMethod
  factory FirebaseCrashlyticsConfiguration.initialize() {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
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
    return const FirebaseCrashlyticsConfiguration._();
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
