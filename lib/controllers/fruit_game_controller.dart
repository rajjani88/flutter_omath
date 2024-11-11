import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/num_helper.dart';

class FruitGameController extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  final int _listSize = 10;
  final List<String> _queList = [];
  List<String> get qurList => _queList;

  final List<double> _digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
  final List<String> _opList = [
    '+',
    '-',
    '*',
    '/',
  ];

  int _hidePosition = 0;
  int get hidePos => _hidePosition;

  final int _level = 0;
  int get level => _level;

  String _currentQue = '';
  String get currentQue => _currentQue;

  double getRandomdigit() {
    _digits.shuffle();
    return _digits[Random().nextInt(_digits.length)];
  }

  void changeHidePos() {
    _hidePosition = Random().nextInt(3);
  }

  buildQueList() {
    _loading = true;
    if (_queList.isNotEmpty) {
      _queList.clear();
    }
    for (var i = 0; i < _listSize; i++) {
      _opList.shuffle();
      double firstNum = (getRandomdigit() * 10) + getRandomdigit();
      double secondNum = (getRandomdigit() * 10) + getRandomdigit();
      double thirdNum = 0;

      String op = _opList[0];
      if (op == '+') {
        thirdNum = (firstNum + secondNum);
      } else if (op == '-') {
        thirdNum = (firstNum - secondNum);
      } else if (op == '*') {
        thirdNum = (firstNum * secondNum);
      } else {
        thirdNum = firstNum / secondNum;
      }

      String que =
          '${removeTraillingZero(firstNum)} $op ${removeTraillingZero(secondNum)} = ${removeTraillingZero(double.parse(thirdNum.toStringAsFixed(2)))}';
      _queList.add(que);
    }
    changeHidePos();
    _currentQue = _queList[_level];
    _loading = false;
  }
}
