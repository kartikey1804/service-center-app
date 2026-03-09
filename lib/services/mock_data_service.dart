class MockDataService {
  // Mock Jobs for Kanban / Manager
  static List<Map<String, dynamic>> getActiveJobs() {
    return [
      {
        'id': 'JOB-1042',
        'vehicle': 'Honda Civic 2019',
        'customer': 'John Doe',
        'service': 'Full Synthetic Oil Change',
        'status': 'To Start',
        'date': 'Today, 09:00 AM',
      },
      {
        'id': 'JOB-1045',
        'vehicle': 'Yamaha R15 2021',
        'customer': 'Alice Smith',
        'service': 'Brake Pad Replacement',
        'status': 'In Progress',
        'date': 'Today, 10:30 AM',
      },
      {
        'id': 'JOB-1048',
        'vehicle': 'Toyota Corolla 2020',
        'customer': 'Bob Johnson',
        'service': 'Engine Diagnostics',
        'status': 'Ready',
        'date': 'Today, 02:00 PM',
      },
    ];
  }

  // Mock Inventory for Admin
  static List<Map<String, dynamic>> getInventory() {
    return [
      {'id': 'PART-001', 'name': 'Synthetic Engine Oil 5W-30', 'stock': 120, 'minThreshold': 50, 'price': 45.00},
      {'id': 'PART-002', 'name': 'Ceramic Brake Pads (Front)', 'stock': 15, 'minThreshold': 20, 'price': 85.00},
      {'id': 'PART-003', 'name': 'Air Filter Universal', 'stock': 8, 'minThreshold': 15, 'price': 22.50},
      {'id': 'PART-004', 'name': 'Spark Plugs (Set of 4)', 'stock': 45, 'minThreshold': 20, 'price': 35.00},
    ];
  }

  // Mock Vehicles for Customer
  static List<Map<String, dynamic>> getCustomerVehicles() {
    return [
      {'id': 'V-101', 'make': 'Honda', 'model': 'Civic', 'year': 2019, 'plate': 'ABC-123', 'nextService': 'Oct 15, 2026'},
      {'id': 'V-102', 'make': 'Yamaha', 'model': 'MT-07', 'year': 2022, 'plate': 'XYZ-987', 'nextService': 'Dec 20, 2026'},
    ];
  }

  // Mock Quotes for Customer
  static List<Map<String, dynamic>> getCustomerQuotes() {
    return [
      {
        'id': 'QUOTE-884',
        'vehicle': 'Honda Civic 2019',
        'description': 'Replace worn brake pads strongly recommended after inspection.',
        'amount': 210.00,
        'status': 'Pending'
      }
    ];
  }

  // Mock Stats for Manager/Owner
  static Map<String, dynamic> getDashboardStats() {
    return {
      'revenueToday': 12450.00,
      'activeJobs': 14,
      'completedJobs': 28,
      'partsLowStock': 3,
      'techniciansOnline': 8,
    };
  }

  // Phase 2 Additions
  static List<Map<String,dynamic>> getNotifications() {
     return [
       {'id': 'notif-1', 'title': 'System maintenance tonight.', 'isRead': false, 'time': '10 mins ago'},
       {'id': 'notif-2', 'title': 'New Quote Approval: MT-07', 'isRead': true, 'time': '1 hr ago'},
     ];
  }

  static List<Map<String,dynamic>> getInvoices() {
     return [
       {'id': 'INV-9002', 'vehicle': 'Honda Civic 2019', 'amount': 120.00, 'date': 'Oct 10, 2026', 'status': 'Paid'},
     ];
  }

  static List<Map<String,dynamic>> getStaff() {
     return [
      {'id': 'tech-1', 'name': 'Mike Technician', 'role': 'Lead Temp', 'status': 'Online', 'hours': '3h 45m'},
      {'id': 'tech-2', 'name': 'Alex Rivera', 'role': 'Junior Tech', 'status': 'Offline', 'hours': '0h 0m'},
      {'id': 'tech-3', 'name': 'David Chen', 'role': 'Mechanic', 'status': 'Online', 'hours': '5h 10m'},
    ];
  }
}
