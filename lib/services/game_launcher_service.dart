import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

class GameLauncherService {
  static const packageName = 'com.robtopx.geometryjump';
  static const _channel = MethodChannel('com.neonlauncher.geode_mod_manager/app');

  Future<bool> isGameInstalled() async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'isAppInstalled',
        {'packageName': packageName},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> launchGame() async {
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName,
      flags: <int>[268435456],
    );
    await intent.launch();
  }
}
