import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/hotel_details.dart';
import '../models/category.dart' as cat;
import '../models/item.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join((await getApplicationDocumentsDirectory()).path, 'pos_database.db');
    print('DatabaseHelper: Opening database at path: $path');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        print('DatabaseHelper: Database opened successfully');
        // Ensure default data exists
        await _ensureDefaultData(db);
      },
    );
  }

  Future<void> _ensureDefaultData(Database db) async {
    // Check if categories exist
    final categories = await db.query('categories', where: 'active = 1');
    if (categories.isEmpty) {
      await _insertDefaultCategories(db);
    }

    // Check if items exist
    final items = await db.query('items', where: 'active = 1');
    if (items.isEmpty) {
      await _insertDefaultItems(db);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    await db.insert('categories', {'name': 'Food', 'active': 1});
    await db.insert('categories', {'name': 'Drinks', 'active': 1});
    await db.insert('categories', {'name': 'Desserts', 'active': 1});
  }

  Future<void> _insertDefaultItems(Database db) async {
    await db.insert('items', {
      'name': 'Pizza',
      'categoryId': 1,
      'price': 15.0,
      'gstPercent': 18.0,
      'active': 1,
    });
    await db.insert('items', {
      'name': 'Burger',
      'categoryId': 1,
      'price': 10.0,
      'gstPercent': 18.0,
      'active': 1,
    });
    await db.insert('items', {
      'name': 'Coke',
      'categoryId': 2,
      'price': 2.0,
      'gstPercent': 18.0,
      'active': 1,
    });
    await db.insert('items', {
      'name': 'Ice Cream',
      'categoryId': 3,
      'price': 5.0,
      'gstPercent': 18.0,
      'active': 1,
    });
    await db.insert('items', {
      'name': 'Cake',
      'categoryId': 3,
      'price': 20.0,
      'gstPercent': 18.0,
      'active': 1,
    });
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE hotel_details (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, contact TEXT NOT NULL, address TEXT NOT NULL, gstin TEXT NOT NULL, email TEXT NOT NULL, logoPath TEXT, backgroundPath TEXT)''');
    await db.execute('''CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, active INTEGER NOT NULL)''');
    await db.execute('''CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, categoryId INTEGER NOT NULL, price REAL NOT NULL, gstPercent REAL NOT NULL, imagePath TEXT, active INTEGER NOT NULL, FOREIGN KEY (categoryId) REFERENCES categories (id))''');
    await db.execute('''CREATE TABLE invoices (id INTEGER PRIMARY KEY AUTOINCREMENT, invoiceNumber TEXT, customerName TEXT NOT NULL, contact TEXT NOT NULL, tableNumber TEXT, gstApplied INTEGER NOT NULL, total REAL NOT NULL, date TEXT NOT NULL)''');
    await db.execute('''CREATE TABLE invoice_items (id INTEGER PRIMARY KEY AUTOINCREMENT, invoiceId INTEGER NOT NULL, itemId INTEGER NOT NULL, quantity INTEGER NOT NULL, price REAL NOT NULL, FOREIGN KEY (invoiceId) REFERENCES invoices (id), FOREIGN KEY (itemId) REFERENCES items (id))''');

    // Insert default hotel details
    await db.insert('hotel_details', {
      'name': 'Sample Restaurant',
      'contact': '123-456-7890',
      'address': '123 Main St, City, State',
      'gstin': 'GSTIN123456',
      'email': 'info@samplerestaurant.com',
    });

    // Insert default categories
    await db.insert('categories', {'name': 'Food', 'active': 1});
    await db.insert('categories', {'name': 'Drinks', 'active': 1});

    // Insert default items
    await db.insert('items', {
      'name': 'Pizza',
      'categoryId': 1,
      'price': 15.0,
      'gstPercent': 18.0,
      'active': 1,
    });
    await db.insert('items', {
      'name': 'Burger',
      'categoryId': 1,
      'price': 10.0,
      'gstPercent': 18.0,
      'active': 1,
    });
    await db.insert('items', {
      'name': 'Coke',
      'categoryId': 2,
      'price': 2.0,
      'gstPercent': 18.0,
      'active': 1,
    });
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Insert additional dummy data
      await db.insert('categories', {'name': 'Desserts', 'active': 1});
      await db.insert('items', {
        'name': 'Ice Cream',
        'categoryId': 3,
        'price': 5.0,
        'gstPercent': 18.0,
        'active': 1,
      });
      await db.insert('items', {
        'name': 'Cake',
        'categoryId': 3,
        'price': 20.0,
        'gstPercent': 18.0,
        'active': 1,
      });
    }
    if (oldVersion < 3) {
      // Add invoiceNumber column to invoices table
      await db.execute('ALTER TABLE invoices ADD COLUMN invoiceNumber TEXT');
    }
  }



  // Hotel Details CRUD
  Future<int> insertHotelDetails(HotelDetails hotel) async {
    final db = await database;
    return await db.insert('hotel_details', hotel.toMap());
  }

  Future<HotelDetails?> getHotelDetails() async {
    final db = await database;
    final maps = await db.query('hotel_details', limit: 1);
    if (maps.isNotEmpty) {
      return HotelDetails.fromMap(maps.first);
    }
    // Insert dummy data if none exists
    await db.insert('hotel_details', {
      'name': 'Sample Restaurant',
      'contact': '123-456-7890',
      'address': '123 Main St, City, State',
      'gstin': 'GSTIN123456',
      'email': 'info@samplerestaurant.com',
    });
    final newMaps = await db.query('hotel_details', limit: 1);
    if (newMaps.isNotEmpty) {
      return HotelDetails.fromMap(newMaps.first);
    }
    return null;
  }

  Future<int> updateHotelDetails(HotelDetails hotel) async {
    final db = await database;
    return await db.update('hotel_details', hotel.toMap(), where: 'id = ?', whereArgs: [hotel.id]);
  }

  // Categories CRUD
  Future<int> insertCategory(cat.ItemCategory category) async {
    final db = await database;
    print('DatabaseHelper: Inserting category to database: ${category.toMap()}');
    final id = await db.transaction((txn) async {
      return await txn.insert('categories', category.toMap());
    });
    print('DatabaseHelper: Category inserted with ID: $id');
    return id;
  }

  Future<List<cat.ItemCategory>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', where: 'active = 1');
    print('DatabaseHelper: Retrieved ${maps.length} categories from database');
    maps.forEach((map) => print('DatabaseHelper: Category: ${map['name']} (ID: ${map['id']})'));
    return maps.map((map) => cat.ItemCategory.fromMap(map)).toList();
  }

  Future<int> updateCategory(cat.ItemCategory category) async {
    final db = await database;
    return await db.update('categories', category.toMap(), where: 'id = ?', whereArgs: [category.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.update('categories', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // Items CRUD
  Future<int> insertItem(Item item) async {
    final db = await database;
    print('DatabaseHelper: Inserting item to database: ${item.toMap()}');
    final id = await db.transaction((txn) async {
      return await txn.insert('items', item.toMap());
    });
    print('DatabaseHelper: Item inserted with ID: $id');
    return id;
  }

  Future<List<Item>> getItems({int? categoryId}) async {
    final db = await database;
    String where = 'active = 1';
    List<dynamic> whereArgs = [];
    if (categoryId != null) {
      where += ' AND categoryId = ?';
      whereArgs.add(categoryId);
    }
    final maps = await db.query('items', where: where, whereArgs: whereArgs);
    print('DatabaseHelper: Retrieved ${maps.length} items from database${categoryId != null ? ' for category $categoryId' : ''}');
    maps.forEach((map) => print('DatabaseHelper: Item: ${map['name']} (ID: ${map['id']}, Category ID: ${map['categoryId']})'));
    return maps.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.update('items', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // Invoices CRUD
  Future<String> generateInvoiceNumber() async {
    final db = await database;
    // Get current date in YYYYMMDD format
    String datePrefix = DateFormat('yyyyMMdd').format(DateTime.now());

    // Get the highest invoice number for today
    final result = await db.rawQuery(
      'SELECT invoiceNumber FROM invoices WHERE invoiceNumber LIKE ? ORDER BY invoiceNumber DESC LIMIT 1',
      ['$datePrefix%']
    );

    int nextNumber = 1;
    if (result.isNotEmpty && result.first['invoiceNumber'] != null) {
      String lastInvoiceNumber = result.first['invoiceNumber'] as String;
      // Extract the number part (after the date prefix)
      String numberPart = lastInvoiceNumber.substring(datePrefix.length);
      if (numberPart.isNotEmpty) {
        nextNumber = int.parse(numberPart) + 1;
      }
    }

    // Format: YYYYMMDD001, YYYYMMDD002, etc.
    return '$datePrefix${nextNumber.toString().padLeft(3, '0')}';
  }

  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database;
    return await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getInvoices({DateTime? startDate, DateTime? endDate, String? search}) async {
    final db = await database;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];
    if (startDate != null && endDate != null) {
      whereClauses.add('date BETWEEN ? AND ?');
      whereArgs.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(startDate));
      whereArgs.add(DateFormat('yyyy-MM-dd HH:mm:ss').format(endDate));
    }
    if (search != null && search.isNotEmpty) {
      whereClauses.add('(customerName LIKE ? OR contact LIKE ?)');
      whereArgs.add('%$search%');
      whereArgs.add('%$search%');
    }
    String where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';
    final maps = await db.query('invoices', where: where.isNotEmpty ? where : null, whereArgs: whereArgs);
    return maps.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<int> deleteInvoice(int id) async {
    final db = await database;
    await db.delete('invoice_items', where: 'invoiceId = ?', whereArgs: [id]);
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  // Invoice Items CRUD
  Future<int> insertInvoiceItem(InvoiceItem item) async {
    final db = await database;
    return await db.insert('invoice_items', item.toMap());
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await database;
    final maps = await db.query('invoice_items', where: 'invoiceId = ?', whereArgs: [invoiceId]);
    return maps.map((map) => InvoiceItem.fromMap(map)).toList();
  }
}
