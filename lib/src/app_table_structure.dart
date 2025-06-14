class LocalDatabaseStructure {
  static String dbDefaultName = "mydb.db";
  //odoo_id INTEGER,
  // static String productStructure = """
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       product_id INTEGER,
  //       product_name TEXT,
  //       detailed_type TEXT,
  //       product_tmpl_id INTEGER,
  //       pos_available INTEGER,
  //       uom_id INTEGER,
  //       so_pos_categ_id INTEGER,
  //       categ_id TEXT,
  //       barcode TEXT,
  //       unit_price REAL,
  //       currency TEXT,
  //       default_code TEXT,
  //       image TEXT,
  //       quick_menu_availability INTEGER,
  //       available_qty REAL,
  //       taxes_id TEXT,
  //       record_hash TEXT,
  //       discount_value REAL,
  //       discount_control INTEGER""";

  // last 8 fields for price control
  static String productStructure = """
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      product_id INTEGER,
      product_name TEXT,
      detailed_type TEXT,
      product_tmpl_id INTEGER,
      pos_available INTEGER,
      uom_id INTEGER,
      so_pos_categ_id INTEGER,
      categ_id TEXT,
      barcode TEXT,
      unit_price REAL,
      currency TEXT,
      default_code TEXT,
      image TEXT,
      quick_menu_availability INTEGER,
      available_qty REAL,
      taxes_id TEXT,
      record_hash TEXT,
      discount_value REAL,
      discount_control INTEGER,
      
      standard_price REAL,
      maximum_price REAL,
      minimum_price REAL,
      priority_for_product INTEGER,
      from_product_cost INTEGER,
      pro_cost_incrse_percentage REAL,
      product_price_readonly INTEGER,
      price_fields_readonly INTEGER
      """;

static String posCategoryStructure = """
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      parent_id INTEGER,
      parent_name TEXT,
      discount_value REAL,
      discount_control INTEGER""";
  // name TEXT""";
      static String productUnitStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT""";

// id INTEGER PRIMARY KEY AUTOINCREMENT,
static String customerStructure = """
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT,
      phone TEXT,
      image_1920 TEXT,
      vat TEXT,
      customer_rank INTEGER,
      street TEXT,
      city TEXT,
      country_id TEXT,
      Postal_code TEXT,
      District TEXT,
      additional_no TEXT,
      l10n_sa_edi_plot_identification TEXT,
      building_no TEXT,
      other_seller_id TEXT,
      company_id INTEGER,
      is_company INTEGER,
      pay_type  TEXT
      """;

// id INTEGER PRIMARY KEY AUTOINCREMENT,
      static String notificationStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subscription_detail_id INTEGER,
            ticket_reply TEXT,
            create_date TEXT,
            exception_details TEXT,
            stauts INTEGER,
            user_id INTEGER,
            pos_id INTEGER,
            is_read INTEGER
      """;
      static String userStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            password TEXT,
            pincode TEXT""";

      static String posSessionStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pos_id INTEGER,
            user_id INTEGER,
            user_name TEXT,
            state TEXT,
            start_date TEXT,
            end_date TEXT,
            payment_session REAL,
            balance_opening REAL,
            last_end_date TEXT,
            last_balance_opening REAL,
            closing_amount REAL,
            closing_amount_diff REAL,
            closing_amount_set INTEGER,
            total_sales REAL
            """;

      static String accountTaxStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            amount REAL,
            price_include INTEGER""";

      static String accountJournalStructure = """
            id INTEGER PRIMARY KEY,
            name TEXT,
            is_default_journal INTEGER,
            pos_preferred_payment_method INTEGER,
            type TEXT""";

  // id INTEGER PRIMARY KEY AUTOINCREMENT,
      static String saleOrderStructure = """
            id INTEGER PRIMARY KEY,
            invoice_name TEXT,
            partner_id INTEGER,
            picking_id INTEGER,
            invoice_id INTEGER,
            partner_name TEXT,
            date_order TEXT,
            user_id INTEGER,
            warehouse_id INTEGER,
            session_number INTEGER,
            tmp_journal_id INTEGER,
            note TEXT,
            state TEXT,
            is_draft_synchroniz INTEGER,
            is_draft_update INTEGER,
            total_price REAL, 
            remaining REAL,
            change REAL,
            discount_amount REAL,
            total_price_subtotal REAL,
            total_taxes REAL,
            total_discount REAL,
            total_quantity REAL,
            type_of_discount TEXT,
            invoice_chosen_payment TEXT,
            move_type TEXT,
            create_date TEXT,
            has_refund INTEGER,
            zatca_qr_code TEXT,
            is_paid_invoice_synchronized INTEGER,
            failure_synchronization_reason TEXT,
            local_remote_inv_amount_diff TEXT,
            reason TEXT,
            original_invoice_id TEXT,
            payment_ids TEXT,
            save_invoice_as_draft_for_process INTEGER,
            FOREIGN KEY(user_id) REFERENCES user(id),
            FOREIGN KEY(session_number) REFERENCES possession(id)
            """;
  // FOREIGN KEY(original_invoice_id) REFERENCES saleorder(id) ON DELETE SET NULL

  // id INTEGER PRIMARY KEY AUTOINCREMENT,
      static String saleOrderLineStructure = """
            id INTEGER PRIMARY KEY,
            product_id INTEGER,
            name TEXT,
            product_uom_qty INTEGER,
            product_uom INTEGER,
            discount REAL,
            price_unit REAL,
            tax_id TEXT,
            order_id INTEGER,
            order_partner_id INTEGER,
            note TEXT,
            total_price REAL,
            total_price_subtotal REAL,
            tax REAL,
            type_of_discount TEXT,
            discount_as_percentage REAL,
            total_discount REAL,
            FOREIGN KEY(product_id) REFERENCES product(id),
            FOREIGN KEY(product_uom) REFERENCES productunit(id),
            FOREIGN KEY(order_id) REFERENCES saleorderinvoice(id)
            """;

      static String appConnectedPrinters = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            printer_name TEXT,
            system_printer_name TEXT,
            paper_type TEXT,
            printer_ip TEXT,
            category_ids TEXT""";

      static String userSalePriceStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            odoo_id INTEGER,
            user_id INTEGER,
            product_category_id INTEGER,
            company_id INTEGER,
            maximum_percentage REAL,
            minimum_percentage REAL
      """;

      static String categorySalePriceStructure = """
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            odoo_id INTEGER,
            user_id INTEGER,
            product_category_id INTEGER,
            company_id INTEGER,
            maximum_percentage REAL,
            minimum_percentage REAL
      """;

  // static String paymentStructure = """
  //       id INTEGER PRIMARY KEY,
  //       name TEXT""";

  //
  // static String itemHistoryStructure = """
  //     id INTEGER PRIMARY KEY AUTOINCREMENT,
  //     is_added INTEGER,
  //     type_name TEXT,
  //     product_id INTEGER,
  //     customer_id INTEGER,
  //     pos_category_id INTEGER,
  //     FOREIGN KEY (product_id) REFERENCES product(id),
  //     FOREIGN KEY (customer_id) REFERENCES customer(id),
  //     FOREIGN KEY (pos_category_id) REFERENCES poscategory(id)
  //     """;
}
