import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/job_history_model.dart';
import '../providers/auth_provider.dart';
import '../services/job_history_service.dart';
import '../hubs/hub_detail_page.dart';
import '../widgets/rate_user_dialog.dart';

class JobHistoryScreen extends StatefulWidget {
  const JobHistoryScreen({super.key});

  static String routeName = 'JobHistoryScreen';
  static String routePath = '/job-history';

  @override
  State<JobHistoryScreen> createState() => _JobHistoryScreenState();
}

class _JobHistoryScreenState extends State<JobHistoryScreen> {
  List<JobHistoryModel> _history = [];
  int _total = 0;
  int _page = 0;
  static const int _pageSize = 10;
  String _roleFilter = 'all'; // 'all' | 'worker' | 'employer'
  bool _loading = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load({bool resetPage = true}) async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) {
      setState(() {
        _loading = false;
        _history = [];
        _total = 0;
        if (resetPage) _page = 0;
      });
      return;
    }
    setState(() {
      _loading = true;
      if (resetPage) _page = 0;
    });
    try {
      final result = await JobHistoryService.getHistoryForUserPaginated(
        userId,
        roleFilter: _roleFilter,
        page: 0,
        pageSize: _pageSize,
      );
      final list = result['list'] as List<JobHistoryModel>;
      final total = result['total'] as int;
      if (mounted) {
        setState(() {
          _history = list;
          _total = total;
          _page = 0;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null || _loadingMore || _history.length >= _total) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    try {
      final result = await JobHistoryService.getHistoryForUserPaginated(
        userId,
        roleFilter: _roleFilter,
        page: nextPage,
        pageSize: _pageSize,
      );
      final list = result['list'] as List<JobHistoryModel>;
      final total = result['total'] as int;
      if (mounted) {
        setState(() {
          _history = [..._history, ...list];
          _total = total;
          _page = nextPage;
          _loadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _setFilter(String filter) {
    if (_roleFilter == filter) return;
    setState(() => _roleFilter = filter);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final userId = context.read<AuthProvider>().currentUser?.id;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Job history',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: 12),
            child: Row(
              children: [
                _filterChip('All', _roleFilter == 'all', () => _setFilter('all')),
                const SizedBox(width: 8),
                _filterChip('As worker', _roleFilter == 'worker', () => _setFilter('worker')),
                const SizedBox(width: 8),
                _filterChip('As employer', _roleFilter == 'employer', () => _setFilter('employer')),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No completed jobs yet',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _roleFilter == 'all'
                                    ? 'Completed jobs (after payment) will appear here.'
                                    : 'No jobs in this filter.',
                                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => Navigator.pushReplacementNamed(context, '/hub-list'),
                                icon: const Icon(Icons.search, size: 20),
                                label: Text('Browse Hubs', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C2C2C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(),
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(
                            isTablet ? 24 : 16,
                            12,
                            isTablet ? 24 : 16,
                            24,
                          ),
                          itemCount: _history.length + (_history.length < _total ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _history.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _loadingMore
                                      ? const SizedBox(
                                          height: 40,
                                          width: 40,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : TextButton.icon(
                                          onPressed: _loadMore,
                                          icon: const Icon(Icons.add_circle_outline, size: 20),
                                          label: Text(
                                            'Load more',
                                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(0xFF06C698),
                                          ),
                                        ),
                                ),
                              );
                            }
                            final h = _history[index];
                            final isWorker = userId != null && h.workerId == userId;
                            return _buildHistoryCard(context, h, isWorker, isTablet);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500)),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF06C698).withOpacity(0.3),
      checkmarkColor: const Color(0xFF06C698),
    );
  }

  Widget _buildHistoryCard(BuildContext context, JobHistoryModel h, bool isWorker, bool isTablet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => HubDetailPage(hubId: h.hubId),
            ),
          );
          _load(resetPage: false);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      h.hubTitle,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isWorker
                          ? const Color(0xFF06C698).withOpacity(0.15)
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isWorker ? 'Worker' : 'Employer',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isWorker ? const Color(0xFF06C698) : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'R${h.paymentAmount.toStringAsFixed(2)} • ${_formatDate(h.completedAt)}',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
              ),
              if (!h.ratingGiven) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    showRateUserDialog(
                      context: context,
                      hubId: h.hubId,
                      toUserId: isWorker ? h.employerId : h.workerId,
                      toUserName: isWorker ? 'Employer' : 'Worker',
                      role: isWorker ? 'as_worker' : 'as_employer',
                    );
                    JobHistoryService.markRatingGiven(h.id);
                    _load(resetPage: false);
                  },
                  icon: const Icon(Icons.star_border, size: 18),
                  label: Text(isWorker ? 'Rate employer' : 'Rate worker'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF06C698),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Today';
    final diff = now.difference(d);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${d.day}/${d.month}/${d.year}';
  }
}
