class MockDataService {
  // Mock Jobs for Kanban / Manager
  static List<Map<String, dynamic>> getActiveJobs() {
    return [
      {
        'id': 'JOB-1042',
        'vehicle': 'Tesla Model 3 2022',
        'image': 'assets/images/car_tesla.png',
        'customer': 'John Doe',
        'service': 'Wheel Alignment & Balancing',
        'status': 'To Start',
        'date': 'Today, 09:00 AM',
        'estimatedCompletionTime': '1h 30m',
        'inspectionChecklist': {
          'Check Tire Pressure': false,
          'Inspect Wheel Bearings': false,
          'Check Suspension Components': false,
          'Verify Alignment': false,
        },
        'customerCommunicationLog': [
          {
            'type': 'Call',
            'message': 'Customer confirmed service appointment.',
            'timestamp': 'Today, 08:30 AM',
          },
        ],
        'completionChecklist': {
          'Final Quality Check': false,
          'Vehicle Cleaned': false,
          'Paperwork Completed': false,
          'Customer Notified': false,
        },
      },
      {
        'id': 'JOB-1045',
        'vehicle': 'Yamaha R15 2021',
        'image':
            'assets/images/bike_ducati.png', // Using ducati as a generic sporty bike image
        'customer': 'Alice Smith',
        'service': 'Brake Pad Replacement',
        'status': 'In Progress',
        'date': 'Today, 10:30 AM',
        'estimatedCompletionTime': '2h 0m',
        'inspectionChecklist': {
          'Inspect Brake Pads': true,
          'Check Brake Fluid Level': false,
          'Examine Rotors/Discs': false,
          'Test Brake Functionality': false,
        },
        'customerCommunicationLog': [
          {
            'type': 'SMS',
            'message': 'Sent update: Brakes are being replaced.',
            'timestamp': 'Today, 11:00 AM',
          },
        ],
        'completionChecklist': {
          'Final Brake Test': false,
          'Road Test Completed': false,
          'Invoice Generated': false,
        },
      },
      {
        'id': 'JOB-1048',
        'vehicle': 'BMW M4 Competition',
        'image': 'assets/images/car_bmw.png',
        'customer': 'Bob Johnson',
        'service': 'Engine Diagnostics',
        'status': 'Ready',
        'date': 'Today, 02:00 PM',
        'estimatedCompletionTime': '0h 45m',
        'inspectionChecklist': {
          'Connect Diagnostic Tool': true,
          'Check Error Codes': true,
          'Inspect Engine Bay': true,
          'Test Drive Vehicle': false,
        },
        'customerCommunicationLog': [
          {
            'type': 'Email',
            'message': 'Sent diagnostic report to customer.',
            'timestamp': 'Today, 01:30 PM',
          },
          {
            'type': 'Call',
            'message': 'Customer approved engine repair.',
            'timestamp': 'Today, 01:45 PM',
          },
        ],
        'completionChecklist': {
          'Engine Performance Check': false,
          'Fluid Levels Topped': false,
          'Diagnostic Report Finalized': false,
        },
      },
      {
        'id': 'JOB-1050',
        'vehicle': 'Harley Davidson Iron 883',
        'image': 'assets/images/bike_harley.png',
        'customer': 'Charlie Brown',
        'service': 'Oil Filter Change',
        'status': 'To Start',
        'date': 'Tomorrow, 10:00 AM',
        'estimatedCompletionTime': '1h 0m',
        'inspectionChecklist': {
          'Drain Old Oil': false,
          'Replace Oil Filter': false,
          'Add New Oil': false,
          'Check for Leaks': false,
        },
        'customerCommunicationLog': [],
        'completionChecklist': {
          'Oil Level Check': false,
          'Filter Disposal': false,
          'Service Sticker Applied': false,
        },
      },
    ];
  }

  // Mock Inventory for Admin
  static List<Map<String, dynamic>> getInventory() {
    return [
      {
        'id': 'PART-001',
        'name': 'Synthetic Engine Oil 5W-30',
        'stock': 120,
        'minThreshold': 50,
        'price': 45.00,
      },
      {
        'id': 'PART-002',
        'name': 'Ceramic Brake Pads (Front)',
        'stock': 15,
        'minThreshold': 20,
        'price': 85.00,
      },
      {
        'id': 'PART-003',
        'name': 'Air Filter Universal',
        'stock': 8,
        'minThreshold': 15,
        'price': 22.50,
      },
      {
        'id': 'PART-004',
        'name': 'Spark Plugs (Set of 4)',
        'stock': 45,
        'minThreshold': 20,
        'price': 35.00,
      },
    ];
  }

  // Mock Vehicles for Customer
  static List<Map<String, dynamic>> getCustomerVehicles() {
    return [
      {
        'id': 'V-101',
        'make': 'Tesla',
        'model': 'Model 3',
        'year': 2022,
        'plate': 'ELC-TRIC',
        'image': 'assets/images/car_tesla.png',
        'nextService': 'Oct 15, 2026',
      },
      {
        'id': 'V-102',
        'make': 'Harley Davidson',
        'model': 'Iron 883',
        'year': 2021,
        'plate': 'CRU-ISER',
        'image': 'assets/images/bike_harley.png',
        'nextService': 'Dec 20, 2026',
      },
    ];
  }

  // Mock Quotes for Customer
  static List<Map<String, dynamic>> getCustomerQuotes() {
    return [
      {
        'id': 'QUOTE-884',
        'vehicle': 'Tesla Model 3',
        'description':
            'Full detailed detailing and ceramic coating for winter protection.',
        'amount': 450.00,
        'status': 'Pending',
      },
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
  static List<Map<String, dynamic>> getNotifications() {
    return [
      {
        'id': 'notif-1',
        'title': 'System maintenance tonight.',
        'isRead': false,
        'time': '10 mins ago',
      },
      {
        'id': 'notif-2',
        'title': 'New Quote Approval: Iron 883',
        'isRead': true,
        'time': '1 hr ago',
      },
    ];
  }

  static List<Map<String, dynamic>> getInvoices() {
    return [
      {
        'id': 'INV-9002',
        'vehicle': 'Tesla Model 3 2022',
        'amount': 120.00,
        'date': 'Oct 10, 2026',
        'status': 'Paid',
      },
    ];
  }

  static List<Map<String, dynamic>> getStaff() {
    return [
      {
        'id': 'tech-1',
        'name': 'Mike Ross',
        'role': 'Lead Technician',
        'status': 'Online',
        'hours': '3h 45m',
        'image': 'assets/images/staff_mechanic_1.png',
      },
      {
        'id': 'tech-2',
        'name': 'Alex Rivera',
        'role': 'Junior Tech',
        'status': 'Offline',
        'hours': '0h 0m',
        'image': 'assets/images/staff_mechanic_1.png',
      },
      {
        'id': 'tech-3',
        'name': 'David Chen',
        'role': 'Mechanic',
        'status': 'Online',
        'hours': '5h 10m',
        'image': 'assets/images/staff_mechanic_1.png',
      },
    ];
  }

  static List<Map<String, dynamic>> getPartsRequests() {
    return [
      {
        'id': 'PR-001',
        'partName': 'Ceramic Brake Pads (Front)',
        'jobId': 'JOB-1045',
        'status': 'Pending Approval',
        'requestDate': 'Today, 11:00 AM',
      },
      {
        'id': 'PR-002',
        'partName': 'Air Filter Universal',
        'jobId': 'JOB-1042',
        'status': 'Approved',
        'requestDate': 'Today, 09:30 AM',
      },
      {
        'id': 'PR-003',
        'partName': 'Spark Plugs (Set of 4)',
        'jobId': 'JOB-1050',
        'status': 'Ordered',
        'requestDate': 'Yesterday, 04:00 PM',
      },
    ];
  }

  static List<Map<String, dynamic>> getChatConversations() {
    return [
      {
        'id': 'chat-1',
        'participants': ['Mike Ross', 'Alex Rivera'],
        'lastMessage': 'Hey Alex, need help with JOB-1045.',
        'lastMessageTime': '2 mins ago',
        'messages': [
          {
            'sender': 'Mike Ross',
            'message':
                'Hey Alex, need help with JOB-1045. The brake caliper bolt is stuck.',
            'time': '2 mins ago',
          },
          {
            'sender': 'Alex Rivera',
            'message': 'On my way, Mike. Bringing the impact wrench.',
            'time': '1 min ago',
          },
        ],
      },
      {
        'id': 'chat-2',
        'participants': ['Mike Ross', 'Manager'],
        'lastMessage': 'JOB-1042 needs parts approval.',
        'lastMessageTime': '15 mins ago',
        'messages': [
          {
            'sender': 'Mike Ross',
            'message':
                'Manager, JOB-1042 needs parts approval for the air filter.',
            'time': '15 mins ago',
          },
          {
            'sender': 'Manager',
            'message': 'Approved. Parts department notified.',
            'time': '10 mins ago',
          },
        ],
      },
    ];
  }

  static Map<String, dynamic> getTechnicianPerformanceMetrics() {
    return {
      'averageCompletionTime': '2h 30m',
      'customerSatisfaction': '4.8/5',
      'efficiencyScore': '92%',
      'jobsCompletedLastWeek': 18,
      'partsUsedLastWeek': 45,
    };
  }
}
