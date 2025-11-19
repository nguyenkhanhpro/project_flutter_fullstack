import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/database.dart';
import 'package:backend/repositories.dart';

// Khởi tạo database
late Database _database;
late UserRepository _userRepository;
late TaskRepository _taskRepository;

/// Cấu hình các routes
final _router = Router(notFoundHandler: _notFoundHandler)
  ..get('/', _rootHandler)
  ..get('/api/v1/check', _checkHandler)
  ..get('/api/v1/echo/<message>', _echoHandler)
  ..post('/api/v1/submit', _submitHandler)
  // User routes
  ..get('/api/v1/users', _getAllUsersHandler)
  ..post('/api/v1/users', _createUserHandler)
  ..get('/api/v1/users/<userId>', _getUserHandler)
  ..put('/api/v1/users/<userId>', _updateUserHandler)
  ..delete('/api/v1/users/<userId>', _deleteUserHandler)
  // Task routes
  ..get('/api/v1/users/<userId>/tasks', _getTasksHandler)
  ..post('/api/v1/users/<userId>/tasks', _createTaskHandler)
  ..put('/api/v1/tasks/<taskId>', _updateTaskHandler)
  ..delete('/api/v1/tasks/<taskId>', _deleteTaskHandler);

/// Header mặc định cho dữ liệu trả về dưới dạng JSON
final _headers = {'Content-Type': 'application/json'};

/// Xử lý các yêu cầu đến các đường dẫn không được định nghĩa (404 Not Found).
Response _notFoundHandler(Request req) {
  return Response.notFound('Không tìm thấy đường dẫn "${req.url}" trên server');
}

/// Hàm xử lý các yêu cầu gốc tại đường dẫn '/'
///
/// Trả về một phản hồi với thông điệp "Hello, World!" dưới dạng JSON
///
/// `reg`: Đối tượng yêu cầu từ client
///
/// Trả về: Một đối tượng `Response` với mã trạng thái 200 và nội dung JSON
Response _rootHandler(Request req) {
  // Constructor `ok` của Response có statusCode là 200
  return Response.ok(
    json.encode({'message': 'Hello, World!'}),
    headers: _headers,
  );
}

/// Hàm xử lý yêu cầu tại đường dẫn '/api/v1/check'
Response _checkHandler(Request req) {
  return Response.ok(
    json.encode({'message': 'Chào mừng bạn đến với ứng dụng web động'}),
    headers: _headers,
  );
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

// ===== USER HANDLERS =====
Future<Response> _getAllUsersHandler(Request req) async {
  try {
    final users = await _userRepository.getAllUsers();
    return Response.ok(
      json.encode(users.map((u) => u.toJson()).toList()),
      headers: _headers,
    );
  } catch (e) {
    return Response.internalServerError(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _createUserHandler(Request req) async {
  try {
    final payload = await req.readAsString();
    final data = json.decode(payload) as Map<String, dynamic>;

    final user = await _userRepository.createUser(
      name: data['name'] as String,
      email: data['email'] as String,
      password: data['password'] as String,
    );

    return Response.ok(json.encode(user.toJson()), headers: _headers);
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _getUserHandler(Request req) async {
  try {
    final userId = int.parse(req.params['userId']!);
    final user = await _userRepository.getUserById(userId);

    if (user == null) {
      return Response.notFound(
        json.encode({'error': 'Không tìm thấy user'}),
        headers: _headers,
      );
    }

    return Response.ok(json.encode(user.toJson()), headers: _headers);
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _updateUserHandler(Request req) async {
  try {
    final userId = int.parse(req.params['userId']!);
    final payload = await req.readAsString();
    final data = json.decode(payload) as Map<String, dynamic>;

    await _userRepository.updateUser(
      userId,
      name: data['name'] as String?,
      email: data['email'] as String?,
    );

    final user = await _userRepository.getUserById(userId);
    return Response.ok(json.encode(user?.toJson()), headers: _headers);
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _deleteUserHandler(Request req) async {
  try {
    final userId = int.parse(req.params['userId']!);
    await _userRepository.deleteUser(userId);

    return Response.ok(
      json.encode({'message': 'Xóa user thành công'}),
      headers: _headers,
    );
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

// ===== TASK HANDLERS =====
Future<Response> _getTasksHandler(Request req) async {
  try {
    final userId = int.parse(req.params['userId']!);
    final tasks = await _taskRepository.getTasksByUserId(userId);

    return Response.ok(
      json.encode(tasks.map((t) => t.toJson()).toList()),
      headers: _headers,
    );
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _createTaskHandler(Request req) async {
  try {
    final userId = int.parse(req.params['userId']!);
    final payload = await req.readAsString();
    final data = json.decode(payload) as Map<String, dynamic>;

    final task = await _taskRepository.createTask(
      userId: userId,
      title: data['title'] as String,
      description: data['description'] as String?,
    );

    return Response.ok(json.encode(task.toJson()), headers: _headers);
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _updateTaskHandler(Request req) async {
  try {
    final taskId = int.parse(req.params['taskId']!);
    final payload = await req.readAsString();
    final data = json.decode(payload) as Map<String, dynamic>;

    await _taskRepository.updateTask(
      taskId,
      title: data['title'] as String?,
      description: data['description'] as String?,
      isCompleted: data['isCompleted'] as bool?,
    );

    final task = await _taskRepository.getTaskById(taskId);
    return Response.ok(json.encode(task?.toJson()), headers: _headers);
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _deleteTaskHandler(Request req) async {
  try {
    final taskId = int.parse(req.params['taskId']!);
    await _taskRepository.deleteTask(taskId);

    return Response.ok(
      json.encode({'message': 'Xóa task thành công'}),
      headers: _headers,
    );
  } catch (e) {
    return Response.badRequest(
      body: json.encode({'error': e.toString()}),
      headers: _headers,
    );
  }
}

Future<Response> _submitHandler(Request req) async {
  try {
    // Đọc payload từ request
    final payload = await req.readAsString();

    // Giải mã JSON từ payload
    final data = json.decode(payload);

    // Lấy giá trị 'name' từ data, ép kiểu về String? nếu có
    final name = data['name'] as String?;

    // Kiểm tra nếu 'name' hợp lệ
    if (name != null && name.isNotEmpty) {
      // Tạo phản hồi chào mừng
      final response = {'message': 'Chào mừng $name'};

      // Trả về phản hồi với statusCode 200 và nội dung JSON
      return Response.ok(json.encode(response), headers: _headers);
    } else {
      // Tạo phản hồi yêu cầu cung cấp tên
      final response = {'message': 'Server không nhận được tên của bạn.'};

      // Trả về phản hồi với statusCode 400 và nội dung JSON
      return Response.badRequest(
        body: json.encode(response),
        headers: _headers,
      );
    }
  } catch (e) {
    // Xử lý ngoại lệ khi giải mã JSON
    final response = {'message': 'Yêu cầu không hợp lệ. Lỗi ${e.toString()}'};

    // Trả về phản hồi với statusCode 400
    return Response.badRequest(body: json.encode(response), headers: _headers);
  }
}

void main(List<String> args) async {
  // Khởi tạo database
  _database = Database();
  await _database.init();
  _userRepository = UserRepository(database: _database);
  _taskRepository = TaskRepository(database: _database);

  // Lắng nghe trên tất cả các địa chỉ IPv4
  final ip = InternetAddress.anyIPv4;

  final corsHeader = createMiddleware(
    requestHandler: (req) {
      if (req.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            // Cho phép mọi nguồn truy cập (trong môi trường dev). Trong môi trường production chúng ta nên thay * bằng domain cụ thể.
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods':
                'GET, POST, PUT, DELETE, PATCH, HEAD',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          },
        );
      }
      return null; // Tiếp tục xử lý các yêu cầu khác
    },
    responseHandler: (res) {
      return res.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, HEAD',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        },
      );
    },
  );

  // Cấu hình một pipeline để logs các requests và middleware
  final handler = Pipeline()
      .addMiddleware(corsHeader) // Thêm middleware xử lý CORS
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // Để chạy trong các container, chúng ta sẽ sử dụng biến môi trường PORT.
  // Nếu biến môi trường không được thiết lập nó sẽ sử dụng giá trị từ biến
  // môi trường này; nếu không, nó sẽ sử dụng giá trị mặc định là 8080.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  // Khởi chạy server tại địa chỉ và cổng chỉ định
  final server = await serve(handler, ip, port);
  print('Server đang chạy tại http://${server.address.host}:${server.port}');
  print('Database đã được khởi tạo thành công');
}
