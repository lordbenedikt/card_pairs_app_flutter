import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:memory/models/card_set.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// import 'package:sqflite_ffi/sqflite_ffi.dart';

// TODO: Use Drift!!!
// Drift supports flutter web

class SqfliteHelper {
  static late final db;

  static init() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfi;
    }
    db = _getDatabase();
  }

  static Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    // sql.deleteDatabase(path.join(dbPath, 'memory.db'));
    return sql.openDatabase(
      path.join(dbPath, 'memory.db'),
      onCreate: (db, version) {
        return db
            .execute('CREATE TABLE images(url TEXT PRIMARY KEY, data BLOB);');
      },
      version: 1,
    );
  }

  static Future<Uint8List> getImage(String url) async {
    final table = await db.query('images', where: 'url = ?', whereArgs: [url]);
    if (table.isEmpty) {
      print('load image from network');
      return downloadImage(url);
    }
    print('load image from sqflite');
    return table.first['data'] as Uint8List;
  }

  static Future<Uint8List> downloadImage(String url) async {
    final storage = FirebaseStorage.instance;
    final reference = storage.refFromURL(url);
    final data = await reference.getData();

    db.insert(
      'images',
      {
        'url': url,
        'data': data,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    if (data == null) {
      throw ErrorDescription('image not found: $url');
    }

    return data;
  }

  // static Future<List<CardSet>> getCardSets() async {
  //   final db = await _getDatabase();
  //   final data = await db.query('card_sets');
  //   final cardSets = data.map((row) {
  //     return CardSet.fromJson(jsonDecode(row['json'] as String));
  //   }).toList();
  //   return cardSets;
  // }

  // static Future<String> localPathFromUrl(String url) async {
  //   final appDir = await syspaths.getApplicationDocumentsDirectory();
  //   final storage = FirebaseStorage.instance;
  //   final reference = storage.refFromURL(url);
  //   return '${appDir.path}/${reference.name}';
  // }

  // static void addCardSet(CardSet set) async {
  //   final db = await _getDatabase();

  //   for (final url in set.imageUrls) {
  //     final storage = FirebaseStorage.instance;
  //     final reference = storage.refFromURL(url);
  //     reference.writeToFile(File(await localPathFromUrl(url)));

  //     // db.insert(
  //     //   'images',
  //     //   {
  //     //     'url': url,
  //     //     'localPath': ,
  //     //   },
  //     //   conflictAlgorithm: ConflictAlgorithm.replace,
  //     // );
  //   }

  //   db.insert(
  //     'card_sets',
  //     {
  //       'uid': set.uid,
  //       'json': jsonEncode(set),
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }
}
