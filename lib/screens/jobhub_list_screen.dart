import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jobhub_provider.dart';
import '../widgets/jobhub_card.dart';
import '../model/jobhub_model.dart';

class JobhubListScreen extends StatefulWidget {
  final String? title;
  final List<JobhubModel>? initialJobhubs;
  final bool showSearch;
  final bool showFilters;

  const JobhubListScreen({
    Key? key,
    this.title,
    this.initialJobhubs,
    this.showSearch = true,
    this.showFilters = true,
  }) : super(key: key);

  @override
  State<JobhubListScreen> createState() => _JobhubListScreenState();
}

class _JobhubListScreenState extends State<JobhubListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  List<JobhubModel> _filteredJobhubs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialJobhubs == null) {
        context.read<JobhubProvider>().loadAllJobhubs();
      } else {
        _filteredJobhubs = widget.initialJobhubs!;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final provider = context.read<JobhubProvider>();
    List<JobhubModel> jobhubs = widget.initialJobhubs ?? provider.allJobhubs;

    // Apply category filter
    if (_selectedCategory != 'All') {
      jobhubs = jobhubs.where((j) => j.category == _selectedCategory).toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      switch (_selectedStatus) {
        case 'Available':
          jobhubs = jobhubs.where((j) => j.isAvailable).toList();
          break;
        case 'In Progress':
          jobhubs = jobhubs.where((j) => j.isInProgress).toList();
          break;
        case 'Completed':
          jobhubs = jobhubs.where((j) => j.isCompleted).toList();
          break;
      }
    }

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      jobhubs = provider.searchJobhubs(_searchController.text);
    }

    setState(() {
      _filteredJobhubs = jobhubs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Available Hubs'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.showFilters)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
        ],
      ),
      body: Consumer<JobhubProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading jobhubs',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final jobhubs = widget.initialJobhubs ?? provider.allJobhubs;
          if (jobhubs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No jobhubs found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters or check back later',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search bar
              if (widget.showSearch) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search jobhubs...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _applyFilters();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (value) => _applyFilters(),
                  ),
                ),
              ],
              
              // Active filters display
              if (_selectedCategory != 'All' || _selectedStatus != 'All')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Filters: ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_selectedCategory != 'All')
                        Chip(
                          label: Text(_selectedCategory),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = 'All';
                            });
                            _applyFilters();
                          },
                        ),
                      if (_selectedStatus != 'All')
                        Chip(
                          label: Text(_selectedStatus),
                          onDeleted: () {
                            setState(() {
                              _selectedStatus = 'All';
                            });
                            _applyFilters();
                          },
                        ),
                    ],
                  ),
                ),
              
              // Jobhubs list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.refreshData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _filteredJobhubs.isEmpty 
                        ? jobhubs.length 
                        : _filteredJobhubs.length,
                    itemBuilder: (context, index) {
                      final jobhub = _filteredJobhubs.isEmpty 
                          ? jobhubs[index] 
                          : _filteredJobhubs[index];
                      
                      return JobhubCard(
                        jobhub: jobhub,
                        onTap: () => _showJobhubDetails(jobhub),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    final provider = context.read<JobhubProvider>();
    final categories = ['All', ...provider.uniqueCategories];
    final statuses = ['All', 'Available', 'In Progress', 'Completed'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Jobhubs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category filter
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? 'All';
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Status filter
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value ?? 'All';
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedStatus = 'All';
              });
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showJobhubDetails(JobhubModel jobhub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  jobhub.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Jobhub details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: JobhubCard(
                    jobhub: jobhub,
                    showFullDetails: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
