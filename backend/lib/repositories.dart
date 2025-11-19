import 'models.dart';
import 'database.dart' as db_module;

/// Repository cho User
class UserRepository {
  final db_module.Database database;

  UserRepository({required this.database});

  /// Tạo user mới
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      database.db.execute(
        'INSERT INTO users (name, email, password) VALUES (?, ?, ?)',
        [name, email, password],
      );

      final result = database.db.select('SELECT * FROM users WHERE email = ?', [
        email,
      ]);

      return User.fromRow(result.first);
    } catch (e) {
      throw Exception('Lỗi khi tạo user: $e');
    }
  }

  /// Lấy user theo ID
  Future<User?> getUserById(int id) async {
    try {
      final result = database.db.select('SELECT * FROM users WHERE id = ?', [
        id,
      ]);

      if (result.isEmpty) return null;
      return User.fromRow(result.first);
    } catch (e) {
      throw Exception('Lỗi khi lấy user: $e');
    }
  }

  /// Lấy user theo email
  Future<User?> getUserByEmail(String email) async {
    try {
      final result = database.db.select('SELECT * FROM users WHERE email = ?', [
        email,
      ]);

      if (result.isEmpty) return null;
      return User.fromRow(result.first);
    } catch (e) {
      throw Exception('Lỗi khi lấy user: $e');
    }
  }

  /// Lấy tất cả users
  Future<List<User>> getAllUsers() async {
    try {
      final result = database.db.select('SELECT * FROM users');
      return result.map((row) => User.fromRow(row)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách users: $e');
    }
  }

  /// Cập nhật user
  Future<void> updateUser(int id, {String? name, String? email}) async {
    try {
      final updates = <String>[];
      final params = <dynamic>[];

      if (name != null) {
        updates.add('name = ?');
        params.add(name);
      }
      if (email != null) {
        updates.add('email = ?');
        params.add(email);
      }

      if (updates.isEmpty) return;

      params.add(id);
      database.db.execute(
        'UPDATE users SET ${updates.join(', ')} WHERE id = ?',
        params,
      );
    } catch (e) {
      throw Exception('Lỗi khi cập nhật user: $e');
    }
  }

  /// Xóa user
  Future<void> deleteUser(int id) async {
    try {
      database.db.execute('DELETE FROM users WHERE id = ?', [id]);
    } catch (e) {
      throw Exception('Lỗi khi xóa user: $e');
    }
  }
}

/// Repository cho Task
class TaskRepository {
  final db_module.Database database;

  TaskRepository({required this.database});

  /// Tạo task mới
  Future<Task> createTask({
    required int userId,
    required String title,
    String? description,
  }) async {
    try {
      database.db.execute(
        'INSERT INTO tasks (user_id, title, description) VALUES (?, ?, ?)',
        [userId, title, description],
      );

      final result = database.db.select(
        'SELECT * FROM tasks WHERE user_id = ? ORDER BY id DESC LIMIT 1',
        [userId],
      );

      return Task.fromRow(result.first);
    } catch (e) {
      throw Exception('Lỗi khi tạo task: $e');
    }
  }

  /// Lấy task theo ID
  Future<Task?> getTaskById(int id) async {
    try {
      final result = database.db.select('SELECT * FROM tasks WHERE id = ?', [
        id,
      ]);

      if (result.isEmpty) return null;
      return Task.fromRow(result.first);
    } catch (e) {
      throw Exception('Lỗi khi lấy task: $e');
    }
  }

  /// Lấy tất cả tasks của user
  Future<List<Task>> getTasksByUserId(int userId) async {
    try {
      final result = database.db.select(
        'SELECT * FROM tasks WHERE user_id = ? ORDER BY created_at DESC',
        [userId],
      );

      return result.map((row) => Task.fromRow(row)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách tasks: $e');
    }
  }

  /// Cập nhật task
  Future<void> updateTask(
    int id, {
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    try {
      final updates = <String>[];
      final params = <dynamic>[];

      if (title != null) {
        updates.add('title = ?');
        params.add(title);
      }
      if (description != null) {
        updates.add('description = ?');
        params.add(description);
      }
      if (isCompleted != null) {
        updates.add('is_completed = ?');
        params.add(isCompleted ? 1 : 0);
      }

      updates.add('updated_at = CURRENT_TIMESTAMP');

      if (updates.isEmpty) return;

      params.add(id);
      database.db.execute(
        'UPDATE tasks SET ${updates.join(', ')} WHERE id = ?',
        params,
      );
    } catch (e) {
      throw Exception('Lỗi khi cập nhật task: $e');
    }
  }

  /// Xóa task
  Future<void> deleteTask(int id) async {
    try {
      database.db.execute('DELETE FROM tasks WHERE id = ?', [id]);
    } catch (e) {
      throw Exception('Lỗi khi xóa task: $e');
    }
  }

  /// Xóa tất cả tasks của user
  Future<void> deleteTasksByUserId(int userId) async {
    try {
      database.db.execute('DELETE FROM tasks WHERE user_id = ?', [userId]);
    } catch (e) {
      throw Exception('Lỗi khi xóa tasks của user: $e');
    }
  }
}
