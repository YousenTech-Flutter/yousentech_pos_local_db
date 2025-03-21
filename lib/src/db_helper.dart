// ignore_for_file: empty_catches, unused_local_variable

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yousentech_pos_local_db/yousentech_pos_local_db.dart';

class DbHelper {
  static DbHelper? _instance;
  static Database? db;
  static String? dataBasePath;
  static String? backupPath;

  DbHelper._();

  static Future<DbHelper> getInstance() async {
    db = await _openDatabase();
    _instance ??= DbHelper._();
    return _instance!;
  }

  static Future<io.Directory> dbPath() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return (await path_provider.getDownloadsDirectory())!;
    }

    return await path_provider.getApplicationSupportDirectory();
  }

  static Future<Database> _openDatabase() async {
    final io.Directory appDocumentsDir;
    if (Platform.isAndroid || Platform.isIOS) {
      appDocumentsDir = (await path_provider.getDownloadsDirectory())!;
    } else {
      appDocumentsDir = await path_provider.getApplicationSupportDirectory();
    }
    // final io.Directory appDocumentsDir = await path_provider.getApplicationSupportDirectory();
    dataBasePath = join(appDocumentsDir.path, "databases",
        LocalDatabaseStructure.dbDefaultName);
    if (io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux) {
      var databaseFactory = databaseFactoryFfi;
      return await databaseFactory.openDatabase(
        dataBasePath!,
        options: OpenDatabaseOptions(
          version: 38,
          onCreate: (Database dbx, int version) async {
            db = dbx;
            await DBHelper.createDBTables();
          },
          onUpgrade: (Database dbx, int oldVersion, int newVersion) async {
            await _migrateDatabase(dbx, oldVersion, newVersion);
          },
        ),
      );
      // if (io.Platform.isAndroid || io.Platform.isIOS)
    } else {
      var databaseFactory = databaseFactoryFfi;
      return await openDatabase(
        dataBasePath!,
        version: 38,
        onCreate: (Database dbx, int version) async {
          db = dbx;
          // var cursor = await db!.rawQuery("SELECT sqlite_version()", null);
          // print("cursor======$cursor");
          await DBHelper.createDBTables();
        },
        onUpgrade: (Database dbx, int oldVersion, int newVersion) async {
          await _migrateDatabase(dbx, oldVersion, newVersion);
        },
      );
    }
  }

  static Future<void> _migrateDatabase(
      Database dbx, int oldVersion, int newVersion) async {
    if (oldVersion < 38) {}
  }

  static Future<void> backupDatabase() async {
    io.Directory appDocDir = await dbPath();
    backupPath = join(appDocDir.path, 'mydb_backup.db');

    if (!await io.File(backupPath!).exists()) {
      await io.File(backupPath!).create(recursive: true);
    }

    if (await io.File(backupPath!).exists()) {
      await io.File(backupPath!).delete();
    }
    await io.File(dataBasePath!).copy(backupPath!);
  }

  static Future<void> restoreDatabase() async {
    await closeDatabase();
    if (await io.File(backupPath!).exists()) {
      Uint8List updatedContent = await io.File(backupPath!).readAsBytes();
      await io.File(dataBasePath!).writeAsBytes(updatedContent, flush: true);
      await io.File(backupPath!).delete();
      await getInstance();
    }
  }

  static Future<void> closeDatabase() async {
    try {
      if (db != null) {
        await db!.close();
      }
    } catch (e) {}
  }

  static Future<bool> testJsonExtract() async {
    try {
      // Execute a query to test json_extract
      final result = await db!.rawQuery(
          "SELECT json_extract('{\"name\": \"Alice\", \"age\": 30}', '\$.name') AS name;");
      return true;
    } catch (e) {
      return false;
    }
  }
}
