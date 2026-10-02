import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';

class SoundManager {
  static final SoundManager instance = SoundManager._internal();
  SoundManager._internal();

  bool _soundEnabled = true;

  Future<void> init() async {}

  Future<void> playBackgroundMusic() async {}

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.beep(); } catch (_) {}
  }

  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.beep(); } catch (_) {}
  }

  Future<void> playWrong() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.playSysSound(
        AndroidSoundIDs.TONE_CDMA_ABBR_ALERT); } catch (_) {}
  }

  Future<void> playWin() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.beep(); } catch (_) {}
  }

  Future<void> playCollect() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.beep(); } catch (_) {}
  }

  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.beep(); } catch (_) {}
  }

  Future<void> playCountdown() async {
    if (!_soundEnabled) return;
    try { await FlutterBeep.beep(); } catch (_) {}
  }

  Future<void> stopBackgroundMusic() async {}

  bool get soundEnabled => _soundEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }
}