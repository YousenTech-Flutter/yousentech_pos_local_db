// ignore_for_file: empty_catches

import 'dart:io' as io;
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pos_shared_preferences/models/account_journal/data/account_journal.dart';
import 'package:pos_shared_preferences/models/account_tax/data/account_tax.dart';
import 'package:pos_shared_preferences/models/authentication_data/user.dart';
import 'package:pos_shared_preferences/models/category_sale_price.dart';
import 'package:pos_shared_preferences/models/customer_model.dart';
import 'package:pos_shared_preferences/models/pos_categories_data/pos_category.dart';
import 'package:pos_shared_preferences/models/pos_session/posSession.dart';
import 'package:pos_shared_preferences/models/printing/data/connected_printer.dart';
import 'package:pos_shared_preferences/models/product_data/product.dart';
import 'package:pos_shared_preferences/models/product_unit/data/product_unit.dart';
import 'package:pos_shared_preferences/models/remote_support_ticket.dart';
import 'package:pos_shared_preferences/models/sale_order.dart';
import 'package:pos_shared_preferences/models/sale_order_line.dart';
import 'package:pos_shared_preferences/models/user_sale_price.dart';
import 'package:shared_widgets/shared_widgets/handle_exception_helper.dart';
import 'package:yousentech_pos_local_db/src/app_table_structure.dart';
import 'package:yousentech_pos_local_db/src/general_local_db.dart';

class DBHelper {
  static createDBTables() async {
    await createDBTable<RemoteSupportTicket>(
        fromJson: RemoteSupportTicket.fromJson,
        structure: LocalDatabaseStructure.notificationStructure);
    await createDBTable<Customer>(
        fromJson: Customer.fromJson,
        structure: LocalDatabaseStructure.customerStructure);
    await createDBTable<PosCategory>(
        fromJson: PosCategory.fromJson,
        structure: LocalDatabaseStructure.posCategoryStructure);
    await createDBTable<Product>(
        fromJson: Product.fromJson,
        structure: LocalDatabaseStructure.productStructure);
    await createDBTable<ProductUnit>(
        fromJson: ProductUnit.fromJson,
        structure: LocalDatabaseStructure.productUnitStructure);
    await createDBTable<PosSession>(
        fromJson: PosSession.fromJson,
        structure: LocalDatabaseStructure.posSessionStructure);
    await createDBTable<AccountTax>(
        fromJson: AccountTax.fromJson,
        structure: LocalDatabaseStructure.accountTaxStructure);
    await createDBTable<SaleOrderInvoice>(
        fromJson: SaleOrderInvoice.fromJson,
        structure: LocalDatabaseStructure.saleOrderStructure);
    await createDBTable<SaleOrderLine>(
        fromJson: SaleOrderLine.fromJson,
        structure: LocalDatabaseStructure.saleOrderLineStructure);
    await createDBTable<ConnectedPrinter>(
        fromJson: ConnectedPrinter.fromJson,
        structure: LocalDatabaseStructure.appConnectedPrinters);
    await createDBTable<AccountJournal>(
        fromJson: AccountJournal.fromJson,
        structure: LocalDatabaseStructure.accountJournalStructure);
    await createDBTable<User>(
        fromJson: User.fromJson,
        structure: LocalDatabaseStructure.userStructure);
    
    await createDBTable<UserSalePrice>(
        fromJson: UserSalePrice.fromJson,
        structure: LocalDatabaseStructure.userSalePriceStructure);
    await  createDBTable<CategorySalePrice>(
        fromJson: CategorySalePrice.fromJson,
        structure: LocalDatabaseStructure.categorySalePriceStructure);

  }

  static dropDBData({isDeleteBasicData = false}) async {
    await deleteTableRows<Customer>(fromJson: Customer.fromJson);
    await deleteTableRows<PosCategory>(fromJson: PosCategory.fromJson);
    await deleteTableRows<Product>(fromJson: Product.fromJson);
    await deleteTableRows<ProductUnit>(fromJson: ProductUnit.fromJson);
    if (!isDeleteBasicData) {
      await deleteTableRows<User>(fromJson: User.fromJson);
    }
    await deleteTableRows<PosSession>(fromJson: PosSession.fromJson);
    await deleteTableRows<AccountTax>(fromJson: AccountTax.fromJson);
    await deleteTableRows<SaleOrderLine>(fromJson: SaleOrderLine.fromJson);
    await deleteTableRows<SaleOrderInvoice>(
        fromJson: SaleOrderInvoice.fromJson);
    await deleteTableRows<AccountJournal>(fromJson: AccountJournal.fromJson);
    await deleteTableRows<ConnectedPrinter>(
        fromJson: ConnectedPrinter.fromJson);

    
    await deleteTableRows<UserSalePrice>(fromJson: UserSalePrice.fromJson);
    await deleteTableRows<CategorySalePrice>(
        fromJson: CategorySalePrice.fromJson);
  }

  static dropDBTable({isDeleteBasicData = false}) async {
    await dropTable<RemoteSupportTicket>(
        fromJson: RemoteSupportTicket.fromJson);
    await dropTable<Customer>(fromJson: Customer.fromJson);
    await dropTable<PosCategory>(fromJson: PosCategory.fromJson);

    await dropTable<Product>(fromJson: Product.fromJson);
    await dropTable<ProductUnit>(fromJson: ProductUnit.fromJson);

    await dropTable<User>(fromJson: User.fromJson);
    await dropTable<PosSession>(fromJson: PosSession.fromJson);

    await dropTable<AccountTax>(fromJson: AccountTax.fromJson);
    await dropTable<SaleOrderInvoice>(fromJson: SaleOrderInvoice.fromJson);

    await dropTable<SaleOrderLine>(fromJson: SaleOrderLine.fromJson);
    await dropTable<ConnectedPrinter>(fromJson: ConnectedPrinter.fromJson);

    await dropTable<AccountJournal>(fromJson: AccountJournal.fromJson);


    await dropTable<UserSalePrice>(fromJson: UserSalePrice.fromJson);
    await dropTable<CategorySalePrice>(fromJson: CategorySalePrice.fromJson);
  }

  static deleteFile() async {
    final io.Directory directory ;
    if (Platform.isAndroid || Platform.isIOS) {
      directory = (await path_provider.getDownloadsDirectory())!;
    }
    else{
      directory = await path_provider.getApplicationSupportDirectory();
    }
    
    final filePath = path.join(directory.path, "databases", LocalDatabaseStructure.dbDefaultName);
    final file = File(filePath);

    if (file.existsSync()) {
      try {
        file.deleteSync();
      } catch (e) {}
    } else {}
  }

  static Future<void> createDBTable<T>({required fromJson, required String structure}) async {
    try {
      GeneralLocalDB? generalLocalDBInstance =
          GeneralLocalDB.getInstance<T>(fromJsonFun: fromJson);
      await generalLocalDBInstance!.createTable(structure: structure);
    } catch (e) {
      handleException(
          exception: e, navigation: false, methodName: "createDBTable");
    }
  }

  static Future deleteTableRows<T>({required fromJson}) async {
    GeneralLocalDB? generalLocalDBInstance =
        GeneralLocalDB.getInstance<T>(fromJsonFun: fromJson);
    return await generalLocalDBInstance!.deleteData();
  }

  static Future dropTable<T>({required fromJson}) async {
    GeneralLocalDB? generalLocalDBInstance =
        GeneralLocalDB.getInstance<T>(fromJsonFun: fromJson);
    return await generalLocalDBInstance!.dropTable();
  }
}
