import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String userName = 'User'; // Default fallback
  Timer? _autoRefreshTimer;
  bool _isRefreshing = false; // Prevent multiple simultaneous refreshes

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Auto refresh every 30 seconds to keep user data updated
    // This ensures the welcome message and user information stay current
    // without overwhelming the system with too frequent API calls
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> _loadUserData() async {
    // Prevent multiple simultaneous refreshes
    if (_isRefreshing) return;
    
    try {
      _isRefreshing = true;
      
      // Only show loading on initial load, not during auto-refresh
      if (userData == null) {
        setState(() {
          isLoading = true;
        });
      }

      // Get user data from stored preferences
      final storedUserData = await AuthService.getUserData();
      
      if (storedUserData != null) {
        // Only update state if data has actually changed
        if (userData == null || 
            userData!['name'] != storedUserData['name'] ||
            userData!['email'] != storedUserData['email']) {
          setState(() {
            userData = storedUserData;
            userName = '${storedUserData['name'] ?? 'User'}';
            isLoading = false;
          });
          
          // Only print on initial load to avoid console spam
          if (userData == null) {
            print('Loaded user data: $userData');
            print('User name: $userName');
          }
        }
      } else {
        // If no stored data, try to get current user from API
        final currentUser = await AuthService.getCurrentUser();
        if (currentUser != null) {
          // Only update state if data has actually changed
          if (userData == null || 
              userData!['name'] != currentUser['name'] ||
              userData!['email'] != currentUser['email']) {
            setState(() {
              userData = currentUser;
              userName = '${currentUser['name'] ?? 'User'}';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            isLoading = false;
            userName = 'User';
          });
        }
      }
    } on ApiException catch (e) {
      // Handle API-specific errors
      print('API error loading user data: ${e.message}');
      if (userData == null) {
        // Only show error on initial load
        print('Initial load failed: ${e.message}');
      }
      setState(() {
        isLoading = false;
        userName = 'User';
      });
    } catch (e) {
      // Handle other errors
      print('Unexpected error loading user data: $e');
      if (userData == null) {
        print('Initial load failed with unexpected error: $e');
      }
      setState(() {
        isLoading = false;
        userName = 'User';
      });
    } finally {
      _isRefreshing = false;
    }
  }

  String _getUserGreeting() {
    if (userData != null) {
      final name = userData!['name'] ?? 'User';
      final surname = userData!['surname'] ?? '';
      final fullName = '${name}${surname.isNotEmpty ? ' $surname' : ''}';
      
      // Smart truncation for long names
      if (fullName.length > 25) {
        // For very long names, show only first name
        return 'Welcome $name';
      } else if (fullName.length > 20) {
        // For moderately long names, truncate with ellipsis
        return 'Welcome ${fullName.substring(0, 17)}...';
      }
      return 'Welcome $fullName';
    }
    return 'Welcome User';
  }

  double _getResponsiveFontSize(BuildContext context, String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textLength = text.length;
    
    // Adjust font size based on text length and screen width
    if (textLength > 25) {
      return screenWidth < 400 ? 20.0 : 24.0;
    } else if (textLength > 20) {
      return screenWidth < 400 ? 22.0 : 26.0;
    } else {
      return screenWidth < 400 ? 24.0 : 28.0;
    }
  }

  String _formatNameForDisplay(String? name, String? surname) {
    if (name == null || name.isEmpty) return 'User';
    
    final fullName = surname != null && surname.isNotEmpty 
        ? '$name $surname' 
        : name;
    
    // For very long names, show only first name
    if (fullName.length > 25) {
      return name;
    }
    
    return fullName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      drawer: Drawer(
        child: Container(
          color: FlutterFlowTheme.of(context).primaryBackground,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BusinessHub',
                      style: FlutterFlowTheme.of(context).title1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (userData != null) ...[
                      Flexible(
                        child: Text(
                          'Welcome, ${userData!['name'] ?? 'User'}',
                          style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(height: 5),
                      Flexible(
                        child: Text(
                          userData!['email'] ?? '',
                          style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ] else
                      Flexible(
                        child: Text(
                          'Welcome, User',
                          style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Dashboard'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.business),
                title: Text('Hubs'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () => Navigator.pop(context),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  Navigator.pop(context);
                  await AuthService.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
         child: Column(
           children: [
             // Mobile App Bar
             if (MediaQuery.of(context).size.width < 768)
               Container(
                 padding: EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: FlutterFlowTheme.of(context).primaryBackground,
                   boxShadow: [
                     BoxShadow(
                       blurRadius: 3,
                       color: Color(0x33000000),
                       offset: Offset(0, 1),
                     ),
                   ],
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     IconButton(
                       icon: Icon(Icons.menu),
                       onPressed: () => scaffoldKey.currentState!.openDrawer(),
                     ),
                     Text(
                       'BusinessHub',
                       style: FlutterFlowTheme.of(context).title1.copyWith(
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                     Row(
                       children: [
                          // Auto-refresh indicator
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _isRefreshing ? Color(0xFFFF9800) : Color(0xFF06C698),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          // Connection status indicator
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: userData != null ? Color(0xFF4CAF50) : Color(0xFFFF5722),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.notifications),
                            onPressed: () {},
                          ),
                        ],
                      ),
                   ],
                 ),
               ),
             // Main Content
             Expanded(
               child: SingleChildScrollView(
                 padding: EdgeInsets.all(16),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Desktop App Bar
                     if (MediaQuery.of(context).size.width >= 768)
                       Padding(
                         padding: EdgeInsets.only(bottom: 25),
                         child: Container(
                           padding: EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: FlutterFlowTheme.of(context).primaryBackground,
                             borderRadius: BorderRadius.circular(8),
                             boxShadow: [
                               BoxShadow(
                                 blurRadius: 3,
                                 color: Color(0x33000000),
                                 offset: Offset(0, 1),
                               ),
                             ],
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 'Dashboard Activity',
                                 style: FlutterFlowTheme.of(context).title1.copyWith(
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               Row(
                                 children: [
                                   IconButton(
                                     icon: Icon(Icons.notifications),
                                     onPressed: () {},
                                   ),
                                   IconButton(
                                     icon: Icon(Icons.person),
                                     onPressed: () {},
                                   ),
                                 ],
                               ),
                             ],
                           ),
                         ),
                       ),
                     // Welcome Banner
                     Container(
                       width: double.infinity,
                       constraints: BoxConstraints(
                         minHeight: 200,
                         maxHeight: 250,
                       ),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(25),
                         image: DecorationImage(
                           fit: BoxFit.cover,
                           image: AssetImage('images/splash.jpeg'),
                         ),
                       ),
                       child: Container(
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(25),
                           gradient: LinearGradient(
                             begin: Alignment.topLeft,
                             end: Alignment.bottomRight,
                             colors: [
                               Colors.black.withOpacity(0.3),
                               Colors.transparent,
                             ],
                           ),
                         ),
                         child: Padding(
                           padding: EdgeInsets.all(20),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                                if (isLoading)
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Loading...',
                                          style: GoogleFonts.readexPro(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Flexible(
                                    child: Text(
                                      _getUserGreeting(),
                                      style: GoogleFonts.readexPro(
                                        color: Colors.white,
                                        fontSize: _getResponsiveFontSize(context, _getUserGreeting()),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                               SizedBox(height: 8),
                               Text(
                                 'Enjoy using BusinessHub to find\nany nearby jobs at your area',
                                 style: GoogleFonts.readexPro(
                                   color: Colors.white.withOpacity(0.9),
                                   fontSize: 14,
                                   fontWeight: FontWeight.w300,
                                 ),
                               ),
                               SizedBox(height: 16),
                                                               InkWell(
                                  onTap: () => Navigator.pushNamed(context, '/hub-list'),
                                 child: Container(
                                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   decoration: BoxDecoration(
                                     color: Color(0xFF111111),
                                     borderRadius: BorderRadius.circular(30),
                                     border: Border.all(color: Color(0x66E6E6E6)),
                                   ),
                                   child: Text(
                                     'View Hub',
                                     style: GoogleFonts.readexPro(
                                       color: Colors.white,
                                       fontSize: 12,
                                       fontWeight: FontWeight.w500,
                                     ),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                     ),
                     SizedBox(height: 25),
                     // Active Hubs Section
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           'Active Hubs',
                           style: GoogleFonts.poppins(
                             color: Color(0xFF111111),
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         InkWell(
                           onTap: () => Navigator.pushNamed(context, '/hub-apply'),
                           child: Text(
                             'See more',
                             style: GoogleFonts.poppins(
                               color: Color(0xFF667eea),
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ),
                       ],
                     ),
                     SizedBox(height: 15),
                     // Hub Cards
                     SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: Row(
                                                  children: [
                            _buildHubCard('Cleaning Service', '2m away', 'R500', Icons.cleaning_services),
                            SizedBox(width: 15),
                            _buildHubCard('Maintaining pavement', '2m away', 'R5k', Icons.construction),
                            SizedBox(width: 15),
                            _buildHubCard('Mathematics tutor', '2m away', 'R380', Icons.school),
                          ],
                       ),
                     ),
                     SizedBox(height: 25),
                     Divider(),
                     SizedBox(height: 15),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           'What\'s In The Hub',
                           style: GoogleFonts.poppins(
                             color: Color(0xFF111111),
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                         InkWell(
                           onTap: () => Navigator.pushNamed(context, '/hub-apply'),
                           child: Text(
                             'See more',
                             style: GoogleFonts.poppins(
                               color: Color(0xFF667eea),
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                             ),
                           ),
                         ),
                       ],
                     ),
                     SizedBox(height: 15),
                     // Hub Information Cards - New Design
                     Row(
                       children: [
                         Expanded(
                           child: _buildHubInfoCard(
                             'Review Requests',
                             'Review Requests You Made To Other Hubs',
                             'View',
                             Color(0xFFFF9800), // Orange border
                             true, // Left border
                           ),
                         ),
                         SizedBox(width: 15),
                         Expanded(
                           child: _buildHubInfoCard(
                             'Review Requests',
                             'Review Requests You Made To Other Hubs',
                             'View',
                             Color(0xFF87CEEB), // Light blue border
                             false, // Right border
                           ),
                         ),
                       ],
                     ),
                     SizedBox(height: 25),
                     // Quick Stats
                     Container(
                       padding: EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         color: FlutterFlowTheme.of(context).primaryBackground,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Color(0xFFE0E0E0)),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             'Quick Stats',
                             style: GoogleFonts.poppins(
                               color: Color(0xFF111111),
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           SizedBox(height: 12),
                           Row(
                             children: [
                               Expanded(
                                 child: _buildStatItem('Today\'s Jobs', '12', Icons.today),
                               ),
                               Expanded(
                                 child: _buildStatItem('This Week', '89', Icons.calendar_view_week),
                               ),
                               Expanded(
                                 child: _buildStatItem('This Month', '342', Icons.calendar_month),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                     SizedBox(height: 80), // Add bottom padding for bottom navigation
                   ],
                 ),
               ),
             ),
             // Fixed Bottom Navigation Bar
             Container(
               decoration: BoxDecoration(
                 color: FlutterFlowTheme.of(context).primaryBackground,
                 boxShadow: [
                   BoxShadow(
                     blurRadius: 8,
                     color: Color(0x1A000000),
                     offset: Offset(0, -2),
                   ),
                 ],
               ),
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                     _buildBottomNavItem(
                       icon: Icons.person_2,
                       label: 'Profile',
                       onTap: () => Navigator.pushNamed(context, '/profile'),
                     ),
                     _buildBottomNavItem(
                       icon: Icons.notifications_active,
                       label: 'Notifications',
                       onTap: () => Navigator.pushNamed(context, '/notifications'),
                     ),
                     _buildBottomNavItem(
                       icon: Icons.menu_open_outlined,
                       label: 'Hubs',
                       onTap: () => Navigator.pushNamed(context, '/hubs'),
                     ),
                   ],
                 ),
               ),
             ),
           ],
         ),
       ),
    );
  }

  Widget _buildHubCard(String title, String distance, String price, IconData icon) {
    return Container(
      width: 170,
      height: 99,
      decoration: BoxDecoration(
                                 color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: Color(0x0D000000),
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF828080),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        distance,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF111111),
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFF06C698),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        price,
                        style: GoogleFonts.readexPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF111111),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHubInfoCard(String title, String subtitle, String buttonText, Color borderColor, bool isLeftBorder) {
    return InkWell(
      onTap: () {
        // Navigate to review requests page
        Navigator.pushNamed(context, '/review-requests');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Color(0x0A000000),
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
        children: [
          // Colored border overlay
          Positioned(
            left: isLeftBorder ? 0 : null,
            right: isLeftBorder ? null : 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.only(
                  topLeft: isLeftBorder ? Radius.circular(12) : Radius.zero,
                  bottomLeft: isLeftBorder ? Radius.circular(12) : Radius.zero,
                  topRight: isLeftBorder ? Radius.zero : Radius.circular(12),
                  bottomRight: isLeftBorder ? Radius.zero : Radius.circular(12),
                ),
              ),
            ),
                    ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top image section
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  image: DecorationImage(
                    image: AssetImage('images/splash.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Content section
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 16),
                    // View button
                    InkWell(
                      onTap: () {
                        // Navigate to review requests page
                        Navigator.pushNamed(context, '/review-requests');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Color(0xFFE0E0E0)),
                        ),
                        child: Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF111111),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            color: Color(0x0A000000),
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF111111),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: FlutterFlowTheme.of(context).primaryColor,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Color(0xFF111111),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Color(0xFF666666),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
