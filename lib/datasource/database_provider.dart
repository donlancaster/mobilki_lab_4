import 'package:notes/entity/note.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  static final DBProvider db = DBProvider._inner();
  static Database? _database;

  static const _notesTable = 'Notes';

  DBProvider._inner();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'CustomDB.db');
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {},
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_notesTable ('
          '${Note.idField} INTEGER PRIMARY KEY,'
          '${Note.titleField} TEXT NOT NULL,'
          '${Note.descriptionField} TEXT,'
          '${Note.colorField} INTEGER NOT NULL,'
          '${Note.dateCreatedField} INTEGER NOT NULL'
          ')',
        );
      },
    );
  }

  Future<int> newNote(Note newNote) async {
    final db = await database;
    return await db.insert(_notesTable, newNote.toJson());
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(_notesTable, note.toJson(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(Note note) async {
    final db = await database;
    return await db.delete(_notesTable, where: 'id = ${note.id}');
  }

  Future<List<Note>> loadNotes() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $_notesTable'));
    if (count == 0) {
      return [];
    } else {
      final res = await db.query(_notesTable);
      final list = res.isNotEmpty ? res.map((c) => Note.fromJson(c)).toList() : [];
      return list as List<Note>;
    }
  }
}
