import '../../data/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuditLogger {
  static const String PIPELINE_HISTORY_COLLECTION = 'service_pipeline_history';

  Future<void> log({
    required String entityId,
    required String fromStage,
    required String toStage,
    required String userId,
    Map<String, dynamic> metadata = const {},
  }) async {
    if (!MongoDbService.isConfigured) return;

    final entry = {
      '_id': ObjectId(),
      'entityId': entityId,
      'fromStage': fromStage,
      'toStage': toStage,
      'updatedBy': userId,
      'timestamp': DateTime.now(),
      'metadata': metadata,
    };

    try {
      await MongoDbService.getCollection(PIPELINE_HISTORY_COLLECTION).insertOne(entry);
    } catch (e) {
      print("Audit Log Error: $e");
    }
  }
}
