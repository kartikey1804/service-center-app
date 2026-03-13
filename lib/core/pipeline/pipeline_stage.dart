import 'package:mongo_dart/mongo_dart.dart';

enum PipelineStageType {
  // Service Request Stages
  BOOKING_CREATED,
  MANAGER_REVIEW,
  TECHNICIAN_ASSIGNED,
  SERVICE_STARTED,
  PART_REQUESTED,
  PART_APPROVAL_PENDING,
  PART_ORDERED,
  WAITING_FOR_PART,
  SERVICE_COMPLETED,
  PAYMENT_PENDING,
  PAYMENT_COMPLETED,
  JOB_CLOSED,

  // Tow Request Stages
  TOW_REQUEST_CREATED,
  MANAGER_DISTANCE_REVIEW,
  TOW_APPROVED,
  DRIVER_ASSIGNED,
  DRIVER_EN_ROUTE,
  VEHICLE_PICKED,
  VEHICLE_DELIVERED,
  TOW_PAYMENT_COMPLETED,
  TOW_JOB_CLOSED,

  // Spare Part Request Stages
  PART_REQUISITION_CREATED,
  MANAGER_PART_REVIEW,
  PART_PROCUREMENT_ORDERED,
  PART_RECEIVED_AT_CENTER,
  PART_INSTALLED,
  REVIEW_SUBMITTED
}

abstract class PipelineStage {
  final PipelineStageType type;
  
  PipelineStage(this.type);

  Future<bool> validate(Map<String, dynamic> data);
  Future<Map<String, dynamic>> process(Map<String, dynamic> data);
  
  String get name => type.name;
}

class PipelineContext {
  final String entityId;
  final String collectionName;
  final String userId;
  final Map<String, dynamic> metadata;

  PipelineContext({
    required this.entityId,
    required this.collectionName,
    required this.userId,
    this.metadata = const {},
  });
}
