import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TodoItem {
  TodoItem({required this.id, required this.todo, this.done = false, int? createdAt})
      : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;
  final String id;
  String todo;
  bool done;
  final int createdAt;
  Map<String, dynamic> toJson() => {'id': id, 'todo': todo, 'done': done, 'createdAt': createdAt};
  static TodoItem fromJson(Map<String, dynamic> j) => TodoItem(
        id: j['id'] as String? ?? const Uuid().v4(),
        todo: j['todo'] as String? ?? '',
        done: j['done'] as bool? ?? false,
        createdAt: j['createdAt'] as int?,
      );
}

class TodoState extends ChangeNotifier {
  static const _key = 'moodist_todos';
  final List<TodoItem> _todos = [];
  final _uuid = const Uuid();

  List<TodoItem> get todos => List.unmodifiable(_todos);
  int get doneCount => _todos.where((t) => t.done).length;

  TodoState() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>?;
        if (list != null) {
          _todos.clear();
          for (final e in list) {
            if (e is Map<String, dynamic>) _todos.add(TodoItem.fromJson(e));
          }
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final list = _todos.map((t) => t.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(list));
    notifyListeners();
  }

  void addTodo(String todo) {
    _todos.insert(0, TodoItem(id: _uuid.v4(), todo: todo));
    _save();
  }

  void editTodo(String id, String newTodo) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _todos[i].todo = newTodo;
      _save();
    }
  }

  void toggleTodo(String id) {
    final i = _todos.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _todos[i].done = !_todos[i].done;
      _save();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _save();
  }
}
