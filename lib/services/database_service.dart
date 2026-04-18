import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart';
import 'package:ai_budget_tracker/models/transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:idb_shim/idb_browser.dart';
import 'package:sqflite/sqflite.dart' show getDatabasesPath;

/// Singleton service that manages all database operations for
/// the budget tracker.
///
/// Uses SQLite on mobile/desktop and IndexedDB on web.
///
/// Usage:
/// ```dart
/// final db = DatabaseService.instance;
/// await db.insertTransaction(txn);
/// final list = await db.getTransactions();
/// ```
class DatabaseService {
  /// The single shared instance of [DatabaseService].
  static final DatabaseService instance = DatabaseService._init();

  /// Private named constructor to enforce the singleton pattern.
  DatabaseService._init();

  /// Cached database reference for SQLite
  static sqlite.Database? _sqliteDatabase;
  
  /// Cached IndexedDB database reference
  static Database? _idbDatabase;
  
  /// IndexedDB object store name
  static const String _storeName = 'transactions';

  /// Returns the database, creating it on the first call.
  Future<dynamic> get database async {
    if (kIsWeb) {
      _idbDatabase ??= await _initWebDB();
      return _idbDatabase!;
    } else {
      _sqliteDatabase ??= await _initDB('budget_tracker.db');
      return _sqliteDatabase!;
    }
  }

  // ─── Initialisation ──────────────────────────────────────────────

  /// Opens (or creates) the SQLite database file at the platform's
  /// default database directory.
  Future<sqlite.Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await sqlite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Opens (or creates) the IndexedDB database for web.
  Future<Database> _initWebDB() async {
    final idbFactory = getIdbFactory();
    final db = await idbFactory!.open(
      'budget_tracker_db',
      version: 1,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final database = event.database;
        // Create the transactions object store if it doesn't already exist
        if (!database.objectStoreNames.contains(_storeName)) {
          database.createObjectStore(_storeName);
        }
      },
    );

    return db;
  }

  /// Called once when the database is first created.
  /// Sets up the `transactions` table schema.
  Future<void> _createDB(sqlite.Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
  }

  // ─── CRUD Operations ─────────────────────────────────────────────

  /// Inserts a new [transaction] into the database.
  Future<void> insertTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      await _insertWebTransaction(transaction);
    } else {
      final db = await database;
      await (db as sqlite.Database).insert(
        'transactions',
        transaction.toMap(),
        conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
      );
    }
  }

  /// Web-specific insert using IndexedDB
  Future<void> _insertWebTransaction(TransactionModel transaction) async {
    final db = await database;
    final txn = db.transaction(_storeName, 'readwrite');
    final store = txn.objectStore(_storeName);
    await store.put(transaction.toMap(), transaction.id);
    await txn.completed;
  }

  /// Retrieves all transactions from the database, ordered by date
  /// descending (most recent first).
  Future<List<TransactionModel>> getTransactions() async {
    if (kIsWeb) {
      return await _getWebTransactions();
    } else {
      final db = await database;
      final result = await (db as sqlite.Database).query(
        'transactions',
        orderBy: 'date DESC',
      );
      return result.map((map) => TransactionModel.fromMap(map)).toList();
    }
  }

  /// Web-specific get all transactions using IndexedDB
  Future<List<TransactionModel>> _getWebTransactions() async {
    final db = await database;
    final txn = db.transaction(_storeName, 'readonly');
    final store = txn.objectStore(_storeName);
    final result = await store.getAll();
    await txn.completed;
    
    // Convert to explicitly typed list and sort by date
    final List<TransactionModel> transactions = result
        .map<TransactionModel>((map) => TransactionModel.fromMap(Map<String, dynamic>.from(map as Map)))
        .toList();
    
    transactions.sort((TransactionModel a, TransactionModel b) => b.date.compareTo(a.date));
    return transactions;
  }

  /// Deletes the transaction with the given [id] from the database.
  Future<void> deleteTransaction(String id) async {
    if (kIsWeb) {
      await _deleteWebTransaction(id);
    } else {
      final db = await database;
      await (db as sqlite.Database).delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Web-specific delete using IndexedDB
  Future<void> _deleteWebTransaction(String id) async {
    final db = await database;
    final txn = db.transaction(_storeName, 'readwrite');
    final store = txn.objectStore(_storeName);
    await store.delete(id);
    await txn.completed;
  }

  /// Closes the database connection and resets the cached reference.
  Future<void> close() async {
    if (kIsWeb) {
      _idbDatabase?.close();
      _idbDatabase = null;
    } else {
      final db = await database;
      await db.close();
      _sqliteDatabase = null;
    }
  }
}
