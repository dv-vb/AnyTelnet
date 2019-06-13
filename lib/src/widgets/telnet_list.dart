
import 'package:flutter/material.dart';
import 'package:anytelnet/src/Controller.dart';
import 'package:anytelnet/src/routes.dart';

/*
class TelnetList extends StatelessWidget {
  TelnetList({Key key}) : super(key: key);

  static final _con = Con.con;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Con.isLoading ? _buildLoading : _buildList(),
    );
  }

  Center get _buildLoading {
    return Center(
      child: CircularProgressIndicator(
        key: ArchSampleKeys.todosLoading,
      ),
    );
  }

  ListView _buildList() {
    final todos = Con.filteredTodos;
    return ListView.builder(
      key: ArchSampleKeys.todoList,
      itemCount: todos.length,
      itemBuilder: (BuildContext context, int index) {
        final Map todo = todos.elementAt(index).cast<String, Object>();
        return TodoItem(
          todo: todo,
          onDismissed: (direction) {
            _removeTodo(context, todo);
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) {
                  return DetailScreen(
                    todoId: todo['id'],
                  );
                },
              ),
            ).then((todo) {
              if (todo is Map && todo.isNotEmpty) {
                _showUndoSnackbar(context, todo);
              }
            });
          },
          onCheckboxChanged: (complete) {
            _con.checked(todo);
          },
        );
      },
    );
  }

}
*/