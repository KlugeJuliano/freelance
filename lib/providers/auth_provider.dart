import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier{
  String _role = "";

  String get role => _role;

  void login(String cargo){
    _role = cargo;
    notifyListeners();
  }
  void logout(){
    _role = "";
    notifyListeners();
  }

}