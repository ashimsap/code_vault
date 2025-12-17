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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE snippets (
  id $idType,
  description $textType,
  codeContent $textType,
  mediaPaths $textType, -- Stored as a JSON string
  categories $textType, -- Stored as a JSON string
  creationDate $textType,
  lastModificationDate $textType,
  deviceSource $textType
)
''');
  }
}
