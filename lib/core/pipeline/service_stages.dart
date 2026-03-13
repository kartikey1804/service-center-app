import 'pipeline_stage.dart';

class BookingCreatedStage extends PipelineStage {
  BookingCreatedStage() : super(PipelineStageType.BOOKING_CREATED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async =>
      data.containsKey('customerId') &&
      data.containsKey('vehicleId') &&
      data.containsKey('serviceType');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'bookingDate': DateTime.now().toIso8601String(),
      };
}

class ManagerReviewStage extends PipelineStage {
  ManagerReviewStage() : super(PipelineStageType.MANAGER_REVIEW);
  @override
  Future<bool> validate(Map<String, dynamic> data) async =>
      data.containsKey('managerId');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'reviewedAt': DateTime.now().toIso8601String(),
      };
}

class TechnicianAssignedStage extends PipelineStage {
  TechnicianAssignedStage() : super(PipelineStageType.TECHNICIAN_ASSIGNED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async =>
      data.containsKey('technicianId');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'assignedAt': DateTime.now().toIso8601String(),
      };
}

class ServiceStartedStage extends PipelineStage {
  ServiceStartedStage() : super(PipelineStageType.SERVICE_STARTED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'startTime': DateTime.now().toIso8601String(),
      };
}

class PartRequestedStage extends PipelineStage {
  PartRequestedStage() : super(PipelineStageType.PART_REQUESTED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => data.containsKey('parts');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'partsRequestedAt': DateTime.now().toIso8601String(),
      };
}

class PartApprovalPendingStage extends PipelineStage {
  PartApprovalPendingStage() : super(PipelineStageType.PART_APPROVAL_PENDING);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => data;
}

class PartOrderedStage extends PipelineStage {
  PartOrderedStage() : super(PipelineStageType.PART_ORDERED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'partOrderedAt': DateTime.now().toIso8601String(),
      };
}

class WaitingForPartStage extends PipelineStage {
  WaitingForPartStage() : super(PipelineStageType.WAITING_FOR_PART);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => data;
}

class ServiceCompletedStage extends PipelineStage {
  ServiceCompletedStage() : super(PipelineStageType.SERVICE_COMPLETED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'completionTime': DateTime.now().toIso8601String(),
      };
}

class PaymentPendingStage extends PipelineStage {
  PaymentPendingStage() : super(PipelineStageType.PAYMENT_PENDING);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => data.containsKey('amount');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => data;
}

class PaymentCompletedStage extends PipelineStage {
  PaymentCompletedStage() : super(PipelineStageType.PAYMENT_COMPLETED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => data.containsKey('transactionId');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'paidAt': DateTime.now().toIso8601String(),
      };
}

class JobClosedStage extends PipelineStage {
  JobClosedStage() : super(PipelineStageType.JOB_CLOSED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async => true;
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'closedAt': DateTime.now().toIso8601String(),
      };
}
class ReviewSubmittedStage extends PipelineStage {
  ReviewSubmittedStage() : super(PipelineStageType.REVIEW_SUBMITTED);
  @override
  Future<bool> validate(Map<String, dynamic> data) async =>
      data.containsKey('rating') && data.containsKey('comment');
  @override
  Future<Map<String, dynamic>> process(Map<String, dynamic> data) async => {
        ...data,
        'review': {
          'rating': data['rating'],
          'comment': data['comment'],
          'submittedAt': DateTime.now().toIso8601String(),
        },
      };
}
