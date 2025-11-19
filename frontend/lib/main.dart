import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// API URL - Thay đổi tùy theo platform:
// - Web: http://localhost:8080
// - Android Emulator: http://10.0.2.2:8080
// - Physical Device: http://192.168.x.x:8080 (IP của máy host)
const String apiUrl = 'http://localhost:8080/api/v1';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ứng dụng full-stack flutter',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng full-stack flutter'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [UsersPage(), TasksPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tasks'),
        ],
      ),
    );
  }
}

// ===== USERS PAGE =====
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> users = [];
  bool isLoading = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
        });
      }
    } catch (e) {
      _showError('Lỗi khi tải users: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> createUser() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showError('Vui lòng điền đầy đủ thông tin');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        _showSuccess('Tạo user thành công');
        loadUsers();
      } else {
        _showError('Lỗi: ${response.body}');
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/users/$id'));
      if (response.statusCode == 200) {
        _showSuccess('Xóa user thành công');
        loadUsers();
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo User Mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Tên',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: createUser,
              child: const Text('Tạo User'),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Danh Sách Users',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (users.isEmpty)
            const Center(child: Text('Không có users'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(user['name'] ?? ''),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteUser(user['id']),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

// ===== TASKS PAGE =====
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<dynamic> users = [];
  List<dynamic> tasks = [];
  int? selectedUserId;
  bool isLoading = false;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/users'));
      if (response.statusCode == 200) {
        setState(() {
          users = json.decode(response.body);
          if (users.isNotEmpty) {
            selectedUserId = users[0]['id'];
            loadTasks();
          }
        });
      }
    } catch (e) {
      _showError('Lỗi khi tải users: $e');
    }
  }

  Future<void> loadTasks() async {
    if (selectedUserId == null) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/users/$selectedUserId/tasks'),
      );
      if (response.statusCode == 200) {
        setState(() {
          tasks = json.decode(response.body);
        });
      }
    } catch (e) {
      _showError('Lỗi khi tải tasks: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> createTask() async {
    if (selectedUserId == null || titleController.text.isEmpty) {
      _showError('Vui lòng chọn user và nhập tiêu đề');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/users/$selectedUserId/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': titleController.text,
          'description': descriptionController.text,
        }),
      );

      if (response.statusCode == 200) {
        titleController.clear();
        descriptionController.clear();
        _showSuccess('Tạo task thành công');
        loadTasks();
      } else {
        _showError('Lỗi: ${response.body}');
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  Future<void> toggleTask(int taskId, bool currentStatus) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/tasks/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isCompleted': !currentStatus}),
      );

      if (response.statusCode == 200) {
        loadTasks();
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/tasks/$taskId'));
      if (response.statusCode == 200) {
        _showSuccess('Xóa task thành công');
        loadTasks();
      }
    } catch (e) {
      _showError('Lỗi: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo Task Mới',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButton<int>(
            isExpanded: true,
            value: selectedUserId,
            items: users.map((user) {
              return DropdownMenuItem<int>(
                value: user['id'],
                child: Text(user['name'] ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedUserId = value;
                loadTasks();
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Tiêu đề',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: createTask,
              child: const Text('Tạo Task'),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Danh Sách Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (tasks.isEmpty)
            const Center(child: Text('Không có tasks'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Checkbox(
                      value: task['isCompleted'] ?? false,
                      onChanged: (_) =>
                          toggleTask(task['id'], task['isCompleted'] ?? false),
                    ),
                    title: Text(
                      task['title'] ?? '',
                      style: TextStyle(
                        decoration: task['isCompleted']
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: task['description'] != null
                        ? Text(task['description'])
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteTask(task['id']),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
