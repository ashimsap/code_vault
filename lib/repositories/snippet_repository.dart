import 'package:code_vault/helpers/storage_helper.dart';
import 'package:code_vault/models/snippet.dart';

class SnippetRepository {
  final StorageHelper _storageHelper;

  SnippetRepository(this._storageHelper);

  Future<Snippet> create(Snippet snippet) async {
    final db = await _storageHelper.database;
    final id = await db.insert('snippets', snippet.toDbJson()); // Use toDbJson()
    return snippet.copyWith(id: id);
  }

  Future<List<Snippet>> readAll() async {
    final db = await _storageHelper.database;
    final result = await db.query('snippets', orderBy: 'lastModificationDate DESC');
    return result.map((json) => Snippet.fromJson(json)).toList();
  }

  Future<int> update(Snippet snippet) async {
    final db = await _storageHelper.database;
    return db.update(
      'snippets',
      snippet.toDbJson(), // Use toDbJson()
      where: 'id = ?',
      whereArgs: [snippet.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _storageHelper.database;
    return db.delete(
      'snippets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
