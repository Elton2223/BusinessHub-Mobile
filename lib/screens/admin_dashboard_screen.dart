import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/jobhub_provider.dart';
import '../model/user_model.dart';
import '../model/jobhub_model.dart';
import '../services/jobhub_service.dart';
import '../widgets/admin_access_wrapper.dart';
import '../utils/responsive_utils.dart';
import '../utils/responsive_theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with ResponsiveWidgetMixin {
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<UserModel> _recentUsers = [];
  List<JobhubModel> _recentJobhubs = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load statistics and recent data
      await Future.wait([
        _loadStatistics(),
        _loadRecentUsers(),
        _loadRecentJobhubs(),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final jobhubCount = await JobhubService.getJobhubCount();
      
      setState(() {
        _stats = {
          'totalUsers': 25, // Mock data for now
          'totalJobhubs': jobhubCount,
          'activeUsers': 18, // Mock data
          'newUsers': 3, // Mock data
        };
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> _loadRecentUsers() async {
    try {
      // Mock data for now - replace with actual API call when available
      setState(() {
        _recentUsers = [
          UserModel(id: '1', name: 'John', surname: 'Doe', email: 'john@example.com', city: 'New York', ratings: 4),
          UserModel(id: '2', name: 'Jane', surname: 'Smith', email: 'jane@example.com', city: 'Los Angeles', ratings: 5),
          UserModel(id: '3', name: 'Bob', surname: 'Johnson', email: 'bob@example.com', city: 'Chicago', ratings: 3),
        ];
      });
    } catch (e) {
      print('Error loading recent users: $e');
    }
  }

  Future<void> _loadRecentJobhubs() async {
    try {
      final jobhubs = await JobhubService.getAllJobhubs();
      setState(() {
        _recentJobhubs = jobhubs.take(5).toList();
      });
    } catch (e) {
      print('Error loading recent jobhubs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return AdminAccessWrapper(
      adminContent: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    responsive.isExtraSmallScreen ? 12 : 16,
                    responsive.isExtraSmallScreen ? 12 : 16,
                    responsive.isExtraSmallScreen ? 12 : 16,
                    MediaQuery.of(context).padding.bottom + (responsive.isExtraSmallScreen ? 16 : 20), // Reduced bottom padding
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      SizedBox(height: responsive.isExtraSmallScreen ? 6 : 8),
                      _buildStatisticsCards(),
                      SizedBox(height: responsive.isExtraSmallScreen ? 6 : 8),
                      _buildRecentUsersSection(),
                      SizedBox(height: responsive.isExtraSmallScreen ? 6 : 8),
                      _buildRecentJobhubsSection(),
                      SizedBox(height: responsive.isExtraSmallScreen ? 6 : 8),
                      _buildQuickActionsSection(),
                      SizedBox(height: responsive.isExtraSmallScreen ? 6 : 8),
                      _buildSystemStatusSection(),
                      // Add extra bottom spacing to prevent overflow
                      SizedBox(height: responsive.isExtraSmallScreen ? 12 : 16),
                      
                      // Add responsive bottom safe area
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final responsive = context.responsive;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isTablet ? 20 : 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(responsive.isTablet ? 18 : 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message spanning full width
          Text(
            'Welcome back, ${user?.name ?? 'Admin'}! 👋',
            style: TextStyle(
              fontSize: responsive.isTablet ? 32 : (responsive.isExtraSmallScreen ? 22 : 26),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: responsive.isExtraSmallScreen ? 4 : 8),
          Text(
            'Here\'s what\'s happening with your BusinessHub today.',
            style: TextStyle(
              fontSize: responsive.isTablet ? 18 : (responsive.isExtraSmallScreen ? 14 : 16),
              color: Colors.white70,
            ),
          ),
          SizedBox(height: responsive.isExtraSmallScreen ? 8 : 12),
          // Date and time in a smaller, less prominent section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.isTablet ? 16 : 12,
                  vertical: responsive.isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(responsive.isTablet ? 12 : 8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _getCurrentDate(),
                      style: TextStyle(
                        fontSize: responsive.isTablet ? 12 : 10,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _getCurrentTime(),
                      style: TextStyle(
                        fontSize: responsive.isTablet ? 14 : 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final responsive = context.responsive;
    return Container(
      constraints: BoxConstraints(
        maxHeight: responsive.isExtraSmallScreen ? 180 : (responsive.isTablet ? 280 : 230),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: responsive.isExtraSmallScreen ? 1 : (responsive.isTablet ? 4 : 2),
        crossAxisSpacing: responsive.isTablet ? 14 : (responsive.isExtraSmallScreen ? 5 : 8),
        mainAxisSpacing: responsive.isTablet ? 14 : (responsive.isExtraSmallScreen ? 5 : 8),
        childAspectRatio: responsive.isTablet ? 1.9 : (responsive.isExtraSmallScreen ? 2.4 : 1.6),
        children: [
          _buildStatCard(
            'Total Users',
            '${_stats['totalUsers'] ?? 0}',
            Icons.people,
            Colors.blue,
            '${_stats['growthRate'] ?? 12}% growth',
          ),
          _buildStatCard(
            'Active Users',
            '${_stats['activeUsers'] ?? 0}',
            Icons.check_circle,
            Colors.green,
            '${((_stats['activeUsers'] ?? 0) / (_stats['totalUsers'] ?? 1) * 100).round()}% engagement',
          ),
          _buildStatCard(
            'New Users',
            '${_stats['newUsers'] ?? 0}',
            Icons.person_add,
            Colors.orange,
            'This month',
          ),
          _buildStatCard(
            'Total Jobhubs',
            '${_stats['totalJobhubs'] ?? 0}',
            Icons.work,
            Colors.purple,
            'Available spaces',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    final responsive = context.responsive;
    return Container(
      padding: EdgeInsets.all(responsive.isTablet ? 14 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 14 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(responsive.isTablet ? 6 : 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: responsive.isTablet ? 18 : 16),
          ),
          SizedBox(height: responsive.isTablet ? 6 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: responsive.isTablet ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: responsive.isTablet ? 2 : 1),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.isTablet ? 12 : 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: responsive.isTablet ? 4 : 3),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: responsive.isTablet ? 10 : 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUsersSection() {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Users',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to users list
                },
                child: const Text('View all →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentUsers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No recent users',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._recentUsers.map((user) => _buildUserItem(user)),
        ],
      ),
    );
  }

  Widget _buildUserItem(UserModel user) {
    final responsive = context.responsive;
    return Container(
      margin: EdgeInsets.only(bottom: responsive.isTablet ? 16 : 8),
      padding: EdgeInsets.all(responsive.isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(responsive.isTablet ? 16 : 12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _getUserInitials(user),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name} ${user.surname}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${user.email}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user.city ?? 'N/A',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (user.ratings != null && user.ratings! > 0)
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${user.ratings}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentJobhubsSection() {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Jobhubs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to jobhubs list
                },
                child: const Text('View all →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_recentJobhubs.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No recent jobhubs',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._recentJobhubs.map((jobhub) => _buildJobhubItem(jobhub)),
        ],
      ),
    );
  }

  Widget _buildJobhubItem(JobhubModel jobhub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(jobhub.jobStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                jobhub.categoryIcon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobhub.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  jobhub.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(jobhub.jobStatus),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  jobhub.jobStatusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                jobhub.formattedPaymentAmount,
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionItem(
            'Manage Users',
            Icons.people,
            Colors.blue,
            () {
              // Navigate to users management
            },
          ),
          const SizedBox(height: 8),
          _buildQuickActionItem(
            'Manage Jobhubs',
            Icons.work,
            Colors.green,
            () {
              // Navigate to jobhubs management
            },
          ),
          const SizedBox(height: 8),
          _buildQuickActionItem(
            'View Analytics',
            Icons.analytics,
            Colors.orange,
            () {
              // Navigate to analytics
            },
          ),
          const SizedBox(height: 8),
          _buildQuickActionItem(
            'Settings',
            Icons.settings,
            Colors.purple,
            () {
              // Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, Color color, VoidCallback onTap) {
    final responsive = context.responsive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.isTablet ? 16 : 12),
      child: Container(
        padding: EdgeInsets.all(responsive.isTablet ? 20 : 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(responsive.isTablet ? 16 : 12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusSection() {
    final responsive = context.responsive;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusItem('Backend API', 'Online', true),
          const SizedBox(height: 8),
          _buildStatusItem('Database', 'Connected', true),
          const SizedBox(height: 8),
          _buildStatusItem('Mobile App', 'Synced', true),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String service, String status, bool isOnline) {
    final responsive = context.responsive;
    return Container(
      padding: EdgeInsets.all(responsive.isTablet ? 16 : 10),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(responsive.isTablet ? 12 : 8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            service,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              color: isOnline ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${_getDayName(now.weekday)}, ${_getMonthName(now.month)} ${now.day}, ${now.year}';
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getUserInitials(UserModel user) {
    final firstName = user.name ?? '';
    final lastName = user.surname ?? '';
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    }
    return 'U';
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1: // Available
        return Colors.green;
      case 2: // In Progress
        return Colors.orange;
      case 3: // Completed
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
