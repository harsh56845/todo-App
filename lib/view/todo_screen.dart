import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_flutter_app_2/controller/auth_controller.dart';
import 'package:todo_flutter_app_2/controller/profile_controller.dart';
import 'package:todo_flutter_app_2/controller/todo_controller.dart';
import 'package:todo_flutter_app_2/view/loading_messag.dart';
import 'package:todo_flutter_app_2/view/welcome_screen.dart';

enum Filter { all, completed, incomplete }

class TodoPage extends StatefulWidget {
  final String userEmail;
  final String uid;

  const TodoPage({super.key, required this.userEmail, required this.uid});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoController _todos = TodoController();
  final TextEditingController _tasktitle = TextEditingController();
  final TextEditingController _editTask = TextEditingController();
  final ProfileController profileController = ProfileController();
  Filter _currentFilter = Filter.all;
  bool _isLoading = false;
  String taskMsg = "";

  void _addTask() async {
    if (_tasktitle.text.trim().isNotEmpty) {
      setState(() {
        taskMsg = "Adding Your task";
        _isLoading = true;
      });
      await _todos.addTask(widget.uid, _tasktitle.text.trim());
      _tasktitle.clear();
      setState(() {
        _isLoading = false;
      });
      _snackBarMessage('✅ Task added successfully', Colors.green);
    } else {
      setState(() {
        _isLoading = false;
      });
      _snackBarMessage('⚠️ Text field cannot be empty', Colors.redAccent);
    }
  }

  void _delTask(String docId) async {
    setState(() {
      taskMsg = "Deleting Your task";
      _isLoading = true;
    });
    await _todos.deleteTask(docId, widget.uid);
    _snackBarMessage(
      '🗑️ Task deleted',
      const Color.fromARGB(255, 239, 85, 74),
    );
    setState(() {
      _isLoading = false;
    });
  }

  void _editTaskFun(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: _editTask,
          decoration: const InputDecoration(
            hintText: "Enter new task name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                taskMsg = "Editing Your task";
                _isLoading = true;
              });
              await _todos.editTask(docId, _editTask.text.trim(), widget.uid);
              Navigator.pop(context);
              setState(() {
                _isLoading = false;
              });
              _snackBarMessage('✏️ Task edited successfully', Colors.green);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _snackBarMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            "📝 ToDo App",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF673AB7),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              tooltip: "About App",
              onPressed: () => showAboutDialog(
                context: context,
                applicationName: "ToDo App",
                applicationVersion: "v1.0",
                children: [const Text("Made with ❤️ by Harsh")],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              tooltip: "Logout",
              onPressed: () {
                AuthController().logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Username & welcome message
              StreamBuilder<QuerySnapshot>(
                stream: profileController.fetchProfile(widget.uid),
                builder: (context, snapshot) {
                  String userName = "User";
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text(""));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final data =
                        snapshot.data!.docs.first.data()
                            as Map<String, dynamic>;
                    userName = data['username'] ?? userName;
                  }
                  return Text(
                    "👋 Welcome, $userName!",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF673AB7),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                "🗓️ Let’s plan your day\n🚀 Stay focused & get things done!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: _todos.fetchTasks(widget.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text(""));
                  }
                  final allTasks = snapshot.data!.docs;

                  final filteredTasks = allTasks.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    if (_currentFilter == Filter.completed) {
                      return data['isChecked'] == true;
                    }
                    if (_currentFilter == Filter.incomplete) {
                      return data['isChecked'] == false;
                    }
                    return true; // All
                  }).toList();
                  final count = filteredTasks.length;
                  return Text(
                    "Total tasks: $count",
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilterChip(
                    label: const Text("All"),
                    selected: _currentFilter == Filter.all,
                    onSelected: (_) =>
                        setState(() => _currentFilter = Filter.all),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("✅ Completed"),
                    selected: _currentFilter == Filter.completed,
                    onSelected: (_) =>
                        setState(() => _currentFilter = Filter.completed),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("🕑 Incomplete"),
                    selected: _currentFilter == Filter.incomplete,
                    onSelected: (_) =>
                        setState(() => _currentFilter = Filter.incomplete),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Task input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tasktitle,
                      decoration: const InputDecoration(
                        hintText: "Enter task",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: _addTask,
                    child: const Icon(Icons.add, size: 32, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Task list
              _isLoading
                  ? LoadingMessage(message: taskMsg)
                  : Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _todos.fetchTasks(widget.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No tasks found"));
                          }

                          // final tasks = snapshot.data!.docs;
                          final allTasks = snapshot.data!.docs;

                          final filteredTasks = allTasks.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            if (_currentFilter == Filter.completed)
                              return data['isChecked'] == true;
                            if (_currentFilter == Filter.incomplete)
                              return data['isChecked'] == false;
                            return true; // All
                          }).toList();
                          final tasks = filteredTasks;

                          return ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final taskData =
                                  tasks[index].data() as Map<String, dynamic>;
                              final docId = tasks[index].id;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(
                                    taskData['title'],
                                    style: GoogleFonts.poppins(
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: taskData['isChecked']
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          _editTask.text = taskData['title'];
                                          _editTaskFun(docId);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _delTask(docId),
                                      ),
                                      Checkbox(
                                        value: taskData['isChecked'],
                                        onChanged: (val) {
                                          _todos.toggle(
                                            docId,
                                            val!,
                                            widget.uid,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

              const SizedBox(height: 12),
              const Text(
                "Made by Harsh ❤️",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
