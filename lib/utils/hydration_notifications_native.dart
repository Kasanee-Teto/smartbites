import 'dart:async';

import 'package:flutter/services.dart';

const supportsBrowserReminders = false;

Future<String> requestDrinkNotification() async => 'unsupported';

void prepareDrinkSound() {}

void playDrinkSound({required bool alarm}) {
  unawaited(SystemSound.play(SystemSoundType.alert));
}

void showDrinkNotification() {}

void clearDrinkNotification() {}

void Function() listenForDrinkSnooze(void Function(int) onSnooze) => () {};
