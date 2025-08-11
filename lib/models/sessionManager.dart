// lib/utils/session_manager.dart
import 'user.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  User? currentUser;

  void setUser(User user) {
    currentUser = user;
  }

  User? getUser() {
    return currentUser;
  }

  void clearUser() {
    currentUser = null;
  }
}
