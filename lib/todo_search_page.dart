import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:task_aap2/todo_model.dart';
import 'package:http/http.dart' as http;

class TodoSearchPage extends StatefulWidget {
  const TodoSearchPage({super.key});

  @override
  _TodoSearchPage createState() => _TodoSearchPage();
}

class _TodoSearchPage extends State<TodoSearchPage> {
  late List<Todo> _todos;
  late List<Todo> _filteredTodos;

  @override
  void initState() {
    super.initState();
    _todos = [];
    _filteredTodos = [];
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/todos'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        _todos = jsonData.map((e) => Todo.fromJson(e)).toList();
        _filteredTodos = List.from(_todos);
      });
    } else {
      throw Exception('Failed to load todos');
    }
  }

  void _filterTodos(String query) {
    setState(() {
      _filteredTodos = _todos.where((todo) => todo.title.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final String? query = await showSearch<String>(
                context: context,
                delegate: TodoSearchDelegate(_todos),
              );
              if (query != null) {
                _filterTodos(query);
              }
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredTodos.length,
        itemBuilder: (context, index) {
          final todo = _filteredTodos[index];
          return Card(
            child: ListTile(
              title: Text(todo.title),
              subtitle: Text('User ID: ${todo.userId}, Completed: ${todo.completed.toString()}'),
            ),
          );
        },
      ),
    );
  }
}

class TodoSearchDelegate extends SearchDelegate<String> {
  final List<Todo> todos;

  TodoSearchDelegate(this.todos);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTodos = todos.where((todo) => todo.title.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: filteredTodos.length,
      itemBuilder: (context, index) {
        final todo = filteredTodos[index];
        return Card(
          child: ListTile(
            title: Text(todo.title),
            subtitle: Text('User ID: ${todo.userId}, Completed: ${todo.completed.toString()}'),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestedTodos = todos.where((todo) => todo.title.toLowerCase().startsWith(query.toLowerCase())).toList();
    return ListView.builder(
      itemCount: suggestedTodos.length,
      itemBuilder: (context, index) {
        final todo = suggestedTodos[index];
        return Card(
          child: ListTile(
            title: Text(todo.title),
            subtitle: Text('User ID: ${todo.userId}, Completed: ${todo.completed.toString()}'),
            onTap: () {
              close(context, todo.title);
            },
          ),
        );
      },
    );
  }
}
