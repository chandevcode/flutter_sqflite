// ignore_for_file: prefer_const_constructors, unused_field, prefer_final_fields

import 'package:flutter/material.dart';

import 'sql_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SQFLite',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //List Data
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshJournals();
    super.initState(); // Loading data when apps starts
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  //this function is trigger when button pressed also can be button update items
  void _showForm(int? id) async {
    if (id != null) {
      final existinJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existinJournal['title'];
      _descriptionController.text = existinJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  top: 15,
                  left: 15,
                  right: 15,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 120),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Notes',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        //save new journal
                        if (id == null) {
                          await _addItem();
                        }
                        if (id != null) {
                          await _updateItem(id);
                        }
                        _titleController.text = '';
                        _descriptionController.text = '';

                        //Close Form
                        Navigator.of(context).pop();
                      },
                      child: Text(id == null ? 'Create New' : 'Update'))
                ],
              ),
            ));
  }

  //Insert a New Journal to Database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

// Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

//Delete Item in Database
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Successfully Deleted')));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Sqflite CRUD'),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _journals.length,
                itemBuilder: (context, index) => Card(
                    color: Colors.purple[100],
                    margin: EdgeInsets.all(15),
                    child: ListTile(
                      title: Text(
                        _journals[index]['title'],
                      ),
                      subtitle: Text(_journals[index]['description']),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showForm(_journals[index]['id']),
                          ),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteItem(_journals[index]['id']))
                        ]),
                      ),
                    )),
              ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: () => _showForm(null)));
  }
}
