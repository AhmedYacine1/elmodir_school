import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../core/database/isar_service.dart';
import '../../../models/user.dart';

final authProvider = StateNotifierProvider<AuthProvider, AuthState>(
  (ref) => AuthProvider(),
);

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final String? role;

  AuthState({
    this.isAuthenticated = false,
    this.username,
    this.role,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? username,
    String? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      role: role ?? this.role,
    );
  }
}

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider() : super(AuthState());

  Future<bool> login(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final user = await IsarService.findUserByUsername(username);
      
      if (user != null && user.passwordHash == hashedPassword) {
        state = state.copyWith(
          isAuthenticated: true,
          username: user.username,
          role: user.role,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  void logout() {
    state = state.copyWith(
      isAuthenticated: false,
      username: null,
      role: null,
    );
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}