import 'package:flutter/material.dart';

class ColorState with ChangeNotifier {
  bool _isBlue = false;

  bool get getIsBlue {
    return _isBlue;
  }

  Color get getColor {
    return _isBlue ? Colors.blue : Colors.amber;
  }

  set setColor(bool value) {
    _isBlue = value;
    notifyListeners();
  }
}
