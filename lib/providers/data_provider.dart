import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class DataProvider extends ChangeNotifier {
  String _storeName = 'AutoCare Hub';
  List<Map<String, dynamic>> _activeJobs = [];
  List<Map<String, dynamic>> _inventory = [];
  List<Map<String, dynamic>> _customerVehicles = [];
  List<Map<String, dynamic>> _customerQuotes = [];
  Map<String, dynamic> _stats = {};

  // Phase 2
  List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _staff = [];
  List<Map<String, dynamic>> _partsRequests = [];
  List<Map<String, dynamic>> _chatConversations = [];
  Map<String, dynamic> _technicianPerformanceMetrics = {};

  bool _isLoading = false;

  String get storeName => _storeName;
  List<Map<String, dynamic>> get activeJobs => _activeJobs;
  List<Map<String, dynamic>> get inventory => _inventory;
  List<Map<String, dynamic>> get customerVehicles => _customerVehicles;
  List<Map<String, dynamic>> get customerQuotes => _customerQuotes;
  Map<String, dynamic> get stats => _stats;

  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get invoices => _invoices;
  List<Map<String, dynamic>> get staff => _staff;
  List<Map<String, dynamic>> get partsRequests => _partsRequests;
  List<Map<String, dynamic>> get chatConversations => _chatConversations;
  Map<String, dynamic> get technicianPerformanceMetrics =>
      _technicianPerformanceMetrics;

  bool get isLoading => _isLoading;

  DataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    _activeJobs = MockDataService.getActiveJobs();
    _inventory = MockDataService.getInventory();
    _customerVehicles = MockDataService.getCustomerVehicles();
    _customerQuotes = MockDataService.getCustomerQuotes();
    _stats = MockDataService.getDashboardStats();

    _notifications = MockDataService.getNotifications();
    _invoices = MockDataService.getInvoices();
    _staff = MockDataService.getStaff();
    _partsRequests = MockDataService.getPartsRequests();
    _chatConversations = MockDataService.getChatConversations();
    _technicianPerformanceMetrics =
        MockDataService.getTechnicianPerformanceMetrics();

    _isLoading = false;
    notifyListeners();
  }

  void updateJobStatus(String jobId, String newStatus) {
    final index = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (index != -1) {
      _activeJobs[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  void updateInspectionChecklistItem(
    String jobId,
    String item,
    bool isChecked,
  ) {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (_activeJobs[jobIndex].containsKey('inspectionChecklist')) {
        (_activeJobs[jobIndex]['inspectionChecklist']
                as Map<String, bool>)[item] =
            isChecked;
        notifyListeners();
      }
    }
  }

  void approveQuote(String quoteId) {
    final index = _customerQuotes.indexWhere((q) => q['id'] == quoteId);
    if (index != -1) {
      _customerQuotes[index]['status'] = 'Approved';
      notifyListeners();
    }
  }

  void denyQuote(String quoteId) {
    final index = _customerQuotes.indexWhere((q) => q['id'] == quoteId);
    if (index != -1) {
      _customerQuotes[index]['status'] = 'Denied';
      notifyListeners();
    }
  }

  void orderPart(String partId) {
    // Just a mock action hook
    final index = _inventory.indexWhere((p) => p['id'] == partId);
    if (index != -1) {
      _inventory[index]['stock'] += 50; // Add generic stock count
      notifyListeners();
    }
  }

  void updateStoreName(String newName) {
    _storeName = newName;
    notifyListeners();
  }

  void addEmployee(String name, String role) {
    _staff.add({
      'id': 'tech-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'role': role,
      'status': 'Offline',
      'hours': '0h 0m',
    });
    notifyListeners();
  }

  void addStaffMember(Map<String, dynamic> NewEmployee) {
    _staff.add({
      'id': 'tech-${DateTime.now().millisecondsSinceEpoch}',
      ...NewEmployee,
    });
    notifyListeners();
  }

  void generateInvoice(String jobId, double amount) {
    _invoices.insert(0, {
      'id':
          'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'vehicle': 'Service Job $jobId',
      'amount': amount,
      'date': 'Today',
      'status': 'Paid',
    });
    notifyListeners();
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  void addChatMessage(String chatId, String sender, String message) {
    final chatIndex = _chatConversations.indexWhere(
      (chat) => chat['id'] == chatId,
    );
    if (chatIndex != -1) {
      (_chatConversations[chatIndex]['messages'] as List).add({
        'sender': sender,
        'message': message,
        'time': 'Just now',
      });
      _chatConversations[chatIndex]['lastMessage'] = message;
      _chatConversations[chatIndex]['lastMessageTime'] = 'Just now';
      notifyListeners();
    }
  }

  void sendMockReply(String chatId) {
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

      Future.delayed(const Duration(seconds: 2), () {
        (_chatConversations[chatIndex]['messages'] as List).add({
          'sender': sender,
          'message': 'Okay, got it. Will look into that.',
          'time': 'Just now',
        });
        _chatConversations[chatIndex]['lastMessage'] =
            'Okay, got it. Will look into that.';
        _chatConversations[chatIndex]['lastMessageTime'] = 'Just now';
        notifyListeners();
      });
    }
  }

  void updateJobEstimatedTime(String jobId, String newTime) {
    final index = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (index != -1) {
      _activeJobs[index]['estimatedCompletionTime'] = newTime;
      notifyListeners();
    }
  }

  void addCustomerCommunicationLogEntry(
    String jobId,
    String type,
    String message,
  ) {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (!_activeJobs[jobIndex].containsKey('customerCommunicationLog')) {
        _activeJobs[jobIndex]['customerCommunicationLog'] = [];
      }
      (_activeJobs[jobIndex]['customerCommunicationLog'] as List).add({
        'type': type,
        'message': message,
        'timestamp': 'Just now', // In a real app, use DateTime.now()
      });
      notifyListeners();
    }
  }

  void updateCompletionChecklistItem(
    String jobId,
    String item,
    bool isChecked,
  ) {
    final jobIndex = _activeJobs.indexWhere((j) => j['id'] == jobId);
    if (jobIndex != -1) {
      if (_activeJobs[jobIndex].containsKey('completionChecklist')) {
        (_activeJobs[jobIndex]['completionChecklist']
                as Map<String, bool>)[item] =
            isChecked;
        notifyListeners();
      }
    }
  }
}
