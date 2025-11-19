# Backend SQLite API

Backend Dart/Shelf với SQLite database để quản lý Users và Tasks.

## Cấu trúc

```
backend/
├── bin/
│   └── server.dart          # Main server entry point
├── lib/
│   ├── database.dart        # Database initialization
│   ├── models.dart          # Data models (User, Task)
│   └── repositories.dart    # Repository pattern (UserRepository, TaskRepository)
├── data/
│   └── app.db               # SQLite database file (created on init)
├── pubspec.yaml             # Dependencies
└── Dockerfile               # Docker configuration
```

## Cài đặt Dependencies

```bash
cd backend
dart pub get
```

## Chạy Server

```bash
dart run bin/server.dart
```

Server sẽ chạy tại `http://localhost:8080` (hoặc port được định nghĩa trong biến môi trường `PORT`)

## Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

### Tasks Table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  is_completed INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
)
```

## API Endpoints

### User Endpoints

#### Lấy tất cả users
```
GET /api/v1/users
```

Response:
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
]
```

#### Tạo user mới
```
POST /api/v1/users
```

Request body:
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

Response: User object (như trên)

#### Lấy user theo ID
```
GET /api/v1/users/<userId>
```

#### Cập nhật user
```
PUT /api/v1/users/<userId>
```

Request body:
```json
{
  "name": "Updated Name",
  "email": "newemail@example.com"
}
```

#### Xóa user
```
DELETE /api/v1/users/<userId>
```

### Task Endpoints

#### Lấy tất cả tasks của user
```
GET /api/v1/users/<userId>/tasks
```

Response:
```json
[
  {
    "id": 1,
    "userId": 1,
    "title": "Task 1",
    "description": "Description",
    "isCompleted": false,
    "createdAt": "2024-01-15T10:30:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
]
```

#### Tạo task mới
```
POST /api/v1/users/<userId>/tasks
```

Request body:
```json
{
  "title": "Task Title",
  "description": "Task Description"
}
```

#### Cập nhật task
```
PUT /api/v1/tasks/<taskId>
```

Request body:
```json
{
  "title": "Updated Title",
  "description": "Updated Description",
  "isCompleted": true
}
```

#### Xóa task
```
DELETE /api/v1/tasks/<taskId>
```

## Chạy với Docker

```bash
docker build -t backend-api .
docker run -p 8080:8080 backend-api
```

## Testing

```bash
dart test
```
