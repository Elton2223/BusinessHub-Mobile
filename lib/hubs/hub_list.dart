import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class HubListPage extends StatefulWidget {
  const HubListPage({super.key});

  static String routeName = 'HubListPage';
  static String routePath = '/hub-list';

  @override
  State<HubListPage> createState() => _HubListPageState();
}

class _HubListPageState extends State<HubListPage> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF2C2C2C),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Hubs',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Buttons
              Row(
                children: [
                  _buildFilterButton('All', '123', true, isTablet),
                  SizedBox(width: isTablet ? 16 : 12),
                  _buildFilterButton('Your Area', '12', false, isTablet),
                ],
              ),
              SizedBox(height: isTablet ? 32 : 24),
              
              // Ongoing Task Section
              Text(
                'Ongoing Task',
                style: GoogleFonts.poppins(
                  color: Color(0xFF111111),
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              _buildOngoingTaskCard(isTablet),
              SizedBox(height: isTablet ? 32 : 24),
              
              // Job Listings
              Expanded(
                child: isTablet && isLandscape
                    ? _buildTabletLayout()
                    : _buildMobileLayout(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      children: [
        _buildJobCard(
          title: 'Tutoring math',
          location: 'Market 42, st. Sraties, Lost Faramos',
          address: '2464 Royal Ln. Mesa, New Jersey',
          price: '\$51',
          image: 'images/splash.jpeg',
          buttonText: 'Task Completed',
          buttonColor: Color(0xFF2C2C2C),
          buttonIcon: Icons.arrow_forward,
          status: 'completed',
          isTablet: false,
        ),
        SizedBox(height: 16),
        _buildJobCard(
          title: 'Moving Help Needed',
          location: 'Market 42, st. Sraties, Lost Faramos',
          address: '',
          price: 'R1 500.00',
          image: 'images/splash.jpeg',
          buttonText: 'Accept',
          buttonColor: Color(0xFF06C698),
          buttonIcon: Icons.access_time,
          status: 'available',
          isTablet: false,
        ),
        SizedBox(height: 16),
        _buildJobCard(
          title: 'Moving Help Needed',
          location: 'Market 42, st. Sraties, Lost Faramos',
          address: '',
          price: 'R1 500.00',
          image: 'images/splash.jpeg',
          buttonText: 'View Task',
          buttonColor: Color(0xFFFF9800),
          buttonIcon: Icons.work,
          status: 'viewable',
          isTablet: false,
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final jobs = [
          {
            'title': 'Tutoring math',
            'location': 'Market 42, st. Sraties, Lost Faramos',
            'address': '2464 Royal Ln. Mesa, New Jersey',
            'price': '\$51',
            'buttonText': 'Task Completed',
            'buttonColor': Color(0xFF2C2C2C),
            'buttonIcon': Icons.arrow_forward,
            'status': 'completed',
          },
          {
            'title': 'Moving Help Needed',
            'location': 'Market 42, st. Sraties, Lost Faramos',
            'address': '',
            'price': 'R1 500.00',
            'buttonText': 'Accept',
            'buttonColor': Color(0xFF06C698),
            'buttonIcon': Icons.access_time,
            'status': 'available',
          },
          {
            'title': 'Moving Help Needed',
            'location': 'Market 42, st. Sraties, Lost Faramos',
            'address': '',
            'price': 'R1 500.00',
            'buttonText': 'View Task',
            'buttonColor': Color(0xFFFF9800),
            'buttonIcon': Icons.work,
            'status': 'viewable',
          },
        ];

        final job = jobs[index];
        return _buildJobCard(
          title: job['title'] as String,
          location: job['location'] as String,
          address: job['address'] as String,
          price: job['price'] as String,
          image: 'images/splash.jpeg',
          buttonText: job['buttonText'] as String,
          buttonColor: job['buttonColor'] as Color,
          buttonIcon: job['buttonIcon'] as IconData,
          status: job['status'] as String,
          isTablet: true,
        );
      },
    );
  }

  Widget _buildFilterButton(String text, String count, bool isSelected, bool isTablet) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
          border: Border.all(
            color: isSelected ? Color(0xFF2C2C2C) : Color(0xFFE0E0E0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Color(0xFF666666),
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: isTablet ? 10 : 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 8 : 6,
                vertical: isTablet ? 4 : 2,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
              ),
              child: Text(
                count,
                style: GoogleFonts.poppins(
                  color: isSelected ? Color(0xFF2C2C2C) : Colors.white,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingTaskCard(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tutoring math',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF111111),
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  'June 1, 2020, 08:22 AM',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF666666),
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF666666),
            size: isTablet ? 28 : 24,
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required String location,
    required String address,
    required String price,
    required String image,
    required String buttonText,
    required Color buttonColor,
    required IconData buttonIcon,
    required String status,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: status == 'available' 
              ? Color(0xFF06C698) 
              : status == 'viewable' 
                  ? Color(0xFFFF9800) 
                  : Color(0xFFE0E0E0),
          width: status == 'completed' ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x0A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Job Image
              Container(
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF111111),
                          size: isTablet ? 18 : 16,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.poppins(
                              color: Color(0xFF666666),
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (address.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 4 : 2),
                      Text(
                        address,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF666666),
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          // Action Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  buttonIcon,
                  color: Colors.white,
                  size: isTablet ? 20 : 18,
                ),
                SizedBox(width: isTablet ? 10 : 8),
                Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
