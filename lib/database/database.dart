import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../memo/memo.dart';

// デバッグ用フラグ
//初回起動時のみtruにする
bool shouldDeleteDatabase = false;

Future<void> deleteDatabaseFile() async {
  String path = join(await getDatabasesPath(), 'memo_database.db');
  await deleteDatabase(path);
  print('Database deleted');
}

Future<Database> initializeDB() async {
  String path = await getDatabasesPath();
  return openDatabase(
    join(path, 'memo_database.db'),
    version: 3, 
    onCreate: (database, version) async {
      await database.execute(
        "CREATE TABLE memos(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, updated_at TEXT, created_at TEXT, content TEXT, imageBase64 TEXT, isPinned INTEGER DEFAULT 0)", 
      );
    },
    onUpgrade: (database, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await database.execute(
          "ALTER TABLE memos ADD COLUMN imageBase64 TEXT",
        );
      }
      if (oldVersion < 3) {
        await database.execute(
          "ALTER TABLE memos ADD COLUMN isPinned INTEGER DEFAULT 0", 
        );
      }
    },
  );
}

Future<void> insertMemo(Memo memo) async {
  Database db = await initializeDB();
  await db.insert(
    'memos',
    memo.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> updateRecord(Memo memo) async {
  Database db = await initializeDB();
  await db.update(
    'memos',
    memo.toMap(),
    where: 'id = ?',
    whereArgs: [memo.id],
  );
}

Future<List<Memo>> getMemos() async {
  Database db = await initializeDB();
  final List<Map<String, dynamic>> maps = await db.query('memos', orderBy: 'updated_at DESC');
  List<Memo> memos = List.generate(maps.length, (i) {
    return Memo.fromMap(maps[i]);
  });

  print('Sorted Memos:');
  memos.forEach((memo) {
    print('Memo ID: ${memo.id}');
    print('IsPinned: ${memo.isPinned}');
    print('UpdatedAt: ${memo.updatedAt}');
  });

  return memos;
}

Future<void> deleteRecord(int id) async {
  Database db = await initializeDB();
  await db.delete(
    'memos',
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<void> updateMemoPinStatus(int id, bool isPinned) async {
  final db = await initializeDB();
  await db.update(
    'memos',
    {'isPinned': isPinned ? 1 : 0},
    where: 'id = ?',
    whereArgs: [id],
  );
}
