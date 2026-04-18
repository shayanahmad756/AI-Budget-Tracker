/// Data model representing a single financial transaction.
///
/// Used throughout the app for both income and expense entries.
/// Supports serialization to/from SQLite via [toMap] and [fromMap].
class TransactionModel {
  /// Unique identifier for this transaction (UUID string).
  final String id;

  /// User-provided title or description of the transaction.
  final String title;

  /// Monetary amount of the transaction.
  final double amount;

  /// Spending/income category (e.g. "Food", "Travel", "Bills").
  final String category;

  /// Date and time when the transaction occurred.
  final DateTime date;

  /// Transaction type — must be either `"income"` or `"expense"`.
  final String type;

  /// Creates a [TransactionModel] with all fields required.
  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
  });

  /// Converts this transaction into a Map suitable for SQLite insertion.
  ///
  /// The [date] field is stored as an ISO 8601 string so it can be
  /// reliably parsed back when reading from the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  /// Reconstructs a [TransactionModel] from a SQLite row map.
  ///
  /// Expects keys: `id`, `title`, `amount`, `category`, `date` (ISO 8601
  /// string), and `type`.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      type: map['type'] as String,
    );
  }

  /// Returns a human-readable representation for debugging.
  @override
  String toString() {
    return 'TransactionModel(id: $id, title: $title, amount: $amount, '
        'category: $category, date: $date, type: $type)';
  }
}
