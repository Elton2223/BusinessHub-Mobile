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
              // Filter Section
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 2,
                      color: Color(0x0A000000),
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Filter by Category',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final isSelected = selectedFilter == index + 1;
                          
                          return Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedFilter = index + 1;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(0xFF667eea) : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    color: isSelected ? Colors.white : Color(0xFF111111),
                                    fontSize: 14,
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
              
              SizedBox(height: 20),
              
              // Hub Listings
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return _buildHubCard(index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new hub functionality
        },
        backgroundColor: Color(0xFF667eea),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add New Hub',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHubCard(int index) {
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0)),
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
          // Hub Image
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: DecorationImage(
                image: AssetImage(hub['image']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF667eea),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hub['category']!,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
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
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hub['title']!,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF111111),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color(0xFF667eea),
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        hub['location']!,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        hub['price']!,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF111111),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
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
                        padding: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
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
