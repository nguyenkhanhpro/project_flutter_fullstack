import 'package:sqlite3/sqlite3.dart';

/// Model User
class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final DateTime? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.createdAt,
  });

  /// Chuyển đổi từ row database thành User
  factory User.fromRow(Row row) {
    return User(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      password: row['password'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

/// Model Task
class Task {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Chuyển đổi từ row database thành Task
  factory Task.fromRow(Row row) {
    return Task(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      description: row['description'] as String?,
      isCompleted: (row['is_completed'] as int) == 1,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
