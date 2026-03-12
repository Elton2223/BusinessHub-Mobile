import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../model/jobhub_model.dart';
import '../services/hub_repository.dart';
import 'hub_detail_page.dart';

class HubApplyPage extends StatefulWidget {
  const HubApplyPage({super.key});

  static String routeName = 'HubApplyPage';
  static String routePath = '/hub-apply';

  @override
  State<HubApplyPage> createState() => _HubApplyPageState();
}

class _HubApplyPageState extends State<HubApplyPage> {
  int selectedFilter = 0; // 0 = All
  List<JobhubModel> _hubs = [];
  bool _loading = true;
  String? _error;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHubs());
  }

  Future<void> _loadHubs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await HubRepository.getAvailableJobhubs();
      if (mounted) {
        setState(() {
          _hubs = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  List<JobhubModel> get _filteredHubs {
    if (selectedFilter == 0) return _hubs;
    final cat = categories[selectedFilter];
    return _hubs.where((h) => h.category == cat).toList();
  }

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
                          final isSelected = selectedFilter == index;
                          
                          return Padding(
                            padding: EdgeInsets.only(right: isTablet ? 16 : 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedFilter = index;
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                                SizedBox(height: 16),
                                ElevatedButton(onPressed: _loadHubs, child: Text('Retry')),
                              ],
                            ),
                          )
                        : _filteredHubs.isEmpty
                            ? Center(
                                child: Text(
                                  'No hubs match the selected category.',
                                  style: GoogleFonts.poppins(color: Colors.grey),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: getCrossAxisCount(),
                                  crossAxisSpacing: isTablet ? 20 : 16,
                                  mainAxisSpacing: isTablet ? 20 : 16,
                                  childAspectRatio: getAspectRatio(),
                                ),
                                itemCount: _filteredHubs.length,
                                itemBuilder: (context, index) {
                                  return _buildHubCard(_filteredHubs[index], isTablet, isLaptop);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/hub-list'),
        backgroundColor: Color(0xFF667eea),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHubCard(JobhubModel hub, bool isTablet, bool isLaptop) {
    return InkWell(
      onTap: () {
        if (hub.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => HubDetailPage(hubId: hub.id!),
            ),
          ).then((_) => _loadHubs());
        }
      },
      child: Container(
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
          // Hub Image / Icon
          Container(
            height: isLaptop ? 160 : (isTablet ? 140 : 120),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isTablet ? 16 : 12),
                topRight: Radius.circular(isTablet ? 16 : 12),
              ),
              color: Color(0xFF667eea).withOpacity(0.15),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    hub.categoryIcon,
                    style: TextStyle(fontSize: isTablet ? 48 : 40),
                  ),
                ),
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
                      hub.category,
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
                    hub.title,
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
                          hub.city,
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
                        hub.formattedPaymentAmount,
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
                        if (hub.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => HubDetailPage(hubId: hub.id!),
                            ),
                          ).then((_) => _loadHubs());
                        }
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
    ),
    );
  }
}
