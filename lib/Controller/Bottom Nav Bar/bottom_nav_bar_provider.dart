import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  //Variable
  int _selectedIndex = 0;

  //Getter
  int get selectedIndex => _selectedIndex;

  //Change Index Method
  void changeIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
