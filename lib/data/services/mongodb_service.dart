import 'package:mongo_dart/mongo_dart.dart';

class MongoDbService {
  static Db? _db;
  static late String _connectionString;

  // Collection Names
  static const String JOBS_COLLECTION = 'jobs';
  static const String INVENTORY_COLLECTION = 'inventory';
  static const String CUSTOMER_VEHICLES_COLLECTION = 'customerVehicles';
  static const String CUSTOMER_QUOTES_COLLECTION = 'customerQuotes';
  static const String NOTIFICATIONS_COLLECTION = 'notifications';
  static const String INVOICES_COLLECTION = 'invoices';
  static const String STAFF_COLLECTION = 'staff';
  static const String PARTS_REQUESTS_COLLECTION = 'partsRequests';
  static const String CHAT_CONVERSATIONS_COLLECTION = 'chatConversations';
  static const String TIME_TRACKING_COLLECTION = 'timeTracking';
  static const String PERFORMANCE_METRICS_COLLECTION = 'performanceMetrics';
  static const String USERS_COLLECTION = 'users';
  static const String PARTS_REQUISITION_COLLECTION = 'partsRequisitions';
  static const String TOW_REQUESTS_COLLECTION = 'towRequests';

  static void configure(String connectionString) {
    _connectionString = connectionString;
  }

  static bool get isConfigured => _db != null && _db!.isConnected;

  static Future<void> connect() async {
    if (_connectionString.isEmpty) {
      throw Exception("MongoDB connection string not configured.");
    }
    _db = await Db.create(_connectionString);
    await _db!.open();
    print('Connected to MongoDB');
  }

  static DbCollection getCollection(String collectionName) {
    if (isConfigured) {
      return _db!.collection(collectionName);
    } else {
      throw Exception("MongoDB not connected or not supported on this platform.");
    }
  }

  static Future<void> close() async {
    if (_db != null && _db!.isConnected) {
      await _db!.close();
      print('MongoDB connection closed.');
    }
  }
}
