
import 'package:get/get.dart';
import 'package:shared_widgets/shared_widgets/handle_exception_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:yousentech_pos_loading_synchronizing_data/loading_sync/src/domain/loading_item_count_controller.dart';
import 'package:yousentech_pos_local_db/yousentech_pos_local_db.dart';

class GeneralLocalDB<T> {
  static late String tableName;
  late T Function(Map<String, dynamic> data) fromJson;
  static GeneralLocalDB? _instance;

  GeneralLocalDB._({required this.fromJson}) {
    _loadingItemsCountController.resetLoadingItemCount();
    tableName = T.toString().toLowerCase();
  }

  final LoadingItemsCountController _loadingItemsCountController =
      Get.put(LoadingItemsCountController());

  static GeneralLocalDB? getInstance<T>({required fromJsonFun}) {
    if (_instance != null && _instance!.getType() != T.toString()) {
      _instance = null;
    }
    _instance = _instance ?? GeneralLocalDB<T>._(fromJson: fromJsonFun);



    // if(_instance.runtimeType != T)
    // _instance = _instance ?? GeneralLocalDB<T>._(fromJson: fromJsonFun);
    // _instance = GeneralLocalDB<T>._(fromJson: fromJsonFun);
    return _instance;
  }

  Future createTable({required String structure}) async {
    try {
      await DbHelper.db!.execute('''
      CREATE TABLE IF NOT EXISTS $tableName ( $structure )
      ''');
    } catch (e) {
      return await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB createTable");
    }
  }

  Future<int> checkIfThereIsRowsInTable() async {
    try {
      final result = await DbHelper.db!.query(tableName, columns: ['COUNT(*)']);
      int count = result.first['COUNT(*)'] as int;
      return count;
    } catch (e) {
      throw await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB checkIfThereIsRowsInTable");
    }
  }

  Future<List<T>> index(
      {int? offset, int? limit, bool fromLocal = true, String? orderBy}) async {
    try {
      List<Map<String, dynamic>> result;
      if (offset != null) {
        result = await DbHelper.db!
            .query(tableName, offset: offset, limit: limit, orderBy: orderBy);
      } else {
        result = await DbHelper.db!.query(tableName, orderBy: orderBy);
      }

      return result.map((e) => fromJson(e)).toList();
    } catch (e) {
      throw await handleException(
          exception: e, navigation: false, methodName: "GeneralLocalDB index");

      // throw Exception(e.toString());
    }
  }

  Future getLastItem() async {
    try {
      var results = await DbHelper.db!.rawQuery('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1');
      return results;
    } catch (e) {
      throw await handleException(exception: e, navigation: false, methodName: "getLastItem");
    }
  }

  Future<int> count() async {
    try {
      var results = await DbHelper.db!
          .rawQuery('SELECT count(id) as count FROM $tableName LIMIT 1');

      return results[0]["count"] as int;
    } catch (e) {
      throw await handleException(
          exception: e, navigation: false, methodName: "count");
    }
  }

  Future show(
      {required dynamic val, required whereArg, bool saveinlog = true}) async {
    try {
      List<Map<String, dynamic>> result = await DbHelper.db!
          .query(tableName, limit: 1, where: '$whereArg = ?', whereArgs: [val]);
      return result.isNotEmpty ? fromJson(result.first) : "Empty Result";
    } catch (e) {
      throw  await handleException(
          exception: e, navigation: false, methodName: "GeneralLocalDB show");
    }
  }

  Future<List<T>> filter({required List whereArgs,required String where,String? orderBy,int? page,int limit = 25}) async {
    try {
      List<Map<String, Object?>> result;
      if (page != null) {
        result = await DbHelper.db!.query(tableName,
            where: where,
            whereArgs: whereArgs,
            // orderBy: orderBy,
            offset: page * limit,
            limit: limit);
      
      } else {
        result = await DbHelper.db!.query(tableName,where: where, whereArgs: whereArgs, orderBy: orderBy);
      }
      var dataFilter = result
          .map(
            (e) => fromJson(e),
          )
          .toList();
      return dataFilter;
    } catch (e) {
      throw Exception(e.toString());
    }
  }


  Future getIdsOnly() async {
    try {
      var query = await DbHelper.db!.rawQuery('''
          SELECT ${tableName != 'product' ? 'id' : 'product_id'}
          FROM $tableName
        ''');
      return query
          .map((e) => e[tableName != 'product' ? 'id' : 'product_id'])
          .toList();
    } catch (e) {
      throw  await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB getIdsOnly");
    }
  }

  Future<int> create(
      {required obj, bool isRemotelyAdded = false, Transaction? txn}) async {
    try {
      return await (txn ?? DbHelper.db)!.insert(
          tableName,
          obj is Map<String, dynamic>
              ? obj
              : obj.toJson(isRemotelyAdded: isRemotelyAdded),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      throw await handleException(
          exception: e, navigation: false, methodName: "GeneralLocalDB create");
    }
  }

  Future<int> createList({required List recordsList, Transaction? txn}) async {
    const batchSize = 10; // Adjust this size as needed
    return await DbHelper.db!.transaction((txn) async {
      int affectedRows = 0;
      try {
        for (int i = 0; i < recordsList.length; i += batchSize) {
          final batch = txn.batch();
          final chunk = recordsList.sublist(
              i,
              i + batchSize > recordsList.length
                  ? recordsList.length
                  : i + batchSize);
          for (var item in chunk) {
            _loadingItemsCountController.increaseLoadingItemCount();
            batch.insert(tableName, item.toJson(isRemotelyAdded: true),
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
          // for (var item in chunk) {
          //   _loadingItemsCountController.increaseLoadingItemCount();
          //   batch.insert(tableName, item.toJson(isRemotelyAdded: true));
          // }

          final List<dynamic> result = await batch.commit();
          affectedRows = result.reduce((sum, element) => sum + element);
        }
        return affectedRows;
      } catch (e) {
        throw  await handleException(
            exception: e,
            navigation: false,
            methodName: "GeneralLocalDB createList");
      }
    });
  }

  Future<int> update(
      {required dynamic id,
      required obj,
      required String whereField,
      // bool isRemotelyAdded = false
      bool isRemotelyAdded = true}) async {
    try {
      var result = await DbHelper.db!.update(
        tableName,
        obj is Map<String, dynamic>
            ? obj
            : obj.toJson(isRemotelyAdded: isRemotelyAdded),
        where: '$whereField = ?',
        whereArgs: [id],
      );

      return result;

    } catch (e) {

      throw await handleException(
          exception: e, navigation: false, methodName: "GeneralLocalDB update");
    }
  }

  Future<int> updateFields({required int id, required Map<String, dynamic> fields}) async {
    try {
      var result = await DbHelper.db!.update(
        tableName,
        fields,
        where: 'id = ?',
        whereArgs: [id],
      );

      return result;
    } catch (e) {

      // Handle the exception properly (you can modify this according to your needs)
      throw await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB updateFields"
      );
    }
  }

  Future<int> bulkUpdateFields({
    required List<Map<String, dynamic>> updates,
    String? quantityColumnName,
    String whereColumnName = 'id',
  }) async {
    int totalUpdated = 0;

    try {
      await DbHelper.db!.transaction((txn) async {
        for (var update in updates) {
          int id = update['id'];
          // Map<String, dynamic> fields = quantityColumnName != null ? update['value'] : update['fields'];
          var fields = quantityColumnName != null ? update['value'] : update['fields'];
          int result = 0;
          if (quantityColumnName == null) {
            result = await txn.update(
              tableName,
              fields,
              where: 'id = ?',
              whereArgs: [id],
            );
          } else {
            result = await txn.rawUpdate(
              'UPDATE $tableName SET $quantityColumnName = $quantityColumnName + ? WHERE $whereColumnName = ?',
              [fields, id],
            );
          }

          totalUpdated += result;
        }
      });

      return totalUpdated;
    } catch (e) {

      throw await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB updateFieldsBulk");
    }
  }



  Future<int> updateList(
      {required List recordsList,
      required String whereKey,
      List<int>? ids,
      bool isupdateSpecific = false}) async {
    int affectedRows = 0;

    try {
      return await DbHelper.db!.transaction((txn) async {
        final Batch batch = txn.batch();

        for (int i = 0; i < recordsList.length; i++) {
          batch.update(
              tableName,
              isupdateSpecific
                  ? recordsList[i].specificToJson()
                  : recordsList[i].toJson(isRemotelyAdded: true),
              where: '$whereKey = ?',
              whereArgs: [
                // ids != null ? ids[recordsList.indexOf(item)] : item!.id
                ids != null ? ids[i] : recordsList[i]!.id
              ]);
        }
        final List<dynamic> result = await batch.commit();
        affectedRows = result.reduce((sum, element) => sum + element);
        return affectedRows;
      });
    } catch (e) {
      throw await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB updateList");
    }
  }
  

  Future<int> updateListSaleOrderList(
      {required List recordsList,
      // required String whereKey,
      int? orderId}) async {
    int affectedRows = 0;

    try {
      return await DbHelper.db!.transaction((txn) async {
        final Batch batch = txn.batch();
        index();
        // for (var item in recordsList) {
        for (int i = 0; i < recordsList.length; i++) {
          // batch.update(tableName, item.toJson(isRemotelyAdded: true),
          //     where: 'order_id = ? and id = ?', whereArgs: [orderId, item!.id]);
          batch.update(tableName, recordsList[i].toJson(isRemotelyAdded: true),
              where: 'order_id = ? and product_id = ?',
              whereArgs: [orderId, recordsList[i]!.productId!.productId],
              conflictAlgorithm: ConflictAlgorithm.replace);

          // batch.update(tableName, item.toJson(isRemotelyAdded: true),
          //     where: 'order_id = ? and product_id = ?',
          //     whereArgs: [orderId, item!.productId!.productId],
          //     conflictAlgorithm: ConflictAlgorithm.replace);
        }
        final List<dynamic> result = await batch.commit();
        affectedRows = result.reduce((sum, element) => sum + element);

        return affectedRows;
      });
    } catch (e) {
      throw await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB updateList");
    }
  }

  Future checkRowExists(
      {required dynamic val, required String whereKey}) async {
    final result = await DbHelper.db!.query(
      tableName,
      where: '$whereKey = ?',
      whereArgs: [val],
    );
    return result.isNotEmpty;
  }

  Future<int> delete({required int id, required String whereField}) async {
    return await DbHelper.db!.delete(
      tableName,
      where: '$whereField = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteList(
      {required List recordsList, required String whereKey}) async {
    int affectedRows = 0;

    try {
      return await DbHelper.db!.transaction((txn) async {
        final Batch batch = txn.batch();
        for (var item in recordsList) {
          batch.delete(tableName, where: '$whereKey = ?', whereArgs: [item]);
        }
        final List<dynamic> result = await batch.commit();
        affectedRows = result.reduce((sum, element) => sum + element);
        return affectedRows;
      });
    } catch (e) {
      throw  await handleException(
          exception: e,
          navigation: false,
          methodName: "GeneralLocalDB deleteList");
      // return affectedRows;
    }
  }

  Future<int> deleteData() async {
    return await DbHelper.db!.delete(
      tableName,
    );
  }

  Future<void> dropTable() async {
    await DbHelper.db!.execute('DROP TABLE IF EXISTS $tableName');
  }

  String getType() {
    String runtimeType = this.runtimeType.toString();
    RegExp regExp = RegExp(r'<(.*?)>');
    Match? match = regExp.firstMatch(runtimeType);

    if (match != null) {
      return match.group(1)!;
    } else {
      throw handleException(
          exception: "No match found",
          navigation: false,
          methodName: "GeneralLocalDB getType");
    }
  }

    Future<int> countInvoice({required String whereKey}) async {
    try {
      var results = await DbHelper.db!.rawQuery('SELECT count(id) as count FROM $tableName WHERE $whereKey ');
      return results[0]["count"] as int;
    } catch (e) {
      throw await handleException(exception: e, navigation: false, methodName: "countInvoice");
    }
  }

  Future<bool> checkIfTableExists() async {
    final result = await DbHelper.db!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }
}
