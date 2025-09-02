import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../model/jobhub_model.dart';
import '../services/jobhub_service.dart';
import 'dart:async';

class HubListPage extends StatefulWidget {
  const HubListPage({super.key});

  static String routeName = 'HubListPage';
  static String routePath = '/hub-list';

  @override
  State<HubListPage> createState() => _HubListPageState();
}

class _HubListPageState extends State<HubListPage> {
  String selectedFilter = 'All';
  List<JobhubModel> allHubs = [];
  List<JobhubModel> filteredHubs = [];
  bool isLoading = true;
  String? errorMessage;
  bool _isAutoRefreshEnabled = true;
  Timer? _autoRefreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadHubs();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && _isAutoRefreshEnabled && !_isRefreshing) {
        _safeAutoRefresh();
      }
    });
  }

  void _safeAutoRefresh() async {
    try {
      if (_isRefreshing) return;
      
      setState(() {
        _isRefreshing = true;
      });
      
      await _loadHubs(silent: true);
    } catch (e) {
      // Handle auto-refresh errors silently to avoid spam
      print('Auto-refresh error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _loadHubs({bool silent = false}) async {
    if (_isRefreshing && !silent) return;
    
    try {
      if (!silent) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      final hubs = await JobhubService.getAllJobhubs();
      
      if (mounted) {
        setState(() {
          allHubs = hubs;
          filteredHubs = hubs;
          if (!silent) {
            isLoading = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (!silent) {
            isLoading = false;
            errorMessage = e.toString();
          }
        });
      }
    }
  }

  void _filterHubs(String filter) {
    setState(() {
      selectedFilter = filter;
      switch (filter) {
        case 'All':
          filteredHubs = allHubs;
          break;
        case 'Your Area':
          // Filter by location - you can customize this logic
          filteredHubs = allHubs.where((hub) => 
            hub.city.isNotEmpty || hub.state.isNotEmpty
          ).toList();
          break;
        default:
          filteredHubs = allHubs;
      }
    });
  }

  int get _allHubsCount => allHubs.length;
  int get _areaHubsCount => allHubs.where((hub) => 
    hub.city.isNotEmpty || hub.state.isNotEmpty
  ).length;

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
                  _buildFilterButton('All', _allHubsCount.toString(), selectedFilter == 'All', isTablet),
                  SizedBox(width: isTablet ? 16 : 12),
                  _buildFilterButton('Your Area', _areaHubsCount.toString(), selectedFilter == 'Your Area', isTablet),
                ],
              ),
              SizedBox(height: isTablet ? 16 : 12),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // Content Section
              Expanded(
                child: _buildContent(isTablet, isLandscape),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isTablet, bool isLandscape) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2C2C2C)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading hubs...',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 18 : 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isTablet ? 80 : 60,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Error loading hubs',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHubs,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C2C2C),
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 20,
                  vertical: isTablet ? 16 : 12,
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredHubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: isTablet ? 80 : 60,
              color: Color(0xFF666666),
            ),
            SizedBox(height: 16),
            Text(
              'No hubs found',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111111),
              ),
            ),
            SizedBox(height: 8),
            Text(
              selectedFilter == 'All' 
                  ? 'There are no hubs available at the moment.'
                  : 'No hubs found in your selected filter.',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return isTablet && isLandscape
        ? _buildTabletLayout()
        : _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      itemCount: filteredHubs.length,
      itemBuilder: (context, index) {
        final hub = filteredHubs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildHubCard(hub, false),
        );
      },
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
      itemCount: filteredHubs.length,
      itemBuilder: (context, index) {
        final hub = filteredHubs[index];
        return _buildHubCard(hub, true);
      },
    );
  }

  Widget _buildFilterButton(String text, String count, bool isSelected, bool isTablet) {
    return GestureDetector(
      onTap: () => _filterHubs(text),
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

  Widget _buildHubCard(JobhubModel hub, bool isTablet) {
    final buttonText = hub.jobStatusText;
    final buttonColor = _getButtonColor(hub.jobStatus);
    final buttonIcon = _getButtonIcon(hub.jobStatus);

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: _getBorderColor(hub.jobStatus),
          width: hub.isCompleted ? 1 : 2,
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
              // Hub Image/Icon
              Container(
                width: isTablet ? 80 : 60,
                height: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                  color: Color(0xFFF5F5F5),
                ),
                child: Center(
                  child: Text(
                    hub.categoryIcon,
                    style: TextStyle(fontSize: isTablet ? 32 : 24),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              // Hub Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hub.title,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                            hub.fullAddress,
                            style: GoogleFonts.poppins(
                              color: Color(0xFF666666),
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Color(0xFF666666),
                          size: isTablet ? 16 : 14,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          hub.category,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF666666),
                            fontSize: isTablet ? 14 : 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 6 : 4),
                    Text(
                      hub.formattedPaymentAmount,
                      style: GoogleFonts.poppins(
                        color: Color(0xFF111111),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (hub.description != null && hub.description!.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        hub.description!,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF666666),
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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

  Color _getButtonColor(int? jobStatus) {
    switch (jobStatus) {
      case 1: // Available
        return Color(0xFF06C698);
      case 2: // In Progress
        return Color(0xFFFF9800);
      case 3: // Completed
        return Color(0xFF2C2C2C);
      default:
        return Color(0xFF666666);
    }
  }

  IconData _getButtonIcon(int? jobStatus) {
    switch (jobStatus) {
      case 1: // Available
        return Icons.access_time;
      case 2: // In Progress
        return Icons.work;
      case 3: // Completed
        return Icons.arrow_forward;
      default:
        return Icons.info;
    }
  }

  Color _getBorderColor(int? jobStatus) {
    switch (jobStatus) {
      case 1: // Available
        return Color(0xFF06C698);
      case 2: // In Progress
        return Color(0xFFFF9800);
      case 3: // Completed
        return Color(0xFFE0E0E0);
      default:
        return Color(0xFFE0E0E0);
    }
  }
}
