import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class SoundController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAudioPlayer();
  }

  void _initAudioPlayer() async {
    // Set audio player mode for low latency sound effects
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Play short click/pop sound when user taps buttons or UI elements
  Future<void> playClick() async {
    if (isMuted.value) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  /// Play success/win sound when user completes a level or gets correct answer
  Future<void> playSuccess() async {
    if (isMuted.value) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  /// Play error/buzz sound when user gets wrong answer
  Future<void> playWrong() async {
    if (isMuted.value) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    } catch (e) {
      print('Error playing wrong sound: $e');
    }
  }

  /// Toggle mute/unmute for all sound effects
  void toggleMute() {
    isMuted.value = !isMuted.value;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
