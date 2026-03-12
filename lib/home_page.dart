import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'widgets/admin_navigation_menu.dart';
import 'utils/responsive_utils.dart';
import 'services/hub_repository.dart';
import 'services/notification_service.dart';
import 'services/work_session_service.dart';
import 'services/location_tracking_service.dart';
import 'providers/auth_provider.dart';
import 'hubs/hub_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ResponsiveWidgetMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _unreadNotificationCount = 0;
  int _activeWorkCount = 0;
  static bool _locationPromptShownThisSession = false;
  Future<List<dynamic>>? _nearbyHubsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCounts();
      _maybePromptLocation();
      _nearbyHubsFuture ??= _loadAvailableJobhubs();
      if (mounted) setState(() {});
    });
  }

  Future<void> _maybePromptLocation() async {
    if (!mounted || _locationPromptShownThisSession) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final hasLocation = user.latitude != null && user.longitude != null;
    if (hasLocation) return;
    _locationPromptShownThisSession = true;
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Use your location?'),
        content: const Text(
          'Allow BusinessHub to use your location to find nearby hubs and set your location when posting jobs. You can change this later in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final position = await LocationTrackingService.getCurrentPosition();
              if (position != null && mounted) {
                await context.read<AuthProvider>().updateUserLocation(
                  position.latitude,
                  position.longitude,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location updated. You can find nearby hubs and post with your location.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not get location. You can enable it in device settings.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshCounts() async {
    if (!mounted) return;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    try {
      final results = await Future.wait([
        NotificationService.getUnreadCount(userId),
        WorkSessionService.getActiveSessionsForWorker(userId),
      ]);
      if (mounted) {
        setState(() {
          _unreadNotificationCount = results[0] as int;
          _activeWorkCount = (results[1] as List).length;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => scaffoldKey.currentState!.openDrawer(),
        ),
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 22 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Badge(
            isLabelVisible: _unreadNotificationCount > 0,
            label: Text(
              _unreadNotificationCount > 99 ? '99+' : '$_unreadNotificationCount',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 26),
              onPressed: () async {
                await Navigator.pushNamed(context, '/notifications');
                if (mounted) _refreshCounts();
              },
            ),
          ),
        ],
      ),
      drawer: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          final userName = user != null ? '${user.name ?? ''} ${user.surname ?? ''}'.trim() : 'Guest';
          final userEmail = user?.email ?? '';
          return Drawer(
            width: MediaQuery.of(context).size.width * 0.68,
            backgroundColor: const Color(0xFFFAFAFA),
            child: SafeArea(
              child: Column(
                children: [
                  // Header: profile + app name
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C2C2C),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            backgroundImage: _getProfileImage(user?.profilePhoto),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            userName.isEmpty ? 'BusinessHub' : userName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (userEmail.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            'View profile',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF06C698),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      children: [
                        _drawerSectionLabel('Browse'),
                        _drawerTile(
                          icon: Icons.dashboard_rounded,
                          label: 'Dashboard',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/home');
                          },
                        ),
                        _drawerTile(
                          icon: Icons.explore_rounded,
                          label: 'Hubs',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/hub-list');
                          },
                        ),
                        const SizedBox(height: 8),
                        _drawerSectionLabel('My activity'),
                        _drawerTile(
                          icon: Icons.business_center_rounded,
                          label: 'My Hubs',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/my-hubs');
                          },
                        ),
                        _drawerTile(
                          icon: Icons.send_rounded,
                          label: 'My Applications',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/my-applications');
                          },
                        ),
                        _drawerTile(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Accepted hubs',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/accepted-hubs');
                          },
                        ),
                        _drawerTile(
                          icon: Icons.work_outline_rounded,
                          label: 'Active work',
                          badge: _activeWorkCount > 0 ? '$_activeWorkCount' : null,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/active-work-list').then((_) => _refreshCounts());
                          },
                        ),
                        _drawerTile(
                          icon: Icons.history_rounded,
                          label: 'Job history',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/job-history');
                          },
                        ),
                        const SizedBox(height: 8),
                        _drawerSectionLabel('Wallet'),
                        _drawerTile(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'App Pocket',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/app-pocket');
                          },
                        ),
                        const SizedBox(height: 8),
                        _drawerSectionLabel('App'),
                        _drawerTile(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                        const SizedBox(height: 8),
                        AdminNavigationMenu(),
                        const Divider(height: 24),
                        _drawerTile(
                          icon: Icons.logout_rounded,
                          label: 'Log out',
                          iconColor: Colors.red,
                          labelColor: Colors.red,
                          onTap: () async {
                            Navigator.pop(context);
                            await authProvider.logout();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshCounts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 28 : 20,
              vertical: isTablet ? 20 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
                _buildWelcomeBanner(context, isTablet),
                SizedBox(height: isTablet ? 28 : 20),
                // Action strip: Active work, App Pocket, Job history (notifications live in app bar only)
                _buildActionStrip(context, isTablet),
                SizedBox(height: isTablet ? 28 : 24),
                // Quick access grid (2x2)
                _buildSectionTitle('Quick access'),
                SizedBox(height: isTablet ? 16 : 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: isTablet ? 1.35 : 1.25,
                  children: [
                    _buildGridTile(
                      context: context,
                      title: 'Explore hubs',
                      icon: Icons.explore_outlined,
                      color: const Color(0xFF06C698),
                      onTap: () => Navigator.pushNamed(context, '/hub-list'),
                    ),
                    _buildGridTile(
                      context: context,
                      title: 'My Applications',
                      icon: Icons.send_outlined,
                      color: const Color(0xFFFF9800),
                      onTap: () => Navigator.pushNamed(context, '/my-applications'),
                    ),
                    _buildGridTile(
                      context: context,
                      title: 'My Hubs',
                      icon: Icons.business_center_outlined,
                      color: const Color(0xFF2196F3),
                      onTap: () => Navigator.pushNamed(context, '/my-hubs'),
                    ),
                    _buildGridTile(
                      context: context,
                      title: 'Accepted hubs',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF6C63FF),
                      onTap: () => Navigator.pushNamed(context, '/accepted-hubs'),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 28 : 24),
                // Nearby hubs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildSectionTitle('Nearby hubs'),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/hub-list'),
                      child: Text(
                        'See all',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF06C698),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                FutureBuilder<List<dynamic>>(
                  future: _nearbyHubsFuture ?? Future.value(<dynamic>[]),
                  builder: (context, snapshot) {
                    if (_nearbyHubsFuture == null || snapshot.connectionState == ConnectionState.waiting) {
                      return _buildHubListSkeleton(isTablet);
                    }
                    if (snapshot.hasError) {
                      return _buildEmptyHubCard('Unable to load hubs');
                    }
                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return _buildEmptyHubCard('No available hubs');
                    }
                    return SizedBox(
                      height: isTablet ? 172 : 164,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: list.length > 5 ? 5 : list.length,
                        separatorBuilder: (_, __) => SizedBox(width: isTablet ? 16 : 12),
                        itemBuilder: (context, index) => _buildHubCard(list[index], isTablet),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 88),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomNavItem(Icons.person_2_outlined, 'Profile', () => Navigator.pushNamed(context, '/profile'), false),
                _buildBottomNavItem(Icons.home_outlined, 'Home', () {}, true), // current screen
                _buildBottomNavItem(Icons.explore_outlined, 'Hubs', () => Navigator.pushNamed(context, '/hub-list'), false),
                _buildBottomNavItem(Icons.menu_rounded, 'Menu', () => scaffoldKey.currentState!.openDrawer(), false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _drawerTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? badge,
    Color? iconColor,
    Color? labelColor,
  }) {
    final color = iconColor ?? const Color(0xFF2C2C2C);
    final textColor = labelColor ?? const Color(0xFF1a1a1a);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 22, color: color),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF06C698),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, bool isTablet) {
    final name = context.watch<AuthProvider>().currentUser?.name ?? 'there';
    final welcomeName = name.isNotEmpty ? name : 'there';
    return Container(
      width: double.infinity,
      height: isTablet ? 200 : 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('images/splash.jpeg'),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.2),
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, $welcomeName',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isTablet ? 26 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Find nearby jobs and manage work in one place.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 14),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(context, '/hub-list'),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      child: Text(
                        'Explore hubs',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2C2C2C),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFF111111),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionStrip(BuildContext context, bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: _buildActionChip(
            icon: Icons.work_outline,
            label: 'Active work',
            count: _activeWorkCount,
            color: const Color(0xFF06C698),
            onTap: () => Navigator.pushNamed(context, '/active-work-list').then((_) => _refreshCounts()),
          ),
        ),
        SizedBox(width: isTablet ? 14 : 10),
        Expanded(
          child: _buildActionChip(
            icon: Icons.account_balance_wallet_outlined,
            label: 'App Pocket',
            count: null,
            color: const Color(0xFF6C63FF),
            onTap: () => Navigator.pushNamed(context, '/app-pocket'),
          ),
        ),
        SizedBox(width: isTablet ? 14 : 10),
        Expanded(
          child: _buildActionChip(
            icon: Icons.history_rounded,
            label: 'Job history',
            count: null,
            color: Colors.deepOrange,
            onTap: () => Navigator.pushNamed(context, '/job-history'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required int? count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 24),
                  if (count != null && count > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 34),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF111111),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHubListSkeleton(bool isTablet) {
    return SizedBox(
      height: isTablet ? 172 : 164,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: isTablet ? 16 : 12),
        itemBuilder: (_, __) => Container(
          width: isTablet ? 200 : 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHubCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildHubCard(Map<String, dynamic> item, bool isTablet) {
    final jobhub = item['jobhub'];
    final hubId = jobhub?.id as int?;
    final cardWidth = isTablet ? 220 : 188;
    return SizedBox(
      width: cardWidth.toDouble(),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: hubId != null
              ? () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => HubDetailPage(hubId: hubId),
                    ),
                  )
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06C698).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: const Color(0xFF06C698),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06C698).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Available',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF06C698),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item['title'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111111),
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'] as String,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: const Color(0xFF06C698)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item['distance'] as String,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF06C698),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item['payment'] as String,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF111111),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback onTap, bool highlight, {int badgeCount = 0}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: highlight ? const Color(0xFF06C698) : Colors.grey.shade600,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: highlight ? const Color(0xFF06C698) : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Load available jobhubs from API (sorted by distance, closest first)
  Future<List<dynamic>> _loadAvailableJobhubs() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      double? lat = user?.latitude;
      double? lng = user?.longitude;
      // Use device location when user has no stored location so distance and sort still work
      if (lat == null || lng == null) {
        final position = await LocationTrackingService.getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
        }
      }
      final availableJobhubs = await HubRepository.getAvailableJobhubsSortedByDistance(lat, lng);

      // Convert to the format expected by the UI; show distance when location available
      return availableJobhubs.map((jobhub) {
        String distanceText = 'Nearby';
        if (lat != null && lng != null) {
          final km = HubRepository.distanceKm(lat, lng, jobhub);
          distanceText = '${km.toStringAsFixed(1)} km away';
        }
        return {
          'title': jobhub.title,
          'category': jobhub.category,
          'payment': jobhub.formattedPaymentAmount,
          'distance': distanceText,
          'icon': _getCategoryIcon(jobhub.category),
          'status': 'Available',
          'jobhub': jobhub,
        };
      }).toList();
    } catch (e) {
      print('Error loading available jobhubs: $e');
      // Fallback to mock data if API fails
      return [
        {
          'title': 'House Cleaning',
          'category': 'Cleaning',
          'payment': 'R350',
          'distance': '1.2km away',
          'icon': Icons.cleaning_services,
          'status': 'Available',
        },
        {
          'title': 'Garden Maintenance',
          'category': 'Landscaping',
          'payment': 'R450',
          'distance': '0.8km away',
          'icon': Icons.eco,
          'status': 'Available',
        },
        {
          'title': 'Tutoring Services',
          'category': 'Education',
          'payment': 'R200',
          'distance': '2.1km away',
          'icon': Icons.school,
          'status': 'Available',
        },
      ];
    }
  }

  // Helper method to get icon based on category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'landscaping':
      case 'garden':
        return Icons.eco;
      case 'education':
      case 'tutoring':
        return Icons.school;
      case 'construction':
        return Icons.construction;
      case 'maintenance':
        return Icons.build;
      case 'delivery':
        return Icons.delivery_dining;
      case 'technology':
        return Icons.computer;
      default:
        return Icons.work;
    }
  }

  ImageProvider _getProfileImage(String? profilePhoto) {
    if (profilePhoto == null || profilePhoto.isEmpty) {
      return const AssetImage('images/logo.png');
    }
    try {
      if (profilePhoto.startsWith('data:image/')) {
        final parts = profilePhoto.split(',');
        if (parts.length != 2) return const AssetImage('images/logo.png');
        String base64Data = parts[1].trim().replaceAll(RegExp(r'\s+'), '');
        while (base64Data.length % 4 != 0) base64Data += '=';
        if (!RegExp(r'^[A-Za-z0-9+/]*={0,2}$').hasMatch(base64Data)) {
          return const AssetImage('images/logo.png');
        }
        try {
          final bytes = base64Decode(base64Data);
          return bytes.isEmpty ? const AssetImage('images/logo.png') : MemoryImage(bytes);
        } catch (_) {
          return const AssetImage('images/logo.png');
        }
      }
      return NetworkImage(profilePhoto);
    } catch (_) {
      return const AssetImage('images/logo.png');
    }
  }
}
