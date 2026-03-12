import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../model/jobhub_model.dart';
import '../providers/auth_provider.dart';
import '../services/hub_repository.dart';
import '../services/filter_settings_service.dart';
import '../services/location_tracking_service.dart';
import '../model/filter_settings_model.dart';
import '../utils/success_snackbar.dart';
import 'hub_detail_page.dart';
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
  FilterSettingsModel _filterSettings = FilterSettingsModel();
  double? _deviceLat;
  double? _deviceLng;
  Set<int> _completedHubIds = {};

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
    // Defer data load to after the first frame so navigation and first paint complete
    // without blocking the main thread (fixes "Skipped N frames" when opening from Active work).
    WidgetsBinding.instance.addPostFrameCallback((_) => _deferredInit());
  }

  Future<void> _deferredInit() async {
    if (!mounted) return;
    await _fetchDeviceLocationIfNeeded();
    if (!mounted) return;
    await _loadFilterSettings();
    if (!mounted) return;
    await _loadHubs();
  }

  Future<void> _fetchDeviceLocationIfNeeded() async {
    if (!mounted) return;
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user?.latitude != null && user?.longitude != null) return;
    final pos = await LocationTrackingService.getCurrentPosition();
    if (mounted && pos != null) {
      setState(() {
        _deviceLat = pos.latitude;
        _deviceLng = pos.longitude;
      });
    }
  }

  Future<void> _loadFilterSettings() async {
    final s = await FilterSettingsService.load();
    if (mounted) setState(() => _filterSettings = s);
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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

      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      double? lat = user?.latitude ?? _deviceLat;
      double? lng = user?.longitude ?? _deviceLng;
      if (lat == null || lng == null) {
        final pos = await LocationTrackingService.getCurrentPosition();
        if (pos != null && mounted) {
          lat = pos.latitude;
          lng = pos.longitude;
          setState(() {
            _deviceLat = lat;
            _deviceLng = lng;
          });
        }
      }
      List<JobhubModel> hubs;
      if (_filterSettings.locationRangeKm > 0 && lat != null && lng != null) {
        hubs = await HubRepository.getJobhubsNear(lat, lng, _filterSettings.locationRangeKm);
      } else {
        hubs = await HubRepository.getAllJobhubs();
      }
      // Do not show the current user's own hubs in the main list (they appear under "My Hubs")
      final currentUserId = user?.id;
      if (currentUserId != null && currentUserId.isNotEmpty) {
        hubs = hubs.where((h) => h.registerId?.toString() != currentUserId).toList();
      }
      // If location filter left no hubs (e.g. all nearby hubs are own), show all hubs except own
      if (hubs.isEmpty && currentUserId != null && currentUserId.isNotEmpty) {
        final all = await HubRepository.getAllJobhubs();
        hubs = all.where((h) => h.registerId?.toString() != currentUserId).toList();
      }
      if (_filterSettings.availableOnly) {
        hubs = hubs.where((h) => h.isAvailable).toList();
      }
      // Load hub IDs with completed work so Ongoing/ongoingOnly exclude them
      final completedIds = await HubRepository.getHubIdsWithCompletedSession();
      if (mounted) setState(() => _completedHubIds = completedIds);
      if (_filterSettings.ongoingOnly) {
        hubs = hubs.where((h) => h.isInProgress && !completedIds.contains(h.id ?? -1)).toList();
      }
      if (_filterSettings.areaNames.isNotEmpty) {
        final areas = _filterSettings.areaNames.map((a) => a.toLowerCase()).toSet();
        hubs = hubs.where((h) => areas.contains(h.city.toLowerCase())).toList();
      }
      if (_filterSettings.categories.isNotEmpty) {
        final cats = _filterSettings.categories.map((c) => c.toLowerCase()).toSet();
        hubs = hubs.where((h) => cats.contains(h.category.toLowerCase())).toList();
      }
      // Closest hubs first when user location is available
      hubs = HubRepository.sortByDistance(hubs, lat, lng);

      if (mounted) {
        setState(() {
          allHubs = hubs;
          filteredHubs = _applyUiFilter(hubs, selectedFilter);
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

  List<JobhubModel> _applyUiFilter(List<JobhubModel> hubs, String filter) {
    switch (filter) {
      case 'Your Area':
        return hubs.where((hub) => hub.city.isNotEmpty || hub.state.isNotEmpty).toList();
      case 'Available':
        return hubs.where((hub) => hub.isAvailable).toList();
      case 'Ongoing':
        return hubs.where((hub) => hub.isInProgress && !_completedHubIds.contains(hub.id)).toList();
      default:
        return hubs;
    }
  }

  void _filterHubs(String filter) {
    setState(() {
      selectedFilter = filter;
      filteredHubs = _applyUiFilter(allHubs, filter);
    });
  }

  int get _allHubsCount => allHubs.length;
  int get _areaHubsCount => allHubs.where((hub) => hub.city.isNotEmpty || hub.state.isNotEmpty).length;
  int get _availableCount => allHubs.where((hub) => hub.isAvailable).length;
  int get _ongoingCount => allHubs.where((hub) => hub.isInProgress).length;

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
          'Active Hubs',
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
              // Add a job/hub section - become part of active hubs
              InkWell(
                onTap: () => _showAddHubDialog(context, onSuccess: _loadHubs),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF2C2C2C),
                        Color(0xFF3d3d3d),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isTablet ? 14 : 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_business,
                          color: Colors.white,
                          size: isTablet ? 32 : 28,
                        ),
                      ),
                      SizedBox(width: isTablet ? 20 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add a hub',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Become part of active hubs',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: isTablet ? 14 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 20 : 16),
              // Filter Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('All', _allHubsCount.toString(), selectedFilter == 'All', isTablet),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildFilterButton('Your Area', _areaHubsCount.toString(), selectedFilter == 'Your Area', isTablet),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildFilterButton('Available', _availableCount.toString(), selectedFilter == 'Available', isTablet),
                    SizedBox(width: isTablet ? 16 : 12),
                    _buildFilterButton('Ongoing', _ongoingCount.toString(), selectedFilter == 'Ongoing', isTablet),
                    SizedBox(width: isTablet ? 16 : 12),
                    IconButton(
                      icon: Icon(Icons.tune, color: Color(0xFF2C2C2C)),
                      onPressed: () => Navigator.pushNamed(context, '/hub-filters').then((_) => _loadHubs(silent: true)),
                      tooltip: 'Filter settings',
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // Content Section - Active Hubs
              Expanded(
                child: _buildContent(isTablet, isLandscape),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _hubCategories = [
    'Services',
    'Technology',
    'Education',
    'Construction',
    'Creative',
    'Healthcare',
    'Finance',
    'Business',
    'Marketing',
  ];

  void _showAddHubDialog(BuildContext context, {VoidCallback? onSuccess}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _AddHubDialogContent(
        hubCategories: _hubCategories,
        onSuccess: () {
          Navigator.of(context).pop();
          onSuccess?.call();
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    ).then((_) {
      // Show success from inside the content after submit
    });
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
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
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
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddHubDialog(context, onSuccess: _loadHubs),
                icon: const Icon(Icons.add_business, size: 20),
                label: Text('Post a hub', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        final lat = user?.latitude ?? _deviceLat;
        final lng = user?.longitude ?? _deviceLng;
        return isTablet && isLandscape
            ? _buildTabletLayout(lat, lng)
            : _buildMobileLayout(lat, lng);
      },
    );
  }

  Widget _buildMobileLayout(double? lat, double? lng) {
    return ListView.builder(
      itemCount: filteredHubs.length,
      itemBuilder: (context, index) {
        final hub = filteredHubs[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildHubCard(hub, false, lat, lng),
        );
      },
    );
  }

  Widget _buildTabletLayout(double? lat, double? lng) {
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
        return _buildHubCard(hub, true, lat, lng);
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

  /// Formats distance from current user to hub for display (m, km, or ft when very close).
  String _formatDistanceFromUser(double? userLat, double? userLng, JobhubModel hub) {
    if (userLat == null || userLng == null) return 'Distance unknown';
    final hubLat = double.tryParse(hub.latitude);
    final hubLng = double.tryParse(hub.longitude);
    if (hubLat == null || hubLng == null) return 'Distance unknown';
    final meters = LocationTrackingService.distanceMeters(userLat, userLng, hubLat, hubLng);
    if (meters < 1000) {
      final m = meters.round();
      final ft = (meters * 3.28084).round();
      if (m < 100) return '$m m (${ft} ft) away';
      return '${m} m away';
    }
    final km = meters / 1000;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km away';
  }

  Widget _buildHubCard(JobhubModel hub, bool isTablet, double? userLat, double? userLng) {
    final buttonText = hub.jobStatusText;
    final buttonColor = _getButtonColor(hub.jobStatus);
    final buttonIcon = _getButtonIcon(hub.jobStatus);
    final distanceText = _formatDistanceFromUser(userLat, userLng, hub);

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
                    Row(
                      children: [
                        Icon(
                          Icons.near_me,
                          color: Color(0xFF06C698),
                          size: isTablet ? 16 : 14,
                        ),
                        SizedBox(width: isTablet ? 6 : 4),
                        Text(
                          distanceText,
                          style: GoogleFonts.poppins(
                            color: Color(0xFF06C698),
                            fontSize: isTablet ? 13 : 12,
                            fontWeight: FontWeight.w500,
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
          InkWell(
            onTap: () {
              if (hub.id != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => HubDetailPage(hubId: hub.id!),
                  ),
                ).then((_) => _loadHubs(silent: true));
              }
            },
            borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
            child: Container(
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
                    hub.isAvailable ? 'View & Apply' : buttonText,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
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

/// Add-hub dialog: auto-fills current location; all location fields remain editable for hubs elsewhere.
class _AddHubDialogContent extends StatefulWidget {
  const _AddHubDialogContent({
    required this.hubCategories,
    required this.onSuccess,
    required this.onCancel,
  });

  final List<String> hubCategories;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  @override
  State<_AddHubDialogContent> createState() => _AddHubDialogContentState();
}

class _AddHubDialogContentState extends State<_AddHubDialogContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _streetAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _paymentAmountController;
  late TextEditingController _descriptionController;

  String _category = '';
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _category = widget.hubCategories.isNotEmpty ? widget.hubCategories.first : 'Technology';
    _titleController = TextEditingController();
    _streetAddressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _postalCodeController = TextEditingController();
    _countryController = TextEditingController(text: 'South Africa');
    _latController = TextEditingController();
    _lngController = TextEditingController();
    _paymentAmountController = TextEditingController();
    _descriptionController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillCurrentLocation());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _paymentAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fillCurrentLocation() async {
    if (_isLoadingLocation || !mounted) return;
    setState(() => _isLoadingLocation = true);
    try {
      final position = await LocationTrackingService.getCurrentPosition();
      if (position == null || !mounted) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (mounted && placemarks.isNotEmpty) {
        final place = placemarks[0];
        _streetAddressController.text = '${place.street ?? ''} ${place.subThoroughfare ?? ''}'.trim();
        _cityController.text = place.locality ?? '';
        _stateController.text = place.administrativeArea ?? '';
        _postalCodeController.text = place.postalCode ?? '';
        if (place.country != null && place.country!.isNotEmpty) {
          _countryController.text = place.country!;
        }
        setState(() {
          _isLoadingLocation = false;
          _locationFetched = true;
        });
      } else {
        if (mounted) setState(() => _isLoadingLocation = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSubmitting = true);
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final latStr = _latController.text.trim();
      final lngStr = _lngController.text.trim();
      final hub = JobhubModel(
        title: _titleController.text.trim(),
        streetAddress: _streetAddressController.text.trim(),
        country: _countryController.text.trim().isEmpty ? 'South Africa' : _countryController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        latitude: latStr.isEmpty ? '0' : latStr,
        longitude: lngStr.isEmpty ? '0' : lngStr,
        category: _category,
        paymentType: 1,
        paymentAmount: double.tryParse(_paymentAmountController.text.trim()) ?? 0,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        requirements: null,
        jobStatus: 1,
        registerId: user?.id != null ? int.tryParse(user!.id!) : null,
      );
      await HubRepository.createJobhub(hub);
      if (!mounted) return;
      widget.onSuccess();
      showSuccessSnackBar(context, 'Hub added successfully.');
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add hub: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'Add a new hub',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Hub title',
                  hintText: 'e.g. Web Development',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: widget.hubCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? widget.hubCategories.first),
              ),
              SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoadingLocation ? null : _fillCurrentLocation,
                icon: _isLoadingLocation
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(Icons.my_location, size: 20, color: Color(0xFF06C698)),
                label: Text(
                  _locationFetched ? 'Update to my current location' : 'Use my current location',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Color(0xFF06C698)),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF06C698)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (_locationFetched)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Location detected. You can edit the fields below if this hub is in a different area.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              SizedBox(height: 12),
              TextFormField(
                controller: _streetAddressController,
                decoration: InputDecoration(
                  labelText: 'Street address',
                  hintText: 'e.g. 123 Main Road',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'e.g. Johannesburg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(
                  labelText: 'State / Province',
                  hintText: 'e.g. Gauteng',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal code',
                  hintText: 'e.g. 2000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country',
                  hintText: 'e.g. South Africa',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        hintText: 'Auto-filled',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        hintText: 'Auto-filled',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _paymentAmountController,
                decoration: InputDecoration(
                  labelText: 'Payment amount (R)',
                  hintText: 'e.g. 2500',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Brief description of the hub',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : widget.onCancel,
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Add hub', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
