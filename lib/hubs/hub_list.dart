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
          'Jobs Available',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Buttons
              Row(
                children: [
                  _buildFilterButton('All', '123', true),
                  SizedBox(width: 12),
                  _buildFilterButton('Your Area', '12', false),
                ],
              ),
              SizedBox(height: 24),
              
              // Ongoing Task Section
              Text(
                'Ongoing Task',
                style: GoogleFonts.poppins(
                  color: Color(0xFF111111),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              _buildOngoingTaskCard(),
              SizedBox(height: 24),
              
              // Job Listings
              Expanded(
                child: ListView(
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, String count, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2C2C2C) : Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Color(0xFFFF9800),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: GoogleFonts.poppins(
                  color: isSelected ? Color(0xFF2C2C2C) : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingTaskCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'June 1, 2020, 08:22 AM',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF666666),
            size: 24,
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
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              // Job Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF111111),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: GoogleFonts.poppins(
                              color: Color(0xFF666666),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (address.isNotEmpty) ...[
                      SizedBox(height: 2),
                      Text(
                        address,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    SizedBox(height: 4),
                    Text(
                      price,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Action Button
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  buttonIcon,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
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
