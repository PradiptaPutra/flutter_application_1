// pengguna.dart
class Pengguna {
  int? userId;
  String username;
  String passwordHash;
  String email;
  String createdAt;

  Pengguna({this.userId, required this.username, required this.passwordHash, required this.email, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password_hash': passwordHash,
      'email': email,
      'created_at': createdAt,
    };
  }
}
