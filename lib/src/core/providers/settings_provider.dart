import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, bool>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<bool> {
  static const _key = 'show_captions';
  late SharedPreferences _prefs;

  @override
  bool build() {
    _init();
    return true;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool(_key) ?? true;
  }

  Future<void> toggleCaptions() async {
    state = !state;
    await _prefs.setBool(_key, state);
  }
}
