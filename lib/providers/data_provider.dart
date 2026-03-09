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
      'hours': '0h 0m'
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
      'id': 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'vehicle': 'Service Job $jobId',
      'amount': amount,
      'date': 'Today',
      'status': 'Paid'
    });
    notifyListeners();
  }
}
