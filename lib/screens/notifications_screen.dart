import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/notification_model.dart';
import '../model/hub_application_model.dart';
import '../model/jobhub_model.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';
import '../services/application_service.dart';
import '../services/hub_repository.dart';
import '../services/work_session_service.dart';
import '../data/dummy_hub_data.dart';
import '../hubs/hub_detail_page.dart';
import 'app_pocket_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static String routeName = 'NotificationsScreen';
  static String routePath = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) {
      setState(() {
        _loading = false;
        _list = [];
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final list = await NotificationService.getNotificationsForUser(userId);
      if (mounted) setState(() {
        _list = list;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final user = context.watch<AuthProvider>().currentUser;

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
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to see notifications.'))
          : _loading
              ? const Center(child: CircularProgressIndicator())
              : _list.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'ll see updates here when you get new applications or work alerts.',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushReplacementNamed(context, '/hub-list'),
                              icon: const Icon(Icons.business, size: 20),
                              label: Text('Go to Hubs', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
                        itemCount: _list.length,
                        itemBuilder: (context, index) {
                          final n = _list[index];
                          return _NotificationTile(
                            notification: n,
                            onTap: () => _onTapNotification(n),
                            onMarkRead: () async {
                              await NotificationService.markAsRead(n.id);
                              _load();
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  Future<void> _onTapNotification(NotificationModel n) async {
    await NotificationService.markAsRead(n.id);
    _load();

    if (n.type == 'application_received' &&
        n.relatedApplicationId != null &&
        n.relatedHubId != null) {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ApplicationDetailPage(
            applicationId: n.relatedApplicationId!,
            hubId: int.tryParse(n.relatedHubId!) ?? 0,
          ),
        ),
      );
      _load();
      return;
    }

    // Worker arrived / left area: open hub detail so employer can confirm arrival or complete work.
    if ((n.type == 'worker_arrived' || n.type == 'worker_left_area') &&
        n.relatedHubId != null) {
      final hubId = int.tryParse(n.relatedHubId!);
      if (hubId != null && hubId > 0 && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => HubDetailPage(hubId: hubId),
          ),
        );
        _load();
      }
      return;
    }

    // Work completed (worker): open App Pocket so they see the amount that reflected.
    if (n.type == 'session_completed' && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => const AppPocketScreen(),
        ),
      );
      _load();
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onMarkRead,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    IconData icon;
    Color iconColor;
    switch (notification.type) {
      case 'application_received':
        icon = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case 'application_accepted':
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case 'application_rejected':
        icon = Icons.cancel;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.read ? Colors.grey.shade200 : Colors.blue.shade100,
        ),
      ),
      child: ListTile(
        onTap: () {
          onMarkRead();
          onTap();
        },
        contentPadding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontWeight: notification.read ? FontWeight.w500 : FontWeight.bold,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            notification.body,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 13 : 12,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: notification.type == 'application_received'
            ? Icon(Icons.chevron_right, color: Colors.grey.shade600)
            : null,
      ),
    );
  }
}

class ApplicationDetailPage extends StatefulWidget {
  const ApplicationDetailPage({super.key, required this.applicationId, required this.hubId});

  final String applicationId;
  final int hubId;

  @override
  State<ApplicationDetailPage> createState() => _ApplicationDetailPageState();
}

class _ApplicationDetailPageState extends State<ApplicationDetailPage> {
  HubApplicationModel? _app;
  JobhubModel? _hub;
  Map<String, dynamic>? _applicantProfile;
  bool _loading = true;
  bool _responding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final app = await ApplicationService.getApplicationById(widget.applicationId);
      final hub = await HubRepository.getJobhubById(widget.hubId);
      Map<String, dynamic>? profile;
      if (app != null) {
        profile = DummyHubData.getDummyUser(app.applicantUserId);
      }
      if (mounted) {
        setState(() {
          _app = app;
          _hub = hub;
          _applicantProfile = profile;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _respond(String status, {String? declineReason}) async {
    if (_app == null || _responding) return;
    if (status == 'rejected' && (declineReason == null || declineReason.trim().isEmpty)) return;
    final userId = context.read<AuthProvider>().currentUser?.id;
    setState(() => _responding = true);
    try {
      await ApplicationService.respondToApplication(widget.applicationId, status, declineReason: declineReason?.trim());
      if (userId != null) {
        await NotificationService.notifyApplicationResponded(
          toUserId: _app!.applicantUserId,
          type: status == 'accepted' ? 'application_accepted' : 'application_rejected',
          hubTitle: _hub?.title ?? 'Hub',
          applicationId: widget.applicationId,
          declineReason: declineReason?.trim(),
        );
      }
      if (status == 'accepted' && _hub != null) {
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
          jobStatus: 2, // In progress
          registerId: _hub!.registerId,
          dateCreated: _hub!.dateCreated,
          dateAccepted: DateTime.now(),
        ));
        await WorkSessionService.createSessionWhenAccepted(
          hubId: widget.hubId,
          applicationId: widget.applicationId,
          workerId: _app!.applicantUserId,
          employerId: _hub!.registerId?.toString() ?? userId!,
        );
        await NotificationService.removeApplicationReceivedForApplication(widget.applicationId, userId!);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == 'accepted' ? 'Application accepted.' : 'Application declined.'),
            backgroundColor: status == 'accepted' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _responding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeclineDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Decline application', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provide a reason so the applicant can improve their profile before applying again. They will see this reason in their notification.',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason for declining (required)',
                    hintText: 'e.g. Missing documents, profile incomplete, experience does not match...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  minLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey.shade700)),
            ),
            FilledButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Please provide a reason for declining.')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _respond('rejected', declineReason: reason);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Decline', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Application',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _app == null
              ? const Center(child: Text('Application not found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _hub?.title ?? 'Hub',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProfileCard(isTablet),
                      if (_app!.message != null && _app!.message!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Message',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _app!.message!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_app!.isPending) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _responding ? null : () => _showDeclineDialog(context),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'Decline',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _responding
                                    ? null
                                    : () => _respond('accepted'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  'Accept',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Chip(
                                label: Text(
                                  _app!.isAccepted ? 'Accepted' : 'Declined',
                                  style: GoogleFonts.poppins(
                                    color: _app!.isAccepted ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: _app!.isAccepted
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                              ),
                              if (_app!.isRejected && _app!.declineReason != null && _app!.declineReason!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Reason provided by employer',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange.shade900,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _app!.declineReason!,
                                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.orange.shade900),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileCard(bool isTablet) {
    final name = _applicantProfile != null
        ? '${_applicantProfile!['name'] ?? ''} ${_applicantProfile!['surname'] ?? ''}'.trim()
        : 'Applicant';
    final email = _applicantProfile?['email'] ?? '—';
    final city = _applicantProfile?['city'] ?? '—';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Applicant profile & documents',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: isTablet ? 32 : 28,
                  backgroundColor: const Color(0xFF2C2C2C),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isNotEmpty ? name : 'Unknown',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        'City: $city',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Documents (e.g. ID, resume) can be viewed or uploaded when connected to the backend.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
