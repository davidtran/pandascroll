import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class AppSettings {
  final bool captions;
  final bool volume;

  const AppSettings({this.captions = true, this.volume = true});

  AppSettings copyWith({bool? captions, bool? volume}) {
    return AppSettings(
      captions: captions ?? this.captions,
      volume: volume ?? this.volume,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _captionKey = 'show_captions';
  static const _audioKey = 'toggle_audio';
  SharedPreferences? _prefs;

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      captions: _prefs?.getBool(_captionKey) ?? true,
      volume: _prefs?.getBool(_audioKey) ?? true,
    );
  }

  Future<void> toggleCaptions() async {
    state = state.copyWith(captions: !state.captions);
    await _prefs?.setBool(_captionKey, state.captions);
  }

  Future<void> toggleAudio() async {
    state = state.copyWith(volume: !state.volume);
    await _prefs?.setBool(_audioKey, state.volume);
  }
}
