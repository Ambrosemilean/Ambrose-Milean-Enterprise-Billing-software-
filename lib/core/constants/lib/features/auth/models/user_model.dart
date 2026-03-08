// lib/features/auth/models/user_model.dart
enum UserRole {
  admin,
  cashier,
  manager,
}

class UserModel {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String? cashierId; // For tracking individual cashiers
  final DateTime createdAt;
  final bool isActive;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.cashierId,
    required this.createdAt,
    required this.isActive,
  });
}

// lib/features/auth/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserModel? _currentUser;
  
  UserModel? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCashier => _currentUser?.role == UserRole.cashier;

  Future<void> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Fetch user role from database
      _currentUser = await _getUserFromDatabase(userCredential.user!.uid);
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
