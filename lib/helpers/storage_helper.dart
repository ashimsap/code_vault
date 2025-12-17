import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StorageHelper {
  static final StorageHelper instance = StorageHelper._init();

  static Database? _database;

  StorageHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('snippets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // The line that was deleting the database has been removed.

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE snippets (
  id $idType,
  description $textType,
  fullDescription $textType,
  codeContent $textType,
  mediaPaths $textType,
  categories $textType,
  creationDate $textType,
  lastModificationDate $textType,
  deviceSource $textType
)
''');
  }

  // A simple migration strategy: add the new column if it doesn't exist.
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE snippets ADD COLUMN fullDescription TEXT NOT NULL DEFAULT \'\'');
    }
  }
}
