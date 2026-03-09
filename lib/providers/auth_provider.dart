import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { customer, technician, manager, admin, owner }

class User {
  final String id;
  final String name;
  final UserRole role;

  User({required this.id, required this.name, required this.role});
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadUser();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    // Mock network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication logic based on username
    if (username.toLowerCase().contains('customer')) {
      _currentUser = User(id: '1', name: 'John Customer', role: UserRole.customer);
    } else if (username.toLowerCase().contains('tech')) {
      _currentUser = User(id: '2', name: 'Mike Technician', role: UserRole.technician);
    } else if (username.toLowerCase().contains('manager')) {
      _currentUser = User(id: '3', name: 'Sarah Manager', role: UserRole.manager);
    } else if (username.toLowerCase().contains('admin')) {
      _currentUser = User(id: '4', name: 'Admin User', role: UserRole.admin);
    } else if (username.toLowerCase().contains('owner')) {
      _currentUser = User(id: '5', name: 'Boss Owner', role: UserRole.owner);
    } else {
      // Default to customer if no matching role
      _currentUser = User(id: '1', name: 'Demo Customer', role: UserRole.customer);
    }

    await _saveUser();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    notifyListeners();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString('user_role');
    final name = prefs.getString('user_name') ?? 'Demo User';

    if (roleStr != null) {
      final role = UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == roleStr,
        orElse: () => UserRole.customer,
      );
      _currentUser = User(id: '0', name: name, role: role);
      notifyListeners();
    }
  }

  Future<void> _saveUser() async {
    if (_currentUser == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', _currentUser!.role.toString().split('.').last);
    await prefs.setString('user_name', _currentUser!.name);
  }
}
