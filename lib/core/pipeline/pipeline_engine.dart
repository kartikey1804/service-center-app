import 'package:flutter/foundation.dart';
import '../../data/services/mongodb_service.dart';
import 'pipeline_stage.dart';
import 'audit_logger.dart';
import 'package:mongo_dart/mongo_dart.dart';

class PipelineEngine {
  final AuditLogger _auditLogger = AuditLogger();

  Future<void> processTransition({
    required PipelineContext context,
    PipelineStage? fromStage,
    required PipelineStage toStage,
    required Map<String, dynamic> data,
  }) async {
    try {
      // 1. Validate
      bool isValid = await toStage.validate(data);
      if (!isValid) throw Exception("Validation failed for stage: ${toStage.name}");

      final updatedData = await toStage.process(data);
      updatedData['id'] = context.entityId;
      updatedData['status'] = toStage.name;
      updatedData['lastUpdated'] = DateTime.now().toIso8601String();

      if (!MongoDbService.isConfigured) {
        print("Pipeline Fallback: local mode only for ${context.entityId}");
        return;
      }

      // 2. Atomic Database Update (Optimistic Locking)
      final collection = MongoDbService.getCollection(context.collectionName);
      
      // Get current version for optimistic locking
      final currentDoc = await collection.findOne(where.eq('id', context.entityId));
      
      int currentVersion = 0;
      bool isNew = currentDoc == null;
      
      if (!isNew) {
        currentVersion = currentDoc['version'] ?? 0;
      }
      
      updatedData['version'] = currentVersion + 1;

      if (isNew) {
        updatedData['_id'] = ObjectId();
        await collection.insertOne(updatedData);
      } else {
        // 4. Commit with version check
        final modifier = ModifierBuilder();
        updatedData.forEach((key, value) {
          if (key != '_id') modifier.set(key, value);
        });
        final result = await collection.updateOne(
          where.eq('id', context.entityId).and(where.eq('version', currentVersion)),
          modifier,
        );

        if (result.nModified == 0) {
          throw Exception("Concurrent update detected or version mismatch for ${context.entityId}");
        }
      }

      // 5. Audit Log
      await _auditLogger.log(
        entityId: context.entityId,
        fromStage: fromStage?.name ?? "START",
        toStage: toStage.name,
        userId: context.userId,
        metadata: context.metadata,
      );

      // 6. Trigger Notifications (Simplified for now)
      print("Pipeline: Transitioned ${context.entityId} to ${toStage.name}");
      
    } catch (e) {
      print("Pipeline Error: $e");
      // Centralized error handling / Rollback logic would go here
      rethrow;
    }
  }
}
