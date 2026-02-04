import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class HubApplyPage extends StatefulWidget {
  const HubApplyPage({super.key});

  static String routeName = 'HubApplyPage';
  static String routePath = '/hub-apply';

  @override
  State<HubApplyPage> createState() => _HubApplyPageState();
}

class _HubApplyPageState extends State<HubApplyPage> {
  int selectedFilter = 1;

  final List<String> categories = [
    'All',
    'Services',
    'Technology',
    'Education',
    'Construction',
    'Creative',
    'Healthcare',
    'Finance'
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLaptop = screenWidth > 900;
    final isDesktop = screenWidth > 1200;
    
    // Responsive grid columns
    int getCrossAxisCount() {
      if (isDesktop) return 4;
      if (isLaptop) return 3;
      if (isTablet) return 2;
      return 1;
    }
    
    // Responsive aspect ratio
    double getAspectRatio() {
      if (isDesktop) return 0.85;
      if (isLaptop) return 0.8;
      if (isTablet) return 0.75;
      return 0.7;
    }
    
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Available Hubs',
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
              // Filter Section
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Color(0x0A000000),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Filter by Category',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final isSelected = selectedFilter == index + 1;
                          
                          return Padding(
                            padding: EdgeInsets.only(right: isTablet ? 16 : 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedFilter = index + 1;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 20 : 16,
                                  vertical: isTablet ? 10 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(0xFF667eea) : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(isTablet ? 25 : 20),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : Color(0xFF111111),
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: isTablet ? 24 : 20),
              
              // Hub Listings
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: getCrossAxisCount(),
                    crossAxisSpacing: isTablet ? 20 : 16,
                    mainAxisSpacing: isTablet ? 20 : 16,
                    childAspectRatio: getAspectRatio(),
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return _buildHubCard(index, isTablet, isLaptop);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isTablet 
        ? FloatingActionButton.extended(
            onPressed: () {
              // Add new hub functionality
            },
            backgroundColor: Color(0xFF667eea),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Add New Hub',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : FloatingActionButton(
            onPressed: () {
              // Add new hub functionality
            },
            backgroundColor: Color(0xFF667eea),
            child: Icon(Icons.add, color: Colors.white),
          ),
    );
  }

  Widget _buildHubCard(int index, bool isTablet, bool isLaptop) {
    final hubData = [
      {
        'title': 'Web Development',
        'category': 'Technology',
        'price': 'R2,500',
        'location': 'Johannesburg',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Cleaning Services',
        'category': 'Services',
        'price': 'R800',
        'location': 'Cape Town',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Math Tutoring',
        'category': 'Education',
        'price': 'R300',
        'location': 'Pretoria',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Graphic Design',
        'category': 'Creative',
        'price': 'R1,200',
        'location': 'Durban',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Plumbing Work',
        'category': 'Construction',
        'price': 'R1,500',
        'location': 'Johannesburg',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Financial Consulting',
        'category': 'Finance',
        'price': 'R3,000',
        'location': 'Cape Town',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Mobile App Development',
        'category': 'Technology',
        'price': 'R4,500',
        'location': 'Pretoria',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Photography',
        'category': 'Creative',
        'price': 'R1,800',
        'location': 'Durban',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Medical Consultation',
        'category': 'Healthcare',
        'price': 'R2,200',
        'location': 'Johannesburg',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Electrical Work',
        'category': 'Construction',
        'price': 'R2,000',
        'location': 'Cape Town',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Language Teaching',
        'category': 'Education',
        'price': 'R400',
        'location': 'Pretoria',
        'image': 'images/splash.jpeg',
      },
      {
        'title': 'Marketing Strategy',
        'category': 'Services',
        'price': 'R2,800',
        'location': 'Durban',
        'image': 'images/splash.jpeg',
      },
    ];

    final hub = hubData[index % hubData.length];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(color: Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            blurRadius: isTablet ? 6 : 4,
            color: Color(0x0A000000),
            offset: Offset(0, isTablet ? 3 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hub Image
          Container(
            height: isLaptop ? 160 : (isTablet ? 140 : 120),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTablet ? 16 : 12),
                topRight: Radius.circular(isTablet ? 16 : 12),
              ),
              image: DecorationImage(
                image: AssetImage(hub['image']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: isTablet ? 10 : 8,
                  right: isTablet ? 10 : 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 8,
                      vertical: isTablet ? 5 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF667eea),
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
                    ),
                    child: Text(
                      hub['category']!,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Hub Details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hub['title']!,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF111111),
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: isTablet ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isTablet ? 6 : 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF667eea),
                        size: isTablet ? 16 : 14,
                      ),
                      SizedBox(width: isTablet ? 6 : 4),
                      Expanded(
                        child: Text(
                          hub['location']!,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF666666),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price',
                        style: GoogleFonts.poppins(
                          color: Color(0xFF666666),
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        hub['price']!,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF111111),
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 10 : 8),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply for hub functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
