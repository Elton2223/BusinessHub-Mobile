import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/work_session_model.dart';
import '../model/jobhub_model.dart';
import '../providers/auth_provider.dart';
import '../services/work_session_service.dart';
import '../services/hub_repository.dart';
import 'active_work_session_screen.dart';

/// Lists active work sessions for the current worker.
class ActiveWorkListScreen extends StatefulWidget {
  const ActiveWorkListScreen({super.key});

  static String routePath = '/active-work-list';

  @override
  State<ActiveWorkListScreen> createState() => _ActiveWorkListScreenState();
}

class _ActiveWorkListScreenState extends State<ActiveWorkListScreen> {
  List<WorkSessionModel> _sessions = [];
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
        _sessions = [];
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final list = await WorkSessionService.getActiveSessionsForWorker(userId);
      for (final s in list) {
        _hubCache[s.hubId] ??= await HubRepository.getJobhubById(s.hubId);
      }
      if (mounted) {
        setState(() => _loading = false);
        _sessions = list;
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

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
          'Active work',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No active work sessions',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When an employer accepts your application, your job will appear here. Location (50m) tracking and payment confirmation happen here.',
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
                  child: ListView.builder(
                    padding: EdgeInsets.all(isTablet ? 24 : 16),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final hub = _hubCache[session.hubId];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(
                            hub?.title ?? 'Hub #${session.hubId}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            _statusText(session),
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => ActiveWorkSessionScreen(session: session),
                              ),
                            );
                            _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _statusText(WorkSessionModel s) {
    if (s.isPendingArrival) return 'Go to job location (50m) to check in';
    if (s.isArrivedWaitingConfirm) return 'Waiting for employer to confirm arrival';
    if (s.isInProgress) return 'Work in progress';
    if (s.isCompletedToday) return 'Completed for today – may continue later';
    return 'Active';
  }
}
