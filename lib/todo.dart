import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  // save data
  //final List<String> _todoList = <String>[];
  // text field
  final TextEditingController _textFieldController = TextEditingController();
  final listToDo = FirebaseFirestore.instance.collection('hello');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            listToDo.orderBy('time_inserted', descending: false).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');

          if (snapshot.connectionState == ConnectionState.waiting)
            return (Center(
              child: CircularProgressIndicator(),
            ));
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              //print(document.id);
              return Dismissible(
                key: Key(document.id),
                child: ListTile(
                  title: Text(data['data']),
                ),
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: AlignmentDirectional.centerStart,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.amber,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (DismissDirection direction) {
                  if (direction == DismissDirection.startToEnd)
                    _removeTodoItem(document.id);
                  else
                    _editTodoItem(
                        data['data'], document.id, data['time_inserted']);
                },
              );
            }).toList(),
          );
        },
      ),
      /*ListView(children: _getItems()),
      // add items to the to-do list*/
      floatingActionButton: FloatingActionButton(
          onPressed: () => _displayDialog(context),
          tooltip: 'Add Item',
          child: Icon(Icons.add)),
    );
  }

  Future<void> _addTodoItem(String title) {
    return listToDo
        .add({'data': title, 'time_inserted': FieldValue.serverTimestamp()});
  }

  Future<void> _edit(String update, String id, Timestamp time) {
    _removeTodoItem(id);
    return listToDo.add({'data': update, 'time_inserted': time});
  }

  void _editTodoItem(String data, String id, Timestamp time) {
    _textFieldController.text = data;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Edit $data'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: "type here"),
          ),
          actions: <Widget>[
            new TextButton(
              child: new Text('Edit'),
              onPressed: () {
                _edit(_textFieldController.text, id, time);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _removeTodoItem(String id) {
    return listToDo.doc(id).delete();
  }

  // display a dialog for the user to enter items
  Future<dynamic> _displayDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a task to your list'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter task here'),
          ),
          actions: <Widget>[
            // add button
            TextButton(
              child: const Text('ADD'),
              onPressed: () {
                Navigator.of(context).pop();
                _addTodoItem(_textFieldController.text);
              },
            ),
            // Cancel button
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}
