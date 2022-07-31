import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:starr/services/database_def.dart';
import 'package:starr/services/database_vars.dart';
import 'package:starr/services/globals.dart';



///
/// Bible Book Chapter Verse Class
///
class Verse {
  late int number;
  late String text;
  late String bookName;
  late int chapterNumber;
  late int bookNumber;
  late String bibleName;
  late String bibleVersion;
  late int isHighlighted;
  late int isBookmarked;
  late int updatedAt;

  ///
  /// Instantiate verse from database map
  ///
  Verse.fromDatabaseMap(Map<String, dynamic> map) {
    number = map[columnVerseNumber];
    text = map[columnText];
    chapterNumber = map[columnChapterNumber];
    bookNumber = map[columnBookNumber];
    bookName = map[columnBookName];
    bibleName = map[columnBibleName];
    bibleVersion = map[columnBibleVersion];
    isHighlighted = map[columnIsHighlighted];
    isBookmarked = map[columnIsBookmarked];
    updatedAt = map[columnUpdatedAt];
  }

  ///
  /// Instantiate verse from json map
  ///
  Verse.fromJsonMap(Map<String, dynamic> map,
      {required int chapterNumberParam,
      required int bookNumberParam,
      required String bookNameParam,
      required String bibleNameParam,
      required String bibleVersionParam}) {
    number = int.parse(map["_vnumber"].toString());

    if (map["__text"] == null) {
      text = "--";
    } else {
      text = map["__text"];
    }

    chapterNumber = chapterNumberParam;

    bookNumber = bookNumberParam;
    bookName = bookNameParam;

    bibleName = bibleNameParam;
    bibleVersion = bibleVersionParam;

    isHighlighted = 0;
    isBookmarked = 0;
    updatedAt = DateTime.now().millisecondsSinceEpoch;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnVerseNumber: number,
      columnText: text,
      columnChapterNumber: chapterNumber,
      columnBookName: bookName,
      columnBookNumber: bookNumber,
      columnBibleName: bibleName,
      columnBibleVersion: bibleVersion,
      columnIsHighlighted: isHighlighted,
      columnIsBookmarked: isBookmarked,
      columnUpdatedAt: updatedAt,
    };

    return map;
  }

  ///
  /// check whether book is OT
  ///
  bool isOldTestament() {
    return bookNumber <= 39;
  }

  ///
  /// check whether book is NT
  ///
  bool isNewTestament() {
    return bookNumber > 39;
  }

  String getVerseTitle() {
    return "$bookName $chapterNumber vs $number";
  }
}

///
/// Provider Class
///
class BibleProvider with ChangeNotifier {
  late String currentVersion;
  // late Bible currentBible;

  static const CURRENT_BIBLE_STRING = "current_bible_string";

  Future<bool> getBibles() async {
    await setCurrentVersionIfNotSet();
    if (await _databaseHasBibles() == false) {
      await _copyDatabaseToPath();
    }
    await initializeDB();

    notifyListeners();
    return true;
  }

  Future<void> initializeDB() async {
    String databasePath = await getDBName();
    db = await openDatabase(databasePath,
        version: 1, onCreate: (Database db, int version) async {});
  }

  Future<void> setCurrentVersionIfNotSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _currentVersion = prefs.getString(CURRENT_BIBLE_STRING);

    if (_currentVersion == null) {
      await setCurrentBible(versionsList.first);
    } else {
      await setCurrentBible(_currentVersion);
    }
  }

  Future<void> setCurrentBible(String version) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(CURRENT_BIBLE_STRING, version);
    currentVersion = version;
    notifyListeners();
  }

  Future<bool> _databaseHasBibles() async {
    String databasePath = await getDBName();
    return File(databasePath).existsSync();
  }

  Future<void> _copyDatabaseToPath() async {
    String databasePath = await getDBName();

    try {
      ByteData data = await rootBundle.load("assets/databases/bibles.db");
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(databasePath).writeAsBytes(bytes, flush: true);
    } catch (ex) {}
    return;
  }

  Future<String> getDBName() async {
    String databasePath = await getDatabasesPath();
    String databaseName = 'database.db';
    databasePath = databasePath + "/" + databaseName;
    return databasePath;
  }

  Future<List<Verse>> getOneVersePerBook() async {
    List<Verse> _verses = [];

    List<Map<String, Object?>> records = await db!.query(tableBibles,
        where:
            "$columnVerseNumber = ? AND $columnChapterNumber = ? AND $columnBibleVersion = ?",
        whereArgs: [1, 1, currentVersion],
        orderBy: "$columnBookNumber");
    if (records.isNotEmpty) {
      records.forEach((record) {
        _verses.add(Verse.fromDatabaseMap(record));
      });
    }
    return _verses;
  }

  Future<List<Verse>> getFirstVerseForChapterForBook(int bookNumber) async {
    List<Verse> _chapters = [];
    List<Map<String, Object?>> records = await db!.query(tableBibles,
        where:
            "$columnBookNumber = ? AND $columnVerseNumber = ? AND $columnBibleVersion = ?",
        whereArgs: [bookNumber, 1, currentVersion],
        orderBy: "$columnBookNumber");
    if (records.isNotEmpty) {
      records.forEach((record) {
        _chapters.add(Verse.fromDatabaseMap(record));
      });
    }
    return _chapters;
  }

  Future<bool> isChapterLastInBook(int chapterNumber,
      {required int bookNumber}) async {
    List<Map<String, Object?>> records = await db!.query(tableBibles,
        where:
            "$columnBookNumber = ? AND $columnChapterNumber > ? AND $columnBibleVersion = ?",
        whereArgs: [bookNumber, chapterNumber, currentVersion],
        orderBy: "$columnChapterNumber");
    return records.isEmpty;
  }

  Future<bool> isChapterFirstInBook(int chapterNumber,
      {required int bookNumber}) async {
    List<Map<String, Object?>> records = await db!.query(tableBibles,
        where:
            "$columnBookNumber = ? AND $columnChapterNumber < ? AND $columnBibleVersion = ?",
        whereArgs: [bookNumber, chapterNumber, currentVersion],
        orderBy: "$columnChapterNumber");
    return records.isEmpty;
  }

  Future<List<Verse>> getChapterVerses(int chapterNumber,
      {required int bookNumber}) async {
    List<Map<String, Object?>> records = await db!.query(tableBibles,
        where:
            "$columnBookNumber = ? AND $columnChapterNumber = ? AND $columnBibleVersion = ?",
        whereArgs: [bookNumber, chapterNumber, currentVersion],
        orderBy: "$columnChapterNumber");
    List<Verse> _verses = [];
    if (records.isNotEmpty) {
      records.forEach((record) {
        _verses.add(Verse.fromDatabaseMap(record));
      });
    }
    return _verses;
  }

  Future<List<Verse>> search(String search,
      {bool matchExactPhrase = false,
      bool searchOT = true,
      bool searchNT = true}) async {
    List<Map<String, Object?>> records = [];
    if (matchExactPhrase) {
      records = await _findWholeWordsExactPhrase(search);
    } else if (matchExactPhrase == false) {
      records = await _findPartialWordsNonExactPhrase(search);
    }

    List<Verse> _verses = [];
    if (records.isNotEmpty) {
      records.forEach((record) {
        Verse _verse = Verse.fromDatabaseMap(record);
        if ((_verse.isNewTestament() == searchNT &&
                _verse.isOldTestament() != searchNT) ||
            (_verse.isOldTestament() == searchOT &&
                _verse.isNewTestament() != searchOT)) {
          _verses.add(_verse);
        }
      });
    }
    return _verses;
  }

  Future<List<Map<String, Object?>>> _findWholeWordsExactPhrase(
      String search) async {
    return await db!.query(tableBibles,
        where: "$columnText LIKE ?",
        whereArgs: ["% $search %"],
        orderBy: "$columnBookNumber");
  }

  Future<List<Map<String, Object?>>> _findPartialWordsNonExactPhrase(
      String search) async {
    String formartedString = search.toLowerCase().trim().replaceAll(" ", "%");
    return await db!.query(tableBibles,
        where: "$columnText LIKE ?",
        whereArgs: ["%$formartedString%"],
        orderBy: "$columnBookNumber");
  }

  Future<void> bookmark(List<Verse> selectedVerses) async {
    selectedVerses.forEach((Verse verse) {
      Map<String, Object> updatedFields = {
        columnUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        columnIsBookmarked: verse.isBookmarked == 1 ? 0 : 1
      };
      db!.update(tableBibles, updatedFields,
          where:
              "$columnBookNumber = ? AND $columnChapterNumber = ? AND $columnVerseNumber = ?",
          whereArgs: [verse.bookNumber, verse.chapterNumber, verse.number]);
    });
    notifyListeners();
  }
}
