import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_toast.dart';
import 'package:flutter_omath/models/mathque_model.dart';
import 'package:flutter_omath/utils/consts.dart';

class HomeGameController extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  final List<MathqueModel> _mathList = [];
  List<MathqueModel> get mathQueList => _mathList;

  int _level = 0;
  int get level => _level;

  int _score = 0;
  int get score => _score;

  MathqueModel? _currentQue;
  MathqueModel? get currentQue => _currentQue;

  String _ansText = "";
  String get ansText => _ansText;

  String _successMsg = "";
  String get successMsg => _successMsg;

  readData(BuildContext context) async {
    _loading = true;

    await DefaultAssetBundle.of(context)
        .loadString("assets/game_data/game.json")
        .then((data) {
      final jsonResult = jsonDecode(data);
      if (_mathList.isNotEmpty) {
        _mathList.clear();
      }
      for (var e in jsonResult) {
        MathqueModel mathModel = MathqueModel.fromJson(e);
        _mathList.add(mathModel);
      }
      _loading = false;
      notifyListeners();

      if (_mathList.isNotEmpty) {
        //setup level
        setupLevel();
      }
    }).onError((error, stackTrace) {
      _loading = false;
      notifyListeners();
    });
  }

  setupLevel({bool isNex = false}) {
    if (isNex) {
      _level++;
    }
    _successMsg = '';
    _currentQue = _mathList[_level];
    _ansText = "?";
    notifyListeners();
  }

  removeFromAns() {
    if (_ansText.isNotEmpty) {
      _ansText = _ansText.substring(0, _ansText.length - 1);
    }
    if (_ansText.isEmpty) {
      _ansText = "?";
    }
    notifyListeners();
  }

  resetAns() {
    _ansText = "?";
    notifyListeners();
  }

  addDigitToAns(String char) {
    if (_ansText.contains('?')) {
      _ansText = "";
    }
    _ansText += char;
    notifyListeners();
    checkRightAns();
  }

  checkRightAns() async {
    if (_currentQue == null) {
      return;
    }
    if (_currentQue?.ans == _ansText) {
      _successMsg = "Correct Ans";
      MyToast.showGreentoast("Excellent, Next Moving to Next Problem.");
      _score += scoreUpdate;
      notifyListeners();
      await Future.delayed(
        const Duration(seconds: 2),
      );
      setupLevel(isNex: true);
    }
  }
}
