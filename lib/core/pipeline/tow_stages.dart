import 'pipeline_stage.dart';

class TowRequestCreatedStage extends PipelineStage {
  TowRequestCreatedStage() : super(PipelineStageType.TOW_REQUEST_CREATED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async =>
      data.containsKey('customerId') && data.containsKey('location');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'requestedAt': DateTime.now().toIso8601String(),
      };
}

class ManagerDistanceReviewStage extends PipelineStage {
  ManagerDistanceReviewStage() : super(PipelineStageType.MANAGER_DISTANCE_REVIEW);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => data;
}

class TowApprovedStage extends PipelineStage {
  TowApprovedStage() : super(PipelineStageType.TOW_APPROVED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'approvedAt': DateTime.now().toIso8601String(),
      };
}

class DriverAssignedStage extends PipelineStage {
  DriverAssignedStage() : super(PipelineStageType.DRIVER_ASSIGNED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => data.containsKey('driverId');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'driverAssignedAt': DateTime.now().toIso8601String(),
      };
}

class DriverEnRouteStage extends PipelineStage {
  DriverEnRouteStage() : super(PipelineStageType.DRIVER_EN_ROUTE);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => data;
}

class VehiclePickedStage extends PipelineStage {
  VehiclePickedStage() : super(PipelineStageType.VEHICLE_PICKED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'pickedAt': DateTime.now().toIso8601String(),
      };
}

class VehicleDeliveredStage extends PipelineStage {
  VehicleDeliveredStage() : super(PipelineStageType.VEHICLE_DELIVERED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'deliveredAt': DateTime.now().toIso8601String(),
      };
}

class TowPaymentCompletedStage extends PipelineStage {
  TowPaymentCompletedStage() : super(PipelineStageType.TOW_PAYMENT_COMPLETED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'paidAt': DateTime.now().toIso8601String(),
      };
}

class TowJobClosedStage extends PipelineStage {
  TowJobClosedStage() : super(PipelineStageType.TOW_JOB_CLOSED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'closedAt': DateTime.now().toIso8601String(),
      };
}
