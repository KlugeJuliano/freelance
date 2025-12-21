import 'package:flutter/material.dart';
import 'package:freelance/models/users.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  String? get cargo => user?.cargo;

  void login(UserModel cargo) {
    _user = user;

    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
