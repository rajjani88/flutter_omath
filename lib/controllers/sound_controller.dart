import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';

class SoundController extends GetxController {
  final Sharedprefs _sharedPrefs = Get.find<Sharedprefs>();

  // Separate players for Music and SFX to allow simultaneous playback
  late final AudioPlayer _musicPlayer;
  late final AudioPlayer _sfxPlayer;

  // Settings State
  final RxBool isMusicOn = true.obs;
  final RxBool isSfxOn = true.obs;
  final RxBool isVibrationOn = true.obs;

  @override
  void onClose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize players only once
    _musicPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    _loadSettings();
    _initAudioPlayers();
  }

  void _initAudioPlayers() async {
    // SFX Player: Low latency, stop mode (releases resources immediately)
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);

    // Music Player: Loop mode
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  void _loadSettings() {
    isMusicOn.value = _sharedPrefs.prefs.getBool('isMusicOn') ?? true;
    isSfxOn.value = _sharedPrefs.prefs.getBool('isSfxOn') ?? true;
    isVibrationOn.value = _sharedPrefs.prefs.getBool('isVibrationOn') ?? true;

    // Start music if enabled
    if (isMusicOn.value) {
      playBackgroundMusic();
    }
  }

  // --- Ad Interruption Logic ---

  /// Call this when an Interstitial/Rewarded Ad starts
  Future<void> stopAudioForAd() async {
    try {
      // Pause music to release audio focus/codec
      if (_musicPlayer.state == PlayerState.playing) {
        await _musicPlayer.pause();
      }
      // Stop any pending SFX
      await _sfxPlayer.stop();
    } catch (e) {
      print("Error stopping audio for Ad: $e");
    }
  }

  /// Call this when Ad closes
  Future<void> resumeAudioAfterAd() async {
    // Only resume if music setting is ON
    if (isMusicOn.value) {
      try {
        await _musicPlayer.resume();
      } catch (e) {
        // Fallback if resume fails (e.g. player was disposed or stop called)
        playBackgroundMusic();
      }
    }
  }

  // --- Music Logic ---

  void toggleMusic(bool value) {
    isMusicOn.value = value;
    _sharedPrefs.prefs.setBool('isMusicOn', value);
    if (value) {
      playBackgroundMusic();
    } else {
      _musicPlayer.stop();
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!isMusicOn.value) return;
    try {
      // Ensure specific volume for BGM
      await _musicPlayer.setVolume(0.3);
      if (_musicPlayer.state != PlayerState.playing) {
        await _musicPlayer.play(AssetSource('sounds/bgm.mp3'));
      }
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  // --- SFX Logic ---

  void toggleSfx(bool value) {
    isSfxOn.value = value;
    _sharedPrefs.prefs.setBool('isSfxOn', value);
  }

  /// Play click sound
  Future<void> playClick() async {
    vibrate(); // Vibrate on click if enabled
    if (!isSfxOn.value) return;
    try {
      // Stop previous only if playing to avoid overhead?
      // Actually stop() is good to prevent overlap if user taps fast
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  /// Play success sound
  Future<void> playSuccess() async {
    if (!isSfxOn.value) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  /// Play wrong sound
  Future<void> playWrong() async {
    vibrate(); // Vibrate on error
    if (!isSfxOn.value) return;
    try {
      if (_sfxPlayer.state == PlayerState.playing) {
        await _sfxPlayer.stop();
      }
      await _sfxPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  // --- Vibration Logic ---

  void toggleVibration(bool value) {
    isVibrationOn.value = value;
    _sharedPrefs.prefs.setBool('isVibrationOn', value);
    if (value) vibrate(); // Haptic feedback to confirm
  }

  void vibrate() {
    if (isVibrationOn.value) {
      HapticFeedback.mediumImpact();
    }
  }

  // compatibility for older code
  bool get isMuted => !isSfxOn.value;

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }
}
