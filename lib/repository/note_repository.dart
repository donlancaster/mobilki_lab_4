import 'dart:math';

import 'package:notes/datasource/database_provider.dart';
import 'package:notes/entity/note.dart';

class NoteRepository {
  static final NoteRepository _singleton = NoteRepository._();

  final DBProvider _db = DBProvider.db;

  NoteRepository._();

  factory NoteRepository() => _singleton;

  Future<void> saveNote({required String title, String? description}) => _db.newNote(Note(
        id: title.hashCode + Random().nextInt(10000),
        title: title,
        description: description,
        dateCreated: DateTime.now(),
      ));

  Future<void> updateNote({required Note updatedNote}) => _db.updateNote(updatedNote);

  Future<void> deleteNote({required Note deletedNote}) => _db.deleteNote(deletedNote);

  Future<List<Note>> getNotes() async {
    final toRet = await _db.loadNotes();
    return toRet..sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
  }
}
