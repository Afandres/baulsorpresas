class User {
  int? id;
  String username;
  String password;
  String token;
  String role;
  // Nota: En un entorno de producción, no se debe almacenar la contraseña en texto claro, sino como un hash seguro.

  User(
      {this.id,
      required this.username,
      required this.password,
      this.token = '',
      this.role = ''});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'token': token,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      token: map['token'] ?? '',
      role: map['role'],
    );
  }
}
