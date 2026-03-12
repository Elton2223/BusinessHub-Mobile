import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/jobhub_model.dart';
import '../providers/auth_provider.dart';
import '../services/hub_repository.dart';
import '../services/application_service.dart';
import '../services/notification_service.dart';
import '../services/work_session_service.dart';
import '../services/payment_proof_service.dart';
import '../data/dummy_hub_data.dart';
import '../model/work_session_model.dart';
import '../widgets/rate_user_dialog.dart';
import '../utils/success_snackbar.dart';

class HubDetailPage extends StatefulWidget {
  const HubDetailPage({super.key, required this.hubId});

  static String routePath = '/hub-detail';
  final int hubId;

  @override
  State<HubDetailPage> createState() => _HubDetailPageState();
}

class _HubDetailPageState extends State<HubDetailPage> {
  JobhubModel? _hub;
  bool _loading = true;
  String? _error;
  bool _applying = false;
  String? _applyMessage;
  bool _alreadyApplied = false;
  String? _otherPartyUserId;
  String _otherPartyName = '';
  String _myRole = ''; // as_employer | as_worker
  bool _isOwner = false;
  bool _markingComplete = false;
  WorkSessionModel? _workSession;
  bool _paymentProofEmployerSubmitted = false;
  bool _paymentProofClientConfirmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHub());
  }

  bool _isHubOwner(JobhubModel hub, String userId) {
    if (hub.registerId == null) return false;
    if (hub.registerId?.toString() == userId) return true;
    final idAsInt = int.tryParse(userId);
    return idAsInt != null && hub.registerId == idAsInt;
  }

  Future<void> _loadHub() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hub = await HubRepository.getJobhubById(widget.hubId);
      if (mounted) {
        final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
        bool applied = false;
        String? otherUserId;
        String otherName = '';
        String myRole = '';
        if (userId != null) {
          final myApps = await ApplicationService.getMyApplications(userId);
          applied = myApps.any((a) => a.hubId == widget.hubId);
          if (hub != null && hub.isCompleted) {
            final apps = await ApplicationService.getApplicationsForHub(hub.id!);
            final accepted = apps.where((a) => a.isAccepted).toList();
            if (accepted.isNotEmpty) {
              final app = accepted.first;
              if (hub.registerId?.toString() == userId) {
                myRole = 'as_employer';
                otherUserId = app.applicantUserId;
                final profile = DummyHubData.getDummyUser(app.applicantUserId);
                otherName = profile != null
                    ? '${profile['name'] ?? ''} ${profile['surname'] ?? ''}'.trim()
                    : 'Worker';
              } else if (app.applicantUserId == userId) {
                myRole = 'as_worker';
                otherUserId = hub.registerId?.toString();
                otherName = 'Hub owner';
              }
            }
          }
        }
        WorkSessionModel? session;
        bool payEmployer = false;
        bool payClient = false;
        if (hub != null && userId != null && _isHubOwner(hub, userId)) {
          session = await WorkSessionService.getSessionForHub(hub.id!, userId);
          if (session != null && session.isCompletedFull) {
            final proof = await PaymentProofService.getBySession(session.id);
            payEmployer = proof?.employerSubmitted ?? false;
            payClient = proof?.clientConfirmed ?? false;
          }
        }
        setState(() {
          _hub = hub;
          _loading = false;
          _alreadyApplied = applied;
          _otherPartyUserId = otherUserId;
          _otherPartyName = otherName;
          _myRole = myRole;
          _isOwner = hub != null && userId != null && _isHubOwner(hub, userId);
          _workSession = session;
          _paymentProofEmployerSubmitted = payEmployer;
          _paymentProofClientConfirmed = payClient;
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

  Future<void> _apply() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user?.id == null || _hub == null) return;

    setState(() => _applying = true);
    try {
      final app = await ApplicationService.apply(
        hubId: _hub!.id!,
        applicantUserId: user!.id!,
        message: _applyMessage?.trim().isEmpty == true ? null : _applyMessage,
      );
      if (app != null && mounted) {
        await NotificationService.notifyApplicationReceived(
          toUserId: _hub!.registerId?.toString() ?? '',
          fromUserId: user.id!,
          hubId: _hub!.id!,
          applicationId: app.id!,
          hubTitle: _hub!.title,
          applicantName: user.fullName,
        );
        if (mounted) {
          setState(() {
            _applying = false;
            _alreadyApplied = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application sent. The hub owner will be notified.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _applying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You cannot apply to your own hub.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _applying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e'), backgroundColor: Colors.red),
        );
      }
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
          'Hub details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadHub,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _hub == null
                  ? const Center(child: Text('Hub not found'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(isTablet),
                          if (_hub!.isInProgress && _isOwner) ...[
                            const SizedBox(height: 20),
                            _buildMarkCompleteSection(isTablet),
                            const SizedBox(height: 20),
                          ],
                          _buildSection('Requirements', _hub!.requirements ?? 'No specific requirements.', isTablet),
                          _buildSection('Description', _hub!.description ?? '', isTablet),
                          _buildPricing(isTablet),
                          if (_hub!.isAvailable && !_alreadyApplied && !_isOwner) ...[
                            const SizedBox(height: 24),
                            _buildApplySection(isTablet),
                          ] else if (_isOwner && _hub!.isAvailable) ...[
                            const SizedBox(height: 24),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'This is your hub. You can manage it from My Hubs. Others will see it here and can apply.',
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else if (_alreadyApplied && !_hub!.isAvailable) ...[
                            const SizedBox(height: 24),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade700),
                                    const SizedBox(width: 12),
                                    Text(
                                      'You have already applied to this hub.',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (_hub!.isCompleted && _otherPartyUserId != null && _otherPartyUserId!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildRateSection(isTablet),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hub!.isInProgress && _isOwner) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF06C698).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF06C698).withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.work, color: const Color(0xFF06C698), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This job is in progress. Use the green card below to confirm arrival or complete work.',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0A5C4A)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Container(
                  width: isTablet ? 64 : 48,
                  height: isTablet ? 64 : 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06C698).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _hub!.categoryIcon,
                      style: TextStyle(fontSize: isTablet ? 28 : 22),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hub!.title,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hub!.category,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 14 : 12,
                          color: const Color(0xFF666666),
                        ),
                      ),
                      Text(
                        _hub!.fullAddress,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 13 : 12,
                          color: const Color(0xFF666666),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _hub!.isAvailable
                    ? Colors.green.shade50
                    : _hub!.isInProgress
                        ? Colors.orange.shade50
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _hub!.jobStatusText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: _hub!.isAvailable
                      ? Colors.green.shade800
                      : _hub!.isInProgress
                          ? Colors.orange.shade800
                          : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isTablet) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 14 : 13,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricing(bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111111),
              ),
            ),
            Text(
              '${_hub!.formattedPaymentAmount} (${_hub!.paymentTypeText})',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF06C698),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmArrival() async {
    if (_workSession == null || _markingComplete) return;
    setState(() => _markingComplete = true);
    try {
      await WorkSessionService.confirmWorkerArrival(_workSession!.id);
      if (mounted) {
        setState(() => _markingComplete = false);
        await _loadHub();
        showSuccessSnackBar(context, 'Worker arrival confirmed. Work in progress.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _markingComplete = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showCompleteWorkDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Complete work', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Is the work fully done or just for today?',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 16),
            Text(
              '• Complete work: Job is finished. You can send payment and both can rate.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '• Complete work for today: Worker didn\'t finish; work continues another day.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _completeWork('today');
            },
            child: Text('Complete work for today', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _completeWork('full');
            },
            child: Text('Complete work', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeWork(String type) async {
    if (_workSession == null || _hub == null || _markingComplete) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _markingComplete = true);
    try {
      await WorkSessionService.completeWork(_workSession!.id, type);
      if (type == 'full') {
        await HubRepository.updateJobhub(widget.hubId, JobhubModel(
          id: _hub!.id,
          title: _hub!.title,
          streetAddress: _hub!.streetAddress,
          country: _hub!.country,
          postalCode: _hub!.postalCode,
          state: _hub!.state,
          city: _hub!.city,
          latitude: _hub!.latitude,
          longitude: _hub!.longitude,
          category: _hub!.category,
          paymentType: _hub!.paymentType,
          paymentAmount: _hub!.paymentAmount,
          description: _hub!.description,
          requirements: _hub!.requirements,
          jobStatus: 3,
          registerId: _hub!.registerId,
          dateCreated: _hub!.dateCreated,
          dateAccepted: _hub!.dateAccepted,
          dateFinished: DateTime.now(),
        ));
      }
      if (mounted) {
        setState(() => _markingComplete = false);
        await _loadHub();
        showSuccessSnackBar(context, type == 'full' ? 'Work completed. You can now send payment.' : 'Marked as complete for today.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _markingComplete = false);
        messenger.showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _markAsCompleted() async {
    if (_hub == null || _markingComplete) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _markingComplete = true);
    try {
      await HubRepository.updateJobhub(widget.hubId, JobhubModel(
        id: _hub!.id,
        title: _hub!.title,
        streetAddress: _hub!.streetAddress,
        country: _hub!.country,
        postalCode: _hub!.postalCode,
        state: _hub!.state,
        city: _hub!.city,
        latitude: _hub!.latitude,
        longitude: _hub!.longitude,
        category: _hub!.category,
        paymentType: _hub!.paymentType,
        paymentAmount: _hub!.paymentAmount,
        description: _hub!.description,
        requirements: _hub!.requirements,
        jobStatus: 3,
        registerId: _hub!.registerId,
        dateCreated: _hub!.dateCreated,
        dateAccepted: _hub!.dateAccepted,
        dateFinished: DateTime.now(),
      ));
      if (mounted) {
        setState(() => _markingComplete = false);
        await _loadHub();
        showSuccessSnackBar(context, 'Hub marked as completed. You can now rate the worker.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _markingComplete = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildMarkCompleteSection(bool isTablet) {
    final session = _workSession;
    if (session != null) {
      if (session.isPendingArrival) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.orange.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Waiting for worker to arrive',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The system will track when the worker is within 50m of the job location. You will get a notification to confirm their arrival.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        );
      }
      if (session.isArrivedWaitingConfirm) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Worker has arrived',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The worker is within 50m of the job location. Confirm their arrival to start tracking work.',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _markingComplete ? null : _confirmArrival,
                    icon: _markingComplete ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle_outline),
                    label: Text(_markingComplete ? 'Confirming...' : 'Confirm arrival', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06C698), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (session.isInProgress || session.isCompletedToday) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.person, color: const Color(0xFF06C698), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Only you can complete this job',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF06C698)),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Job in progress',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
                ),
                const SizedBox(height: 8),
                Text(
                  'When work is done, choose "Complete work" (full) or "Complete work for today" if it continues another day.',
                  style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _markingComplete ? null : _showCompleteWorkDialog,
                    icon: _markingComplete ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle_outline),
                    label: Text(_markingComplete ? 'Updating...' : 'Complete work', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06C698), foregroundColor: Colors.white, padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      if (session.isCompletedFull && !_paymentProofClientConfirmed) {
        return _buildSendPaymentSection(isTablet);
      }
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.person, color: const Color(0xFF06C698), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You’re the employer – only you can mark this job complete',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF06C698)),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Job in progress',
              style: GoogleFonts.poppins(fontSize: isTablet ? 16 : 14, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
            ),
            const SizedBox(height: 8),
            Text(
              'When the work is done, mark this hub as completed so both parties can rate each other.',
              style: GoogleFonts.poppins(fontSize: isTablet ? 14 : 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _markingComplete ? null : _markAsCompleted,
                icon: _markingComplete
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(_markingComplete ? 'Updating...' : 'Mark as completed', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06C698),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _paymentProofDescription = '';

  Widget _buildSendPaymentSection(bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send payment',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
            ),
            const SizedBox(height: 8),
            Text(
              'Submit payment proof (e.g. reference number, screenshot description). The worker will confirm receipt with their proof.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
            ),
            if (_paymentProofEmployerSubmitted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text('Payment proof submitted. Waiting for worker to confirm.', style: GoogleFonts.poppins(fontSize: 13, color: Colors.green.shade900)),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _paymentProofDescription = v,
                decoration: const InputDecoration(
                  hintText: 'Payment reference or proof description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _markingComplete ? null : _submitPaymentProof,
                  icon: _markingComplete ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.payment),
                  label: Text(_markingComplete ? 'Submitting...' : 'Submit payment proof', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06C698), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submitPaymentProof() async {
    if (_workSession == null || _hub == null || _markingComplete) return;
    if (_paymentProofDescription.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter payment proof description.')));
      return;
    }
    setState(() => _markingComplete = true);
    try {
      await PaymentProofService.submitEmployerProof(
        hubId: _hub!.id!,
        sessionId: _workSession!.id,
        amount: _hub!.paymentAmount,
        proofDescription: _paymentProofDescription.trim(),
      );
      if (mounted) {
        setState(() {
          _markingComplete = false;
          _paymentProofEmployerSubmitted = true;
        });
        showSuccessSnackBar(context, 'Payment proof submitted. Worker will confirm.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _markingComplete = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildRateSection(bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700),
                const SizedBox(width: 8),
                Text(
                  'Rate this job',
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111111),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _myRole == 'as_employer'
                  ? 'How was your experience with $_otherPartyName?'
                  : 'How was your experience with $_otherPartyName?',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 14 : 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await showRateUserDialog(
                    context: context,
                    hubId: _hub!.id!,
                    toUserId: _otherPartyUserId!,
                    toUserName: _otherPartyName,
                    role: _myRole,
                    onRated: () {
                      if (mounted) Navigator.of(context).pop();
                    },
                  );
                },
                icon: const Icon(Icons.star_border, size: 20),
                label: Text(
                  _myRole == 'as_employer' ? 'Rate worker' : 'Rate employer',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplySection(bool isTablet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apply for this hub',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: (v) => setState(() => _applyMessage = v),
              decoration: InputDecoration(
                hintText: 'Short message (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applying ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _applying
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Send application',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
