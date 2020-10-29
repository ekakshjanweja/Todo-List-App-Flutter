import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._instance(); //singleton object
  static Database _db;
  DatabaseHelper._instance();
  String taskTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  // Task Table
  // Id | Title | Date | Priority | Status
  // 0  |  ''   |  ''  |    ''    |   0
  // 1  |  ''   |  ''  |    ''    |   0
  // 2  |  ''   |  ''  |    ''    |   1
  // 3  |  ''   |  ''  |    ''    |   0
  // 4  |  ''   |  ''  |    ''    |   1
  // 5  |  ''   |  ''  |    ''    |   1

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initialiseDatabase();
    }
    return _db;
  }

  Future<Database> _initialiseDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDatabase);
    return todoListDb;
  }

  void _createDatabase(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $taskTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT,$colDate TEXT,$colPriority TEXT,$colStatus INTEGER)',
    );
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(taskTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> taskList = [];
    taskMapList.forEach((taskMap) {
      taskList.add(Task.fromMap(taskMap));
    });
    taskList.sort((taskA,taskB)=>taskA.date.compareTo(taskB.date));
    return taskList;
  }

  Future<int> insertTask(Task task) async {
    Database db = await this.db;
    final int result = await db.insert(taskTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final int result = await db.update(
      taskTable,
      task.toMap(),
      where: '$colId = ?',
      whereArgs: [task.id],
    );
    return result;
  }

  Future<int> deleteTask(int id) async {
    Database db = await this.db;
    final int result = await db.delete(
      taskTable,
      where: '$colId = ?',
      whereArgs: [id],
    );
    return result;
  }
}
