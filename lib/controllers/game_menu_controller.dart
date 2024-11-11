import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/consts.dart';

class GameMenuController extends ChangeNotifier {
  final bool _loading = false;
  bool get loading => _loading;

  bool _isMusicOn = false;
  bool get isMusicOn => _isMusicOn;

  //setup music
  final assetsAudioPlayer = AssetsAudioPlayer();

  setupMusic() {
    assetsAudioPlayer
        .open(Audio(gameMusic),
            showNotification: false, loopMode: LoopMode.single)
        .then((value) {
      if (_isMusicOn) {
        playMusic(isRefresh: false);
      } else {
        pauseMusic();
      }
    }).onError((error, stackTrace) {});
  }

  playMusic({bool isRefresh = true}) {
    //print('music play');
    try {
      assetsAudioPlayer.play();
      _isMusicOn = true;
      if (isRefresh) {
        notifyListeners();
      }
    } catch (e) {
      // print('play error : $e');
    }
  }

  pauseMusic() {
    if (assetsAudioPlayer.isPlaying.value) {
      //print('music stop');
      assetsAudioPlayer.pause();
      _isMusicOn = false;
      notifyListeners();
    }
  }

  disposeAudio() {
    if (assetsAudioPlayer.isPlaying.value) {
      //print('music stop');
      assetsAudioPlayer.stop();
      assetsAudioPlayer.dispose();
    }
  }

  updateMusicStatus() {
    if (_isMusicOn) {
      pauseMusic();
    } else {
      playMusic(isRefresh: true);
    }
  }
}
