import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memory/models/card_set.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class SqfliteHelper {
  static Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    // sql.deleteDatabase(path.join(dbPath, 'memory.db'));
    return sql.openDatabase(
      path.join(dbPath, 'memory.db'),
      onCreate: (db, version) {
        return db
            .execute('CREATE TABLE card_sets(uid TEXT PRIMARY KEY, json TEXT);'
                'CREATE TABLE images(url TEXT PRIMARY KEY, localPath TEXT);');
      },
      version: 1,
    );
  }

  static Future<List<CardSet>> getCardSets() async {
    final db = await _getDatabase();
    final data = await db.query('card_sets');
    final cardSets = data.map((row) {
      return CardSet.fromJson(jsonDecode(row['json'] as String));
    }).toList();
    return cardSets;
  }

  static Future<String> localPathFromUrl(String url) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final storage = FirebaseStorage.instance;
    final reference = storage.refFromURL(url);
    return '${appDir.path}/${reference.name}';
  }

  static void addCardSet(CardSet set) async {
    final db = await _getDatabase();

    for (final url in set.imageUrls) {
      final storage = FirebaseStorage.instance;
      final reference = storage.refFromURL(url);
      reference.writeToFile(File(await localPathFromUrl(url)));

      // db.insert(
      //   'images',
      //   {
      //     'url': url,
      //     'localPath': ,
      //   },
      //   conflictAlgorithm: ConflictAlgorithm.replace,
      // );
    }

    db.insert(
      'card_sets',
      {
        'uid': set.uid,
        'json': jsonEncode(set),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
