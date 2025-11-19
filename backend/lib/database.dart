import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'dart:io';
import 'package:path/path.dart' as path;

class Database {
  late sqlite3.Database _db;
  late String _dbPath;

  /// Khởi tạo database
  Future<void> init() async {
    // Tạo thư mục data nếu chưa tồn tại
    final dataDir = Directory('data');
    if (!dataDir.existsSync()) {
      dataDir.createSync();
    }

    _dbPath = path.join('data', 'app.db');
    _db = sqlite3.sqlite3.open(_dbPath);

    // Tạo các bảng
    await _createTables();
  }

  /// Tạo các bảng database
  Future<void> _createTables() async {
    // Bảng Users
    _db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Bảng Tasks/Items
    _db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  /// Lấy database connection
  sqlite3.Database get db => _db;

  /// Đóng database
  Future<void> close() async {
    _db.dispose();
  }
}
