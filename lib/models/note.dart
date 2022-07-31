import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:starr/services/database_def.dart';
import 'package:starr/services/database_vars.dart';
import 'package:starr/services/globals.dart';
import 'package:uuid/uuid.dart';

class Note {
  String? uuid;

  String? title;
  String? content;
  int? isPinned;
  int? isArchived;

  int? createdAt;
  int? updatedAt;
  int? deletedAt;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnContent: content,
      columnIsPinned: isPinned,
      columnIsArchived: isArchived,
    };
    if (uuid == null) {
      map[columnUuid] = Uuid().v1();
    } else {
      map[columnUuid] = uuid;
    }
    if (createdAt != null) {
      map[columnCreatedAt] = createdAt;
    }
    if (updatedAt != null) {
      map[columnUpdatedAt] = updatedAt;
    }
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    uuid = map[columnUuid];

    title = map[columnTitle];
    content = map[columnContent];
    isPinned = map[columnIsPinned];
    isArchived = map[columnIsArchived];

    deletedAt =
        map[columnDeletedAt] == null ? null : (map[columnDeletedAt]).toInt();

    createdAt = map[columnCreatedAt] != null
        ? (map[columnCreatedAt]).toInt()
        : DateTime.now().millisecondsSinceEpoch;
    updatedAt = map[columnUpdatedAt] != null
        ? (map[columnUpdatedAt]).toInt()
        : DateTime.now().millisecondsSinceEpoch;
  }

  String getExcept() {
    if (content != null) {
      if (content!.isNotEmpty) {
        return getExceptFromQuillPlainText(content!);
      }
    }
    return "";
  }

  bool hasContent() {
    if (content != null) {
      if (content!.isNotEmpty) {
        return Bidi.stripHtmlIfNeeded(content!).trim().isNotEmpty;
      }
    }
    return false;
  }

  bool hasExcept() {
    if (getExcept().isNotEmpty) {
      return true;
    }
    return false;
  }

  bool isTrashed() {
    if (deletedAt != 0 && deletedAt != null) {
      return true;
    }
    return false;
  }

  String getPinStatus() {
    return isPinned == 1 ? "Yes" : "No";
  }

  String getArchiveStatus() {
    return isArchived == 1 ? "Yes" : "No";
  }

  String getCreatedAt() {
    var date = DateTime.fromMillisecondsSinceEpoch(createdAt!);
    return DateFormat.yMMMd().add_jm().format(date).toString();
  }

  String getUpdatedAt() {
    var date = DateTime.fromMillisecondsSinceEpoch(updatedAt!);
    return DateFormat.yMMMd().add_jm().format(date).toString();
  }
}

///
/// Provider Class
///
class NoteProvider with ChangeNotifier {
  List<Note> notesList = [];

  Future<void> getAllNotes() async {
    List<Map<String, dynamic>> records =
        await db!.query(tableNotes, orderBy: "$columnCreatedAt DESC");

    List<Note> _notes = [];
    if (records.length > 0) {
      for (int i = 0; i < records.length; i++) {
        _notes.add(Note.fromMap(records[i]));
      }
    }
    notesList = _notes;
    notifyListeners();
  }

  ///
  /// insert record to database
  ///
  Future<Note> insert(Note note) async {
    await db!.insert(tableNotes, note.toMap());
    await getAllNotes();
    List<Map<String, Object?>> records =
        await db!.query(tableNotes, orderBy: "$columnCreatedAt DESC");
    return Note.fromMap(records.first);
  }

  ///
  /// pin note
  ///
  Future<void> pin(String uuid, int currentValue) async {
    int updatedAt = DateTime.now().millisecondsSinceEpoch;
    await db!.update(
        tableNotes,
        {
          columnIsPinned: currentValue == 1 ? 0 : 1,
          columnUpdatedAt: updatedAt,
        },
        where: '$columnUuid = ?',
        whereArgs: [uuid]);
    await getAllNotes();
  }

  ///
  /// archive note
  ///
  Future<void> archive(String uuid, int currentValue) async {
    int updatedAt = DateTime.now().millisecondsSinceEpoch;
    await db!.update(
        tableNotes,
        {
          columnIsArchived: currentValue == 1 ? 0 : 1,
          columnUpdatedAt: updatedAt,
        },
        where: '$columnUuid = ?',
        whereArgs: [uuid]);
    await getAllNotes();
  }

  ///
  /// trash record in database
  ///
  Future<void> trash(String uuid) async {
    int deletedAt = DateTime.now().millisecondsSinceEpoch;
    await db!.update(
        tableNotes,
        {
          columnDeletedAt: deletedAt,
          columnUpdatedAt: deletedAt,
        },
        where: '$columnUuid = ?',
        whereArgs: [uuid]);
    await getAllNotes();
  }

  ///
  /// trash record in database
  ///
  Future<void> restore(String uuid) async {
    int updatedAt = DateTime.now().millisecondsSinceEpoch;
    await db!.update(
        tableNotes,
        {
          columnDeletedAt: 0,
          columnUpdatedAt: updatedAt,
        },
        where: '$columnUuid = ?',
        whereArgs: [uuid]);
    await getAllNotes();
  }

  ///
  /// delete record from database
  ///
  Future<void> delete(String uuid) async {
    await db!.delete(tableNotes, where: '$columnUuid = ?', whereArgs: [uuid]);
    await getAllNotes();
  }

  ///
  /// update record in database
  ///
  Future<void> update(Note note) async {
    await db!.update(tableNotes, note.toMap(),
        where: '$columnUuid = ?', whereArgs: [note.uuid]);
    getAllNotes();
  }

  ///
  /// find record in database
  ///
  Future<Note> find(String uuid) async {
    List<Map<String, Object?>> records = await db!
        .query(tableNotes, where: '$columnUuid = ?', whereArgs: [uuid]);
    return Note.fromMap(records.first);
  }
}
