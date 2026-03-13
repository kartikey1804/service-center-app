import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/services/mongodb_service.dart';
import '../../core/pipeline/pipeline_engine.dart';
import '../../core/pipeline/pipeline_stage.dart';
import '../../core/pipeline/service_stages.dart';
import '../../core/pipeline/tow_stages.dart';
import '../../core/pipeline/part_stages.dart';

final pipelineEngineProvider = Provider((ref) => PipelineEngine());

final pipelineStageFactoryProvider = Provider((ref) {
  return (PipelineStageType type) {
    switch (type) {
      case PipelineStageType.BOOKING_CREATED: return BookingCreatedStage();
      case PipelineStageType.MANAGER_REVIEW: return ManagerReviewStage();
      case PipelineStageType.TECHNICIAN_ASSIGNED: return TechnicianAssignedStage();
      case PipelineStageType.SERVICE_STARTED: return ServiceStartedStage();
      case PipelineStageType.PART_REQUESTED: return PartRequestedStage();
      case PipelineStageType.PART_APPROVAL_PENDING: return PartApprovalPendingStage();
      case PipelineStageType.PART_ORDERED: return PartOrderedStage();
      case PipelineStageType.WAITING_FOR_PART: return WaitingForPartStage();
      case PipelineStageType.SERVICE_COMPLETED: return ServiceCompletedStage();
      case PipelineStageType.PAYMENT_PENDING: return PaymentPendingStage();
      case PipelineStageType.PAYMENT_COMPLETED: return PaymentCompletedStage();
      case PipelineStageType.JOB_CLOSED: return JobClosedStage();
      
      case PipelineStageType.TOW_REQUEST_CREATED: return TowRequestCreatedStage();
      case PipelineStageType.MANAGER_DISTANCE_REVIEW: return ManagerDistanceReviewStage();
      case PipelineStageType.TOW_APPROVED: return TowApprovedStage();
      case PipelineStageType.DRIVER_ASSIGNED: return DriverAssignedStage();
      case PipelineStageType.DRIVER_EN_ROUTE: return DriverEnRouteStage();
      case PipelineStageType.VEHICLE_PICKED: return VehiclePickedStage();
      case PipelineStageType.VEHICLE_DELIVERED: return VehicleDeliveredStage();
       case PipelineStageType.TOW_PAYMENT_COMPLETED: return TowPaymentCompletedStage();
      case PipelineStageType.TOW_JOB_CLOSED: return TowJobClosedStage();

      case PipelineStageType.PART_REQUISITION_CREATED: return PartRequisitionCreatedStage();
      case PipelineStageType.MANAGER_PART_REVIEW: return ManagerPartReviewStage();
      case PipelineStageType.PART_PROCUREMENT_ORDERED: return PartProcurementOrderedStage();
      case PipelineStageType.PART_RECEIVED_AT_CENTER: return PartReceivedAtCenterStage();
      case PipelineStageType.PART_INSTALLED: return PartInstalledStage();
      case PipelineStageType.REVIEW_SUBMITTED: return ReviewSubmittedStage();
    }
  };
});

class ServicePipelineNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final PipelineEngine _engine;
  final Function(PipelineStageType) _stageFactory;

  ServicePipelineNotifier(this._engine, this._stageFactory) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      if (MongoDbService.isConfigured) {
        final jobs = await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION).find().toList();
        state = AsyncValue.data(jobs);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> transition({
    required String jobId,
    required PipelineStageType from,
    required PipelineStageType to,
    required String userId,
    Map<String, dynamic> data = const {},
  }) async {
    final context = PipelineContext(
      entityId: jobId,
      collectionName: MongoDbService.JOBS_COLLECTION,
      userId: userId,
    );

    await _engine.processTransition(
      context: context,
      fromStage: _stageFactory(from),
      toStage: _stageFactory(to),
      data: data,
    );
    
    // Refresh local state after successful transition
    await refresh();
  }

  Future<void> initiate({
    required String jobId,
    required PipelineStageType to,
    required String userId,
    Map<String, dynamic> data = const {},
  }) async {
    final context = PipelineContext(
      entityId: jobId,
      collectionName: MongoDbService.JOBS_COLLECTION,
      userId: userId,
    );

    await _engine.processTransition(
      context: context,
      toStage: _stageFactory(to),
      data: data,
    );

    await refresh();
  }
}

final servicePipelineProvider = StateNotifierProvider<ServicePipelineNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return ServicePipelineNotifier(
    ref.watch(pipelineEngineProvider),
    ref.watch(pipelineStageFactoryProvider),
  );
});

class TowPipelineNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final PipelineEngine _engine;
  final Function(PipelineStageType) _stageFactory;

  TowPipelineNotifier(this._engine, this._stageFactory) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      if (MongoDbService.isConfigured) {
        final requests = await MongoDbService.getCollection(MongoDbService.TOW_REQUESTS_COLLECTION).find().toList();
        state = AsyncValue.data(requests);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> transition({
    required String requestId,
    required PipelineStageType from,
    required PipelineStageType to,
    required String userId,
    Map<String, dynamic> data = const {},
  }) async {
    final context = PipelineContext(
      entityId: requestId,
      collectionName: MongoDbService.TOW_REQUESTS_COLLECTION,
      userId: userId,
    );

    await _engine.processTransition(
      context: context,
      fromStage: _stageFactory(from),
      toStage: _stageFactory(to),
      data: data,
    );
    
    await refresh();
  }

  Future<void> initiate({
    required String requestId,
    required PipelineStageType to,
    required String userId,
    Map<String, dynamic> data = const {},
  }) async {
    final context = PipelineContext(
      entityId: requestId,
      collectionName: MongoDbService.TOW_REQUESTS_COLLECTION,
      userId: userId,
    );

    await _engine.processTransition(
      context: context,
      toStage: _stageFactory(to),
      data: data,
    );

    // Create a notification for the manager
    if (MongoDbService.isConfigured) {
      try {
        await MongoDbService.getCollection(MongoDbService.NOTIFICATIONS_COLLECTION).insert({
          'id': 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'New Emergency Tow Request',
          'message': 'A new tow request $requestId has been created for ${data['vehicleId'] ?? 'Unknown Vehicle'}.',
          'time': 'Just Now',
          'isRead': false,
          'type': 'emergency',
          'entityId': requestId,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        // Log error silently
      }
    }

    await refresh();
  }
}

final towPipelineProvider = StateNotifierProvider<TowPipelineNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TowPipelineNotifier(
    ref.watch(pipelineEngineProvider),
    ref.watch(pipelineStageFactoryProvider),
  );
});

class PartPipelineNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final PipelineEngine _engine;
  final Function(PipelineStageType) _stageFactory;

  PartPipelineNotifier(this._engine, this._stageFactory) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      if (MongoDbService.isConfigured) {
        final requests = await MongoDbService.getCollection(MongoDbService.PARTS_REQUESTS_COLLECTION).find().toList();
        state = AsyncValue.data(requests);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> transition({
    required String requestId,
    required PipelineStageType from,
    required PipelineStageType to,
    required String userId,
    Map<String, dynamic> data = const {},
  }) async {
    final context = PipelineContext(
      entityId: requestId,
      collectionName: MongoDbService.PARTS_REQUESTS_COLLECTION,
      userId: userId,
    );

    await _engine.processTransition(
      context: context,
      fromStage: _stageFactory(from),
      toStage: _stageFactory(to),
      data: data,
    );
    
    await refresh();
  }

  Future<void> initiate({
    required String requestId,
    required PipelineStageType to,
    required String userId,
    Map<String, dynamic> data = const {},
  }) async {
    final context = PipelineContext(
      entityId: requestId,
      collectionName: MongoDbService.PARTS_REQUESTS_COLLECTION,
      userId: userId,
    );

    await _engine.processTransition(
      context: context,
      toStage: _stageFactory(to),
      data: data,
    );

    await refresh();
  }
}

final partPipelineProvider = StateNotifierProvider<PartPipelineNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return PartPipelineNotifier(
    ref.watch(pipelineEngineProvider),
    ref.watch(pipelineStageFactoryProvider),
  );
});
