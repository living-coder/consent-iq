import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../data/mock_store.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  bool login(String email, String password) {
    final user = MockStore().authenticate(email, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
