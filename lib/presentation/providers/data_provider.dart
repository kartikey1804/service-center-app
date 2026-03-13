import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DataProvider extends ChangeNotifier {
  String _storeName = 'AutoCare Hub';
  List<Map<String, dynamic>> _activeJobs = [];
  List<Map<String, dynamic>> _inventory = [];
  Map<String, dynamic> _stats = {};

  // Phase 2
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _partsRequests = [];
  List<Map<String, dynamic>> _chatConversations = [];
  List<Map<String, dynamic>> _customerVehicles = [];
  List<Map<String, dynamic>> _customerQuotes = [];
  List<Map<String, dynamic>> _towRequests = [];
  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic> _technicianPerformanceMetrics = {};

  bool _isLoading = false;
  bool _isDataLoaded = false;

  String get storeName => _storeName;
  List<Map<String, dynamic>> get activeJobs => _activeJobs;
  List<Map<String, dynamic>> get inventory => _inventory;
  Map<String, dynamic> get stats => _stats;

  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get invoices => _invoices;
  List<Map<String, dynamic>> get staff => _staff;
  List<Map<String, dynamic>> get partsRequests => _partsRequests;
  List<Map<String, dynamic>> get chatConversations => _chatConversations;
  Map<String, dynamic> get technicianPerformanceMetrics =>
      _technicianPerformanceMetrics;
  List<Map<String, dynamic>> get users => _users;
  List<Map<String, dynamic>> get customerVehicles => _customerVehicles;
  List<Map<String, dynamic>> get customerQuotes => _customerQuotes;
  List<Map<String, dynamic>> get towRequests => _towRequests;

  bool get isLoading => _isLoading;

  DataProvider() {
    Future.microtask(() => loadData());
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (_isDataLoaded && !MongoDbService.isConfigured) {
      _saveToLocalStorage();
    }
  }

  Future<void> _saveToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    Object toEncodable(Object? item) {
      if (item is ObjectId) return item.toHexString();
      return item.toString();
    }

    await prefs.setString('customerVehicles', jsonEncode(_customerVehicles, toEncodable: toEncodable));
    await prefs.setString('activeJobs', jsonEncode(_activeJobs, toEncodable: toEncodable));
    await prefs.setString('towRequests', jsonEncode(_towRequests, toEncodable: toEncodable));
    await prefs.setString('customerQuotes', jsonEncode(_customerQuotes, toEncodable: toEncodable));
  }

  Future<void> _loadFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final cvStr = prefs.getString('customerVehicles');
      if (cvStr != null) {
        final List decoded = jsonDecode(cvStr);
        _customerVehicles = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _customerVehicles = [];
      }

      final ajStr = prefs.getString('activeJobs');
      if (ajStr != null) {
        final List decoded = jsonDecode(ajStr);
        _activeJobs = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _activeJobs = [];
      }

      final trStr = prefs.getString('towRequests');
      if (trStr != null) {
        final List decoded = jsonDecode(trStr);
        _towRequests = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _towRequests = [];
      }

      final cqStr = prefs.getString('customerQuotes');
      if (cqStr != null) {
        final List decoded = jsonDecode(cqStr);
        _customerQuotes = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _customerQuotes = [];
      }
    } catch (e) {
      print('Error loading from local storage: $e');
      _customerVehicles = [];
      _activeJobs = [];
      _towRequests = [];
      _customerQuotes = [];
    }
    
    _inventory = [];
    _stats = {};
    _notifications = [];
    _invoices = [];
    _staff = [];
    _partsRequests = [];
    _chatConversations = [];
    _technicianPerformanceMetrics = {};
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (MongoDbService.isConfigured) {
      _activeJobs =
          await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
              .find()
              .toList();
      _inventory =
          await MongoDbService.getCollection(MongoDbService.INVENTORY_COLLECTION)
              .find()
              .toList();
      _stats =
          (await MongoDbService.getCollection(
                MongoDbService.PERFORMANCE_METRICS_COLLECTION,
              ).findOne()) ??
          {};
      _users =
          await MongoDbService.getCollection(MongoDbService.USERS_COLLECTION)
              .find()
              .toList();
      _customerVehicles =
          await MongoDbService.getCollection(
                MongoDbService.CUSTOMER_VEHICLES_COLLECTION,
              ).find().toList();

      _towRequests =
          await MongoDbService.getCollection(
                MongoDbService.TOW_REQUESTS_COLLECTION,
              ).find().toList();

      _customerQuotes =
          await MongoDbService.getCollection(
                MongoDbService.CUSTOMER_QUOTES_COLLECTION,
              ).find().toList();

      _notifications =
          await MongoDbService.getCollection(
                MongoDbService.NOTIFICATIONS_COLLECTION,
              ).find().toList();
      _invoices =
          await MongoDbService.getCollection(MongoDbService.INVOICES_COLLECTION)
              .find()
              .toList();
      _staff =
          await MongoDbService.getCollection(MongoDbService.STAFF_COLLECTION)
              .find()
              .toList();
      _partsRequests =
          await MongoDbService.getCollection(
                MongoDbService.PARTS_REQUESTS_COLLECTION,
              ).find().toList();
      _chatConversations =
          await MongoDbService.getCollection(
                MongoDbService.CHAT_CONVERSATIONS_COLLECTION,
              ).find().toList();
      _technicianPerformanceMetrics =
          (await MongoDbService.getCollection(
                MongoDbService.PERFORMANCE_METRICS_COLLECTION,
              ).findOne()) ??
          {};
    } else {
      await _loadFromLocalStorage();
    }

    _isDataLoaded = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    final index = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
            .updateOne(
              where.eq('id', jobId),
              ModifierBuilder().set('status', newStatus),
            );
      }
      // Update local state
      _activeJobs[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  Future<void> updateInspectionChecklistItem(
    String jobId,
    String item,
    bool isChecked,
  ) async {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (_activeJobs[jobIndex].containsKey('inspectionChecklist')) {
        if (MongoDbService.isConfigured) {
          // Update in MongoDB
          await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
              .updateOne(
                where.eq('id', jobId),
                ModifierBuilder().set('inspectionChecklist.$item', isChecked),
              );
        }
        // Update local state
        (_activeJobs[jobIndex]['inspectionChecklist']
                as Map<String, bool>)[item] =
            isChecked;
        notifyListeners();
      }
    }
  }

  Future<void> approveQuote(String quoteId) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.CUSTOMER_QUOTES_COLLECTION,
      ).updateOne(where.eq('id', quoteId), ModifierBuilder().set('status', 'Approved'));
    }
    notifyListeners();
  }

  Future<void> denyQuote(String quoteId) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.CUSTOMER_QUOTES_COLLECTION,
      ).updateOne(where.eq('id', quoteId), ModifierBuilder().set('status', 'Denied'));
    }
    notifyListeners();
  }

  Future<void> orderPart(String partId) async {
    final index = _inventory.indexWhere((p) => p['id'] == partId);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(MongoDbService.INVENTORY_COLLECTION)
            .updateOne(where.eq('id', partId), ModifierBuilder().inc('stock', 50));
      }
      // Update local state
      _inventory[index]['stock'] += 50; // Add generic stock count
      notifyListeners();
    }
  }

  Future<void> addInventoryItem(Map<String, dynamic> itemData) async {
    final newItem = {
      '_id': ObjectId(),
      'id': 'PART-${DateTime.now().millisecondsSinceEpoch}',
      ...itemData,
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.INVENTORY_COLLECTION)
          .insertOne(newItem);
    }
    _inventory.add(newItem);
    notifyListeners();
  }

  Future<void> updateInventoryItem(
    String partId,
    Map<String, dynamic> updateData,
  ) async {
    final index = _inventory.indexWhere((p) => p['id'] == partId);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        final modifier = ModifierBuilder();
        updateData.forEach((key, value) {
          modifier.set(key, value);
        });
        await MongoDbService.getCollection(MongoDbService.INVENTORY_COLLECTION)
            .updateOne(where.eq('id', partId), modifier);
      }
      _inventory[index].addAll(updateData);
      notifyListeners();
    }
  }

  Future<void> deleteInventoryItem(String partId) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.INVENTORY_COLLECTION)
          .deleteOne(where.eq('id', partId));
    }
    _inventory.removeWhere((item) => item['id'] == partId);
    notifyListeners();
  }

  Future<void> updateStoreName(String newName) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.PERFORMANCE_METRICS_COLLECTION,
      ).updateOne(where.exists('_id'), ModifierBuilder().set('storeName', newName));
    }
    _storeName = newName;
    notifyListeners();
  }

  Future<void> addEmployee(String name, String role) async {
    final newEmployee = {
      '_id': ObjectId(), // MongoDB's unique ID
      'id': 'tech-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'role': role,
      'status': 'Offline',
      'hours': '0h 0m',
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.STAFF_COLLECTION)
          .insertOne(newEmployee);
    }
    _staff.add(newEmployee);
    notifyListeners();
  }

  Future<void> addStaffMember(Map<String, dynamic> newEmployeeData) async {
    final newEmployee = {
      '_id': ObjectId(), // MongoDB's unique ID
      'id': 'tech-${DateTime.now().millisecondsSinceEpoch}',
      ...newEmployeeData,
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.STAFF_COLLECTION)
          .insertOne(newEmployee);
    }
    _staff.add(newEmployee);
    notifyListeners();
  }


  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(
          MongoDbService.NOTIFICATIONS_COLLECTION,
        ).updateOne(where.eq('id', notificationId), ModifierBuilder().set('isRead', true));
      }
      // Update local state
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  Future<void> addChatMessage(
    String chatId,
    String sender,
    String message,
  ) async {
    final chatIndex = _chatConversations.indexWhere(
      (chat) => chat['id'] == chatId,
    );
    if (chatIndex != -1) {
      final newMessage = {
        'sender': sender,
        'message': message,
        'time': 'Just now',
      };
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(
          MongoDbService.CHAT_CONVERSATIONS_COLLECTION,
        ).updateOne(
          where.eq('id', chatId),
          ModifierBuilder().push('messages', newMessage)
            ..set('lastMessage', message)
            ..set('lastMessageTime', 'Just now'),
        );
      }
      // Update local state
      (_chatConversations[chatIndex]['messages'] as List).add(newMessage);
      _chatConversations[chatIndex]['lastMessage'] = message;
      _chatConversations[chatIndex]['lastMessageTime'] = 'Just now';
      notifyListeners();
    }
  }

  Future<void> sendMockReply(String chatId) async {
    final chatIndex = _chatConversations.indexWhere(
      (chat) => chat['id'] == chatId,
    );
    if (chatIndex != -1) {
      final participants =
          _chatConversations[chatIndex]['participants'] as List<String>;
      final sender = participants.firstWhere(
        (p) => p != 'Mike Ross',
        orElse: () => participants.first,
      ); // Mock reply from other participant

      await Future.delayed(const Duration(seconds: 2), () async {
        final replyMessage = {
          'sender': sender,
          'message': 'Okay, got it. Will look into that.',
          'time': 'Just now',
        };
        if (MongoDbService.isConfigured) {
          // Update in MongoDB
          await MongoDbService.getCollection(
            MongoDbService.CHAT_CONVERSATIONS_COLLECTION,
          ).updateOne(
            where.eq('id', chatId),
            ModifierBuilder().push('messages', replyMessage)
              ..set('lastMessage', replyMessage['message'])
              ..set('lastMessageTime', 'Just now'),
          );
        }
        // Update local state
        (_chatConversations[chatIndex]['messages'] as List).add(replyMessage);
        _chatConversations[chatIndex]['lastMessage'] =
            'Okay, got it. Will look into that.';
        _chatConversations[chatIndex]['lastMessageTime'] = 'Just now';
        notifyListeners();
      });
    }
  }

  Future<void> updateJobEstimatedTime(String jobId, String newTime) async {
    final index = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
            .updateOne(
              where.eq('id', jobId),
              ModifierBuilder().set('estimatedCompletionTime', newTime),
            );
      }
      // Update local state
      _activeJobs[index]['estimatedCompletionTime'] = newTime;
      notifyListeners();
    }
  }

  Future<void> addCustomerCommunicationLogEntry(
    String jobId,
    String type,
    String message,
  ) async {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      final newLogEntry = {
        'type': type,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      };
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
            .updateOne(
              where.eq('id', jobId),
              ModifierBuilder().push('customerCommunicationLog', newLogEntry),
            );
      }
      // Update local state
      if (!_activeJobs[jobIndex].containsKey('customerCommunicationLog')) {
        _activeJobs[jobIndex]['customerCommunicationLog'] = [];
      }
      (_activeJobs[jobIndex]['customerCommunicationLog'] as List).add(
        newLogEntry,
      );
      notifyListeners();
    }
  }

  Future<void> updateCompletionChecklistItem(
    String jobId,
    String item,
    bool isChecked,
  ) async {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (_activeJobs[jobIndex].containsKey('completionChecklist')) {
        if (MongoDbService.isConfigured) {
          // Update in MongoDB
          await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
              .updateOne(
                where.eq('id', jobId),
                ModifierBuilder().set('completionChecklist.$item', isChecked),
              );
        }
        // Update local state
        (_activeJobs[jobIndex]['completionChecklist']
                as Map<String, bool>)[item] =
            isChecked;
        notifyListeners();
      }
    }
  }

  Future<void> deleteDocument(String collectionName, String documentId) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(collectionName).deleteOne(where.eq('id', documentId));
    }
    // Optionally, refresh local data after deletion
    await loadData();
  }

  Future<void> addPartsRequest(
    String partName,
    String jobId, {
    String priority = 'Medium',
    double estimatedPrice = 0.0,
  }) async {
    final newPartsRequest = {
      '_id': ObjectId(),
      'id': 'PR-${DateTime.now().millisecondsSinceEpoch}',
      'partName': partName,
      'jobId': jobId,
      'priority': priority,
      'estimatedPrice': estimatedPrice,
      'status': 'Pending Approval',
      'requestDate': DateTime.now().toIso8601String(),
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.PARTS_REQUISITION_COLLECTION,
      ).insertOne(newPartsRequest);
      
      // Notify Manager
      await createNotification({
        'userId': 'manager-1',
        'title': 'New Parts Request',
        'message': 'Technician requested $partName for Job $jobId (Priority: $priority)',
        'type': 'parts_request',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });
    }
    _partsRequests.insert(0, newPartsRequest);
    notifyListeners();
  }

  Future<void> assignTechnicianToJob(String jobId, String technicianId) async {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
            .updateOne(
              where.eq('id', jobId),
              ModifierBuilder().addToSet('assignedTechnicians', technicianId),
            );
      }
      // Update local state
      if (!_activeJobs[jobIndex].containsKey('assignedTechnicians')) {
        _activeJobs[jobIndex]['assignedTechnicians'] = [];
      }
      (_activeJobs[jobIndex]['assignedTechnicians'] as List).add(technicianId);
      notifyListeners();
    }
  }

  Future<void> removeTechnicianFromJob(
    String jobId,
    String technicianId,
  ) async {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (MongoDbService.isConfigured) {
        // Update in MongoDB
        await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
            .updateOne(
              where.eq('id', jobId),
              ModifierBuilder().pull('assignedTechnicians', technicianId),
            );
      }
      // Update local state
      if (_activeJobs[jobIndex].containsKey('assignedTechnicians')) {
        (_activeJobs[jobIndex]['assignedTechnicians'] as List).remove(
          technicianId,
        );
      }
      notifyListeners();
    }
  }

  Future<void> recordClockIn(String technicianId) async {
    final clockInEntry = {
      '_id': ObjectId(),
      'technicianId': technicianId,
      'clockInTime': DateTime.now().toIso8601String(),
      'clockOutTime': null,
      'duration': null,
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.TIME_TRACKING_COLLECTION,
      ).insertOne(clockInEntry);
    }
    notifyListeners();
  }

  Future<void> recordClockOut(String technicianId, DateTime clockInTime) async {
    final clockOutTime = DateTime.now();
    final duration = clockOutTime.difference(clockInTime).inMinutes;

    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.TIME_TRACKING_COLLECTION,
      ).updateOne(
        where
            .eq('technicianId', technicianId)
            .and(where.eq('clockInTime', clockInTime.toIso8601String()))
            .and(where.eq('clockOutTime', null)),
        ModifierBuilder()
            .set('clockOutTime', clockOutTime.toIso8601String())
            .set('duration', duration),
      );
    }
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getMonthlyTimeTrackingHistory(
    String technicianId,
    int month,
    int year,
  ) async {
    if (MongoDbService.isConfigured) {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      final history =
          await MongoDbService.getCollection(
                MongoDbService.TIME_TRACKING_COLLECTION,
              )
              .find(
                where
                    .eq('technicianId', technicianId)
                    .and(where.gte('clockInTime', startOfMonth.toIso8601String()))
                    .and(where.lte('clockInTime', endOfMonth.toIso8601String())),
              )
              .toList();
      return history;
    }
    return [];
  }

  Future<int> getCompletedJobsCount({String? technicianId}) async {
    if (MongoDbService.isConfigured) {
      var selector = where.eq('status', 'Completed');
      if (technicianId != null) {
        selector = selector.and(where.all('assignedTechnicians', [technicianId]));
      }
      return await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION).count(selector);
    }
    return _activeJobs.where((j) => j['status'] == 'Completed' && (technicianId == null || (j['assignedTechnicians'] as List).contains(technicianId))).length;
  }

  Future<int> getPendingJobsCount({String? technicianId}) async {
    if (MongoDbService.isConfigured) {
      var selector = where.ne('status', 'Completed');
      if (technicianId != null) {
        selector = selector.and(where.all('assignedTechnicians', [technicianId]));
      }
      return await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION).count(selector);
    }
    return _activeJobs.where((j) => j['status'] != 'Completed' && (technicianId == null || (j['assignedTechnicians'] as List).contains(technicianId))).length;
  }

  Future<List<Map<String, dynamic>>> getAllJobs() async {
    if (MongoDbService.isConfigured) {
      return await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .find()
          .toList();
    }
    return _activeJobs;
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    if (MongoDbService.isConfigured) {
      return await MongoDbService.getCollection(MongoDbService.USERS_COLLECTION)
          .findOne(where.eq('id', userId));
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getCustomerVehicles(String userId) async {
    return _customerVehicles.where((v) => v['userId'] == userId).toList();
  }

  Future<void> addCustomerVehicle(Map<String, dynamic> vehicleData) async {
    final newVehicle = {
      '_id': ObjectId(),
      'id': 'V-${DateTime.now().millisecondsSinceEpoch}',
      ...vehicleData,
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(
        MongoDbService.CUSTOMER_VEHICLES_COLLECTION,
      ).insertOne(newVehicle);
    }
    _customerVehicles.add(newVehicle);
    notifyListeners();
  }

  Future<void> updateCustomerVehicle(String id, Map<String, dynamic> updateData) async {
    final index = _customerVehicles.indexWhere((v) => v['id'] == id || v['_id'].toString() == id);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        final modifier = ModifierBuilder();
        updateData.forEach((key, value) {
          modifier.set(key, value);
        });
        await MongoDbService.getCollection(MongoDbService.CUSTOMER_VEHICLES_COLLECTION)
            .updateOne(where.eq('id', id), modifier);
      }
      _customerVehicles[index].addAll(updateData);
      notifyListeners();
    }
  }

  Future<void> deleteCustomerVehicle(String id) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.CUSTOMER_VEHICLES_COLLECTION)
          .deleteOne(where.eq('id', id));
    }
    _customerVehicles.removeWhere((v) => v['id'] == id);
    notifyListeners();
  }

  Future<void> approveServiceRequest(String requestId, List<String> technicianIds) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .updateOne(
        where.eq('id', requestId),
        ModifierBuilder()
          .set('status', 'Appointment Approved')
          .set('assignedTechnicians', technicianIds),
      );


    }
    // Update local state
    final index = _activeJobs.indexWhere((j) => j['id'] == requestId || j['_id'].toString() == requestId);
    if (index != -1) {
      _activeJobs[index]['status'] = 'Appointment Approved';
      _activeJobs[index]['assignedTechnicians'] = technicianIds;
    }
    notifyListeners();
  }

  Future<void> rejectServiceRequest(String requestId) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .updateOne(where.eq('id', requestId), ModifierBuilder().set('status', 'Rejected'));
    }
    // Update local state
    final index = _activeJobs.indexWhere((j) => j['id'] == requestId || j['_id'].toString() == requestId);
    if (index != -1) {
      _activeJobs[index]['status'] = 'Rejected';
    }
    notifyListeners();
  }

  Future<void> rescheduleServiceRequest(String requestId, String newDate, String newTime) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .updateOne(
        where.eq('id', requestId),
        ModifierBuilder()
          .set('appointmentDate', newDate)
          .set('timeSlot', newTime)
          .set('status', 'Rescheduled'),
      );
    }
    // Update local state
    final index = _activeJobs.indexWhere((j) => j['id'] == requestId || j['_id'].toString() == requestId);
    if (index != -1) {
      _activeJobs[index]['appointmentDate'] = newDate;
      _activeJobs[index]['timeSlot'] = newTime;
      _activeJobs[index]['status'] = 'Rescheduled';
    }
    notifyListeners();
  }

  Future<void> addEmergencyRequest(Map<String, dynamic> requestData) async {
    final newRequest = {
      '_id': ObjectId(),
      'id': requestData['id'] ?? 'TR-${DateTime.now().millisecondsSinceEpoch}',
      ...requestData,
      'status': 'Pending Approval',
      'createdAt': DateTime.now().toIso8601String(),
    };
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.TOW_REQUESTS_COLLECTION)
          .insertOne(newRequest);
    }

    // Notify Manager
    await createNotification({
      'id': 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'manager-1',
      'title': 'New EMERGENCY Tow Request',
      'message': 'A new emergency tow request has been raised for vehicle ${requestData['plateNumber']}',
      'type': 'emergency',
      'timestamp': DateTime.now().toIso8601String(),
      'isRead': false,
    });

    _towRequests.add(newRequest);
    notifyListeners();
  }

  Future<void> updateTowRequestStatus(String requestId, String status) async {
    final index = _towRequests.indexWhere((r) => r['id'] == requestId || r['_id'].toString() == requestId);
    if (index != -1) {
      if (MongoDbService.isConfigured) {
        await MongoDbService.getCollection(MongoDbService.TOW_REQUESTS_COLLECTION)
            .updateOne(where.eq('id', requestId), ModifierBuilder().set('status', status));
      }
      _towRequests[index]['status'] = status;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getPartsRequisitions() async {
    if (MongoDbService.isConfigured) {
      return await MongoDbService.getCollection(MongoDbService.PARTS_REQUISITION_COLLECTION)
          .find()
          .toList();
    }
    return _partsRequests;
  }

  Future<void> updatePartsRequisitionStatus(String requisitionId, String status) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.PARTS_REQUISITION_COLLECTION)
          .updateOne(where.eq('id', requisitionId), ModifierBuilder().set('status', status));

      // If approved, update inventory stock
      if (status == 'Approved') {
        final req = await MongoDbService.getCollection(MongoDbService.PARTS_REQUISITION_COLLECTION)
            .findOne(where.eq('id', requisitionId));
        if (req != null) {
          final partName = req['partName'];
          await MongoDbService.getCollection(MongoDbService.INVENTORY_COLLECTION)
              .updateOne(where.eq('name', partName), ModifierBuilder().inc('stock', -1));
        }
      }
    }
    notifyListeners();
  }
  Future<void> generateInvoice(String jobId) async {
    if (MongoDbService.isConfigured) {
      final job = await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .findOne(where.eq('id', jobId));
      if (job != null) {
        final newInvoice = {
          'id': 'INV-${DateTime.now().millisecondsSinceEpoch}',
          'jobId': jobId,
          'customerId': job['customerId'],
          'amount': job['totalEstimate'] ?? 0.0,
          'date': DateTime.now().toIso8601String(),
          'status': 'Unpaid',
        };
        await MongoDbService.getCollection(MongoDbService.INVOICES_COLLECTION)
            .insertOne({'_id': ObjectId(), ...newInvoice});
        
        await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
            .updateOne(where.eq('id', jobId), ModifierBuilder().set('invoiceGenerated', true));
      }
    }
    notifyListeners();
  }

  Future<void> updatePaymentStatus(String invoiceId, String status) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.INVOICES_COLLECTION)
          .updateOne(where.eq('id', invoiceId), ModifierBuilder().set('status', status));
    }
  }

  Future<List<Map<String, dynamic>>> getCompletedJobs(String userId) async {
    if (MongoDbService.isConfigured) {
      return await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .find(where.eq('customerId', userId).and(where.eq('status', 'Completed')))
          .toList();
    }
    return [];
  }

  Future<void> submitReview(String jobId, double rating, String comment) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .updateOne(
        where.eq('id', jobId),
        ModifierBuilder().set('review', {'rating': rating, 'comment': comment, 'date': DateTime.now().toIso8601String()}),
      );
    }
    notifyListeners();
  }

  Future<void> createNotification(Map<String, dynamic> notificationData) async {
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.NOTIFICATIONS_COLLECTION)
          .insertOne({
        '_id': ObjectId(),
        ...notificationData,
      });
    }
    _notifications.insert(0, notificationData);
    notifyListeners();
  }

  Future<void> addServiceRequest(Map<String, dynamic> requestData) async {
    final String requestId = 'J-${DateTime.now().millisecondsSinceEpoch}';
    final newJob = {
      '_id': ObjectId(),
      'id': requestId,
      ...requestData,
    };
    
    if (MongoDbService.isConfigured) {
      await MongoDbService.getCollection(MongoDbService.JOBS_COLLECTION)
          .insertOne(newJob);
    }
    _activeJobs.insert(0, newJob);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getCustomerQuotes(String userId) async {
    return _customerQuotes.where((q) => q['userId'] == userId).toList();
  }

  Future<List<Map<String, dynamic>>> getTechnicians() async {
    if (MongoDbService.isConfigured) {
      return await MongoDbService.getCollection(MongoDbService.STAFF_COLLECTION)
          .find(where.eq('role', 'Technician').or(where.eq('role', 'Mechanic')))
          .toList();
    }
    return _staff.where((s) => s['role'] == 'Technician' || s['role'] == 'Mechanic').toList();
  }

  Future<Map<String, double>> getRevenueOverTime() async {
    if (MongoDbService.isConfigured) {
      final invoices = await MongoDbService.getCollection(MongoDbService.INVOICES_COLLECTION)
          .find()
          .toList();
      
      final Map<String, double> revenueMap = {};
      for (var inv in invoices) {
        final dateStr = inv['date'] as String;
        if (dateStr.length >= 10) {
          final dateKey = dateStr.substring(0, 10);
          final amount = (inv['amount'] as num?)?.toDouble() ?? 0.0;
          revenueMap[dateKey] = (revenueMap[dateKey] ?? 0.0) + amount;
        }
      }
      return revenueMap;
    }
    return {};
  }
}
