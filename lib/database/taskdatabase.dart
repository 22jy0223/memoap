import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../memo/task.dart';

Future<Database> initializeTaskDB() async {
  String path = await getDatabasesPath();
  return openDatabase(
    join(path, 'task_database.db'),
    version: 1,
    onCreate: (database, version) async {
      await database.execute(
        "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, content TEXT, updated_at TEXT, color TEXT)",
      );
    },
  );
}

Future<void> insertTask(Task task) async {
  Database db = await initializeTaskDB();
  await db.insert(
    'tasks',
    task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateTask(Task task) async {
  Database db = await initializeTaskDB();
  await db.update(
    'tasks',
    task.toMap(),
    where: 'id = ?',
    whereArgs: [task.id],
  );
}

Future<List<Task>> getTasks() async {
  Database db = await initializeTaskDB();
  final List<Map<String, dynamic>> maps = await db.query('tasks', orderBy: 'updated_at DESC');
  List<Task> tasks = List.generate(maps.length, (i) {
    return Task.fromMap(maps[i]);
  });

  print('Sorted Tasks:');
  tasks.forEach((task) {
    print('Task ID: ${task.id}');
    print('UpdatedAt: ${task.updatedAt}');
  });

  return tasks;
}

Future<void> deleteTask(int id) async {
  Database db = await initializeTaskDB();
  await db.delete(
    'tasks',
    where: 'id = ?',
    whereArgs: [id],
  );
}
