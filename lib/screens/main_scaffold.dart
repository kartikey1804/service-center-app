import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/data_provider.dart';
import 'customer/customer_dashboard.dart';
import 'customer/customer_garage.dart';
import 'customer/book_service.dart';
import 'customer/service_history.dart';
import 'technician/tech_dashboard.dart';
import 'technician/tech_job_board.dart';
import 'manager/manager_dashboard.dart';
import 'manager/staff_attendance.dart';
import 'manager/active_jobs_list.dart';
import 'admin/inventory_management.dart';
import 'owner/hq_analytics.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  bool _isChatOpen = false;

  void setTab(int index) {
     setState(() {
       _currentIndex = index;
     });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) {
      // Redirect handled by router theoretically, but fallback:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCustomer = user.role == UserRole.customer;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(LucideIcons.car, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(Provider.of<DataProvider>(context).storeName, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          _buildNotificationIcon(context),
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? LucideIcons.sun : LucideIcons.moon),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () async {
              await auth.logout();
              if (mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (!isCustomer && isDesktop) _buildSidebar(context),
          Expanded(
            child: _buildBody(user.role),
          ),
        ],
      ),
      bottomNavigationBar: (isCustomer || !isDesktop) ? _buildBottomNav(user.role) : null,
      floatingActionButton: _buildChatWidget(context),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    final notifications = Provider.of<DataProvider>(context).notifications;
    final unreadCount = notifications.where((n) => n['isRead'] == false).length;

    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          const Icon(LucideIcons.bell),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            )
        ],
      ),
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            enabled: false,
            child: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...notifications.map((n) {
            return PopupMenuItem<String>(
              value: n['id'],
              child: ListTile(
                leading: Icon(n['isRead'] ? Icons.notifications_none : Icons.notifications_active, color: n['isRead'] ? Colors.grey : Colors.blue),
                title: Text(n['title'], style: TextStyle(fontSize: 14, fontWeight: n['isRead'] ? FontWeight.normal : FontWeight.bold)),
                subtitle: Text(n['time'], style: const TextStyle(fontSize: 12)),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            );
          }).toList(),
        ];
      },
    );
  }

  Widget _buildChatWidget(BuildContext context) {
    final role = Provider.of<AuthProvider>(context, listen: false).currentUser?.role;
    if (role == UserRole.admin || role == UserRole.owner || role == null) {
        return const SizedBox.shrink(); // Hide chat for admin/owner
    }

    if (!_isChatOpen) {
      return FloatingActionButton(
        onPressed: () => setState(() => _isChatOpen = true),
        child: const Icon(LucideIcons.messageSquare),
      );
    }

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Support Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                InkWell(
                  onTap: () => setState(() => _isChatOpen = false),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8, right: 40),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Hello! How can we help you today?'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8, left: 40),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Text('I have a question about my recent service quote.'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UserRole role) {
    if (role == UserRole.customer) {
      switch (_currentIndex) {
        case 0: return const CustomerDashboard();
        case 1: return const BookService();
        case 2: return const CustomerGarage();
        case 3: return const ServiceHistory();
        default: return const CustomerDashboard();
      }
    }
    if (role == UserRole.technician) {
      switch (_currentIndex) {
        case 0: return const TechDashboard();
        case 1: return const TechJobBoard();
        default: return const TechDashboard();
      }
    }
    if (role == UserRole.manager) {
      switch (_currentIndex) {
        case 0: return const ManagerDashboard();
        case 1: return const StaffAttendance();
        case 2: return const ActiveJobsList();
        default: return const ManagerDashboard();
      }
    }
    if (role == UserRole.admin) {
      switch (_currentIndex) {
        case 0: return const ManagerDashboard(); // Reusing overview
        case 1: return const InventoryManagement();
        case 2: return const Center(child: Text('Settings Placeholder'));
        default: return const ManagerDashboard();
      }
    }
    if (role == UserRole.owner) {
      switch (_currentIndex) {
        case 0: return const ManagerDashboard(); // Reusing overview
        case 1: return const HqAnalytics();
        default: return const ManagerDashboard();
      }
    }
    return Center(
      child: Text('Dashboard for ${role.name.toUpperCase()} - Tab $_currentIndex'),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: _getNavItems(Provider.of<AuthProvider>(context, listen: false).currentUser!.role)
            .asMap()
            .entries
            .map((e) {
          final index = e.key;
          final item = e.value;
          final isSelected = _currentIndex == index;
          return ListTile(
            leading: Icon(item.icon, color: isSelected ? Theme.of(context).primaryColor : null),
            title: Text(item.label,
                style: TextStyle(
                    color: isSelected ? Theme.of(context).primaryColor : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            selected: isSelected,
            selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
            onTap: () {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNav(UserRole role) {
    final items = _getNavItems(role);
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: items
          .map((item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ))
          .toList(),
    );
  }

  List<_NavItem> _getNavItems(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return [
          _NavItem(LucideIcons.home, 'Home'),
          _NavItem(LucideIcons.calendar, 'Book'),
          _NavItem(LucideIcons.car, 'Garage'),
          _NavItem(LucideIcons.history, 'History'),
        ];
      case UserRole.technician:
        return [
          _NavItem(LucideIcons.layoutDashboard, 'Dashboard'),
          _NavItem(LucideIcons.columns, 'Job Board'),
        ];
      case UserRole.manager:
        return [
          _NavItem(LucideIcons.layoutDashboard, 'Dashboard'),
          _NavItem(LucideIcons.users, 'Staff'),
          _NavItem(LucideIcons.list, 'All Jobs'),
        ];
      case UserRole.admin:
        return [
          _NavItem(LucideIcons.layoutDashboard, 'Dashboard'),
          _NavItem(LucideIcons.package, 'Inventory'),
          _NavItem(LucideIcons.settings, 'Settings'),
        ];
      case UserRole.owner:
        return [
          _NavItem(LucideIcons.layoutDashboard, 'HQ Stats'),
          _NavItem(LucideIcons.barChart2, 'Analytics'),
        ];
    }
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  _NavItem(this.icon, this.label);
}
