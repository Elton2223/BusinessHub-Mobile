import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'widgets/neumorphic_widgets.dart';
import 'flutter_flow/neumorphic_theme.dart';
import 'widgets/admin_navigation_menu.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'utils/responsive_utils.dart';
import 'utils/responsive_theme.dart';
import 'services/jobhub_service.dart';
import 'model/jobhub_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'HomePage';
  static String routePath = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ResponsiveWidgetMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: NeumorphicTheme.baseColor,
      drawer: NeumorphicDrawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryColor,
              ),
              child: Text(
                'BusinessHub',
                style: FlutterFlowTheme.of(context).title1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            NeumorphicListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            NeumorphicListTile(
              leading: Icon(Icons.business),
              title: Text('Hubs'),
              onTap: () => Navigator.pop(context),
            ),
            NeumorphicListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => Navigator.pop(context),
            ),
            // Admin Navigation Menu (only shows for admin users)
            AdminNavigationMenu(),
          ],
        ),
      ),
      body: SafeArea(
         child: Column(
           children: [
                           // Mobile App Bar
              if (responsive.isPhone)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF989898),
                        offset: const Offset(4, 4),
                        blurRadius: 8,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFFFFF),
                        offset: const Offset(-4, -4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF989898),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFFFFF),
                              offset: const Offset(-2, -2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () => scaffoldKey.currentState!.openDrawer(),
                        ),
                      ),
                      Text(
                        'BusinessHub',
                        style: FlutterFlowTheme.of(context).title1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF989898),
                              offset: const Offset(2, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFFFFF),
                              offset: const Offset(-2, -2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.notifications),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
             // Main Content
             Expanded(
               child: Padding(
                 padding: EdgeInsets.all(16),
                 child: SingleChildScrollView(
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
                       height: 200,
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
                               Text(
                                 'Welcome Khethani',
                                 style: GoogleFonts.readexPro(
                                   color: Colors.white,
                                   fontSize: 28,
                                   fontWeight: FontWeight.bold,
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
                     
                     SizedBox(height: 25),
                     // Available Jobhubs Section
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
                           onTap: () => Navigator.pushNamed(context, '/hub-list'),
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
                     // Available Jobhubs Cards
                     FutureBuilder<List<dynamic>>(
                       future: _loadAvailableJobhubs(),
                       builder: (context, snapshot) {
                         if (snapshot.connectionState == ConnectionState.waiting) {
                           return const Center(
                             child: Padding(
                               padding: EdgeInsets.all(20),
                               child: CircularProgressIndicator(),
                             ),
                           );
                         }
                         
                         if (snapshot.hasError) {
                           return Center(
                             child: Padding(
                               padding: const EdgeInsets.all(20),
                               child: Text(
                                 'Error loading available jobhubs',
                                 style: TextStyle(color: Colors.red),
                               ),
                             ),
                           );
                         }
                         
                         final availableJobhubs = snapshot.data ?? [];
                         
                         if (availableJobhubs.isEmpty) {
                           return Center(
                             child: Padding(
                               padding: const EdgeInsets.all(20),
                               child: Text(
                                 'No available jobhubs',
                                 style: TextStyle(color: Colors.grey),
                               ),
                             ),
                           );
                         }
                         
                         return SingleChildScrollView(
                           scrollDirection: Axis.horizontal,
                           child: Row(
                             children: availableJobhubs.take(3).map((jobhub) => 
                               _buildAvailableJobhubCard(jobhub)
                             ).toList(),
                           ),
                         );
                       },
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
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF989898),
                              offset: const Offset(6, 6),
                              blurRadius: 12,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFFFFF),
                              offset: const Offset(-6, -6),
                              blurRadius: 12,
                            ),
                          ],
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
            color: const Color(0xFF989898),
            offset: const Offset(6, 6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: const Color(0xFFFFFFFF),
            offset: const Offset(-6, -6),
            blurRadius: 12,
          ),
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
              color: const Color(0xFF989898),
              offset: const Offset(8, 8),
              blurRadius: 16,
            ),
            BoxShadow(
              color: const Color(0xFFFFFFFF),
              offset: const Offset(-8, -8),
              blurRadius: 16,
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

  // Load available jobhubs from API
  Future<List<dynamic>> _loadAvailableJobhubs() async {
    try {
      // Get available jobhubs from API (status = 1)
      final availableJobhubs = await JobhubService.getAvailableJobhubs();
      
      // Convert to the format expected by the UI
      return availableJobhubs.map((jobhub) => {
        'title': jobhub.title,
        'category': jobhub.category,
        'payment': jobhub.formattedPaymentAmount,
        'distance': 'Nearby',
        'icon': _getCategoryIcon(jobhub.category),
        'status': 'Available',
        'jobhub': jobhub, // Keep reference to original model
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

  // Build available jobhub card
  Widget _buildAvailableJobhubCard(Map<String, dynamic> jobhub) {
    return Container(
      width: 200,
      height: 140,
      margin: EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF06C698), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF989898),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFFFFFFF),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFF06C698),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    jobhub['icon'] as IconData,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    jobhub['status'] as String,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF06C698),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              jobhub['title'] as String,
              maxLines: 2,
              style: GoogleFonts.poppins(
                color: Color(0xFF111111),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              jobhub['category'] as String,
              style: GoogleFonts.poppins(
                color: Color(0xFF666666),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  jobhub['distance'] as String,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF06C698),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  jobhub['payment'] as String,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
