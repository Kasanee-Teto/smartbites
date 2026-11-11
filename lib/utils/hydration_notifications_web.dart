import 'dart:js_interop';

@JS('smartBitesHydration.supported')
external JSBoolean get _supported;

@JS('smartBitesHydration.requestPermission')
external JSPromise<JSString> _requestPermission();

@JS('smartBitesHydration.prepareSound')
external void prepareDrinkSound();

@JS('smartBitesHydration.playSound')
external void _playSound(JSBoolean alarm);

@JS('smartBitesHydration.notify')
external void showDrinkNotification();

@JS('smartBitesHydration.clear')
external void clearDrinkNotification();

@JS('smartBitesHydration.listen')
external JSFunction _listen(JSFunction callback);

bool get supportsBrowserReminders => _supported.toDart;

Future<String> requestDrinkNotification() async =>
    (await _requestPermission().toDart).toDart;

void playDrinkSound({required bool alarm}) => _playSound(alarm.toJS);

void Function() listenForDrinkSnooze(void Function(int) onSnooze) {
  final unsubscribe = _listen(
    ((JSNumber minutes) {
      onSnooze(minutes.toDartInt);
    }).toJS,
  );
  void stop() {
    unsubscribe.callAsFunction();
  }

  return stop;
}
