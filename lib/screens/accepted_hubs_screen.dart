import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/work_session_model.dart';
import '../model/jobhub_model.dart';
import '../providers/auth_provider.dart';
import '../services/work_session_service.dart';
import '../services/hub_repository.dart';
import '../hubs/hub_detail_page.dart';
import 'active_work_session_screen.dart';

/// Page listing all accepted hubs/jobs for the current user (as worker and as employer).
class AcceptedHubsScreen extends StatefulWidget {
  const AcceptedHubsScreen({super.key});

  static String routePath = '/accepted-hubs';

  @override
  State<AcceptedHubsScreen> createState() => _AcceptedHubsScreenState();
}

class _AcceptedHubsScreenState extends State<AcceptedHubsScreen> {
  List<WorkSessionModel> _asWorker = [];
  List<WorkSessionModel> _asEmployer = [];
  final Map<int, JobhubModel?> _hubCache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) {
      setState(() {
        _loading = false;
        _asWorker = [];
        _asEmployer = [];
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        WorkSessionService.getActiveSessionsForWorker(userId),
        WorkSessionService.getActiveSessionsForEmployer(userId),
      ]);
      final asWorker = results[0];
      final asEmployer = results[1];
      for (final s in asWorker) _hubCache[s.hubId] ??= await HubRepository.getJobhubById(s.hubId);
      for (final s in asEmployer) _hubCache[s.hubId] ??= await HubRepository.getJobhubById(s.hubId);
      if (mounted) {
        setState(() {
          _loading = false;
          _asWorker = asWorker;
          _asEmployer = asEmployer;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final hasAny = _asWorker.isNotEmpty || _asEmployer.isNotEmpty;

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
          'Accepted hubs',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !hasAny
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No accepted hubs yet',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When you accept or get accepted for a hub, it will appear here.',
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
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    children: [
                      if (_asWorker.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'As worker',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                        ..._asWorker.map((session) => _buildSessionCard(session, true, isTablet)),
                        const SizedBox(height: 20),
                      ],
                      if (_asEmployer.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'As employer',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF111111),
                            ),
                          ),
                        ),
                        ..._asEmployer.map((session) => _buildSessionCard(session, false, isTablet)),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildSessionCard(WorkSessionModel session, bool isAsWorker, bool isTablet) {
    final hub = _hubCache[session.hubId];
    final title = hub?.title ?? 'Hub #${session.hubId}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isAsWorker ? const Color(0xFF06C698).withOpacity(0.15) : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isAsWorker ? Icons.person : Icons.business,
            color: isAsWorker ? const Color(0xFF06C698) : Colors.orange.shade700,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _statusText(session, isAsWorker),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (!isAsWorker) ...[
              const SizedBox(height: 2),
              Text(
                'Tap to complete work, confirm arrival, or send payment',
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF06C698), fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          if (isAsWorker) {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => ActiveWorkSessionScreen(session: session),
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => HubDetailPage(hubId: session.hubId),
              ),
            );
          }
          _load();
        },
      ),
    );
  }

  String _statusText(WorkSessionModel s, bool isAsWorker) {
    if (s.isPendingArrival) return isAsWorker ? 'Go to job location (50m) to check in' : 'Waiting for worker to arrive (50m)';
    if (s.isArrivedWaitingConfirm) return isAsWorker ? 'Waiting for employer to confirm arrival' : 'Worker arrived – confirm arrival';
    if (s.isInProgress) return 'Work in progress';
    if (s.isCompletedToday) return 'Completed for today';
    if (s.isCompletedFull) return 'Completed';
    return 'Active';
  }
}
