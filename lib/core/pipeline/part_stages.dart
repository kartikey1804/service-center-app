import 'pipeline_stage.dart';

class PartRequisitionCreatedStage extends PipelineStage {
  PartRequisitionCreatedStage() : super(PipelineStageType.PART_REQUISITION_CREATED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async =>
      data.containsKey('partName') && data.containsKey('jobId');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'requestDate': DateTime.now().toIso8601String(),
        'status': 'Awaiting Approval',
      };
}

class ManagerPartReviewStage extends PipelineStage {
  ManagerPartReviewStage() : super(PipelineStageType.MANAGER_PART_REVIEW);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => data.containsKey('approved');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => data;
}

class PartProcurementOrderedStage extends PipelineStage {
  PartProcurementOrderedStage() : super(PipelineStageType.PART_PROCUREMENT_ORDERED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'orderedAt': DateTime.now().toIso8601String(),
      };
}

class PartReceivedAtCenterStage extends PipelineStage {
  PartReceivedAtCenterStage() : super(PipelineStageType.PART_RECEIVED_AT_CENTER);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'receivedAt': DateTime.now().toIso8601String(),
      };
}

class PartInstalledStage extends PipelineStage {
  PartInstalledStage() : super(PipelineStageType.PART_INSTALLED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'installedAt': DateTime.now().toIso8601String(),
      };
}
