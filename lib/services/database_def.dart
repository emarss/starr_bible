import 'package:sqflite/sqflite.dart';
// import 'package:starr/services/database_vars.dart';

String databaseName = 'database.db';
Database? db;

Future openOrCreateDatabase() async {
  String databasePath = await getDatabasesPath();
  databasePath = databasePath+"/" + databaseName;


  await deleteDatabase(databasePath);

  // db = await openDatabase(databasePath, version: 1,
  //     onCreate: (Database db, int version) async {
  //   await db.execute('''
  //       create table $tableNotes ( 
	// 		$columnUuid TEXT NOT NULL,
      
  //     $columnContent TEXT NOT NULL,
  //     $columnIsPinned INT NOT NULL,
  //     $columnIsArchived INT NOT NULL,

	// 		$columnUpdatedAt INTEGER NOT NULL,
  //     $columnDeletedAt INTEGER,
	// 		$columnCreatedAt INTEGER NOT NULL)
  //       ''');

  //   await db.execute('''
  //       create table $tableBibles ( 
  //     $columnVerseNumber INT NOT NULL,
  //     $columnText TEXT NOT NULL,
  //     $columnChapterNumber INT NOT NULL,
  //     $columnBookName TEXT NOT NULL,
  //     $columnBookNumber INT NOT NULL,
  //     $columnBibleName TEXT NOT NULL,
  //     $columnBibleVersion TEXT NOT NULL,

  //     $columnIsHighlighted INT NOT NULL,
  //     $columnIsBookmarked INT NOT NULL,

	// 		$columnUpdatedAt INTEGER NOT NULL)
  //       ''');
  // });
}
