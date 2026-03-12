import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/work_session_model.dart';
import '../model/jobhub_model.dart';
import '../services/work_session_service.dart';
import '../services/hub_repository.dart';
import '../services/location_tracking_service.dart';
import '../services/payment_proof_service.dart';
import '../hubs/hub_detail_page.dart';
import '../widgets/rate_user_dialog.dart';
import '../model/payment_proof_model.dart';
import '../utils/success_snackbar.dart';

/// Worker view: active session with location check (50m) and payment confirmation.
class ActiveWorkSessionScreen extends StatefulWidget {
  const ActiveWorkSessionScreen({super.key, required this.session});

  static String routePath = '/active-work-session';
  final WorkSessionModel session;

  @override
  State<ActiveWorkSessionScreen> createState() => _ActiveWorkSessionScreenState();
}

class _ActiveWorkSessionScreenState extends State<ActiveWorkSessionScreen> {
  JobhubModel? _hub;
  bool _loading = true;
  double? _distanceMeters;
  bool _arrivalReported = false;
  Timer? _locationTimer;
  PaymentProofModel? _paymentProof;
  bool _confirmingPayment = false;
  String _clientProofText = '';
  bool _proceedingWithoutLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _startLocationPolling();
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final hub = await HubRepository.getJobhubById(widget.session.hubId);
      final proof = await PaymentProofService.getBySession(widget.session.id);
      if (mounted) {
        setState(() {
          _hub = hub;
          _loading = false;
          _paymentProof = proof;
          _arrivalReported = widget.session.workerArrivedAt != null;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startLocationPolling() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkLocation();
    });
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    if (_hub == null || _arrivalReported) return;
    final hubLat = double.tryParse(_hub!.latitude);
    final hubLng = double.tryParse(_hub!.longitude);
    if (hubLat == null || hubLng == null) return;
    final dist = await LocationTrackingService.getDistanceToHub(hubLat: hubLat, hubLng: hubLng);
    if (!mounted) return;
    setState(() => _distanceMeters = dist);
    if (dist != null && dist <= LocationTrackingService.workRadiusMeters && !_arrivalReported) {
      final pos = await LocationTrackingService.getCurrentPosition();
      if (pos != null && mounted) {
        await WorkSessionService.reportWorkerArrived(widget.session.id, pos.latitude, pos.longitude);
        setState(() => _arrivalReported = true);
      }
    }
    if (dist != null && dist > LocationTrackingService.workRadiusMeters && widget.session.isInProgress && widget.session.employerConfirmedArrivalAt != null) {
      await WorkSessionService.reportWorkerLeftArea(widget.session.id);
    }
  }

  /// Fallback when location is not available: worker can mark "at site" and proceed.
  Future<void> _proceedWithoutLocation() async {
    if (_hub == null || _arrivalReported || _proceedingWithoutLocation) return;
    final hubLat = double.tryParse(_hub!.latitude);
    final hubLng = double.tryParse(_hub!.longitude);
    if (hubLat == null || hubLng == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job address could not be used. Try again later.')));
      return;
    }
    setState(() => _proceedingWithoutLocation = true);
    try {
      await WorkSessionService.reportWorkerArrived(widget.session.id, hubLat, hubLng);
      if (mounted) {
        setState(() {
          _arrivalReported = true;
          _proceedingWithoutLocation = false;
        });
        showSuccessSnackBar(context, 'Arrival reported. Employer will be notified to confirm.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _proceedingWithoutLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _confirmPayment() async {
    if (_clientProofText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your payment confirmation (e.g. reference or proof).')));
      return;
    }
    setState(() => _confirmingPayment = true);
    try {
      await PaymentProofService.submitClientProof(widget.session.id, _clientProofText.trim());
      if (mounted) {
        final updated = await PaymentProofService.getBySession(widget.session.id);
        setState(() {
          _confirmingPayment = false;
          _paymentProof = updated;
        });
        showSuccessSnackBar(context, 'Payment confirmed. Job added to your history.');
        if (mounted) {
          showRateUserDialog(
            context: context,
            hubId: widget.session.hubId,
            toUserId: widget.session.employerId,
            toUserName: 'Employer',
            role: 'as_worker',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _confirmingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          'Active work',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hub == null
              ? const Center(child: Text('Hub not found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _hub!.title,
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hub!.fullAddress,
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 24),
                      if (!_arrivalReported) ...[
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _distanceMeters != null && _distanceMeters! <= 50 ? Icons.check_circle : Icons.location_on,
                                      color: _distanceMeters != null && _distanceMeters! <= 50 ? Colors.green : Colors.orange,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _distanceMeters != null && _distanceMeters! <= 50
                                          ? 'You are at the job location (within 50m)'
                                          : 'Track your location',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ],
                                ),
                                if (_distanceMeters != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Distance: ${_distanceMeters!.toStringAsFixed(0)}m. ${_distanceMeters! <= 50 ? "Arrival will be reported to the employer." : "Go to the job location to check in."}',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Location not available. If you are at the job site, you can proceed below.',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _proceedingWithoutLocation ? null : _proceedWithoutLocation,
                                    icon: _proceedingWithoutLocation
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.touch_app),
                                    label: Text(
                                      _proceedingWithoutLocation ? 'Reporting...' : "I'm at the site – proceed without location",
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF06C698),
                                      side: const BorderSide(color: Color(0xFF06C698)),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.session.isArrivedWaitingConfirm
                                            ? 'Arrival reported. Waiting for employer to confirm.'
                                            : 'Work in progress.',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                                if (!widget.session.isArrivedWaitingConfirm) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'The employer will mark the job complete when done; you’ll then confirm payment and can rate.',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_paymentProof != null && _paymentProof!.employerSubmitted && !_paymentProof!.clientConfirmed) ...[
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Confirm payment received',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF111111)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Employer submitted: ${_paymentProof!.employerProofDescription ?? "—"}',
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  onChanged: (v) => setState(() => _clientProofText = v),
                                  decoration: const InputDecoration(
                                    hintText: 'Your confirmation (e.g. reference number received)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _confirmingPayment ? null : _confirmPayment,
                                    icon: _confirmingPayment ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check_circle),
                                    label: Text(_confirmingPayment ? 'Submitting...' : 'Confirm payment received', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06C698), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_paymentProof != null && _paymentProof!.isComplete) ...[
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green.shade700, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Payment confirmed. Job completed. You can rate the employer from hub details.',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(context, MaterialPageRoute<void>(builder: (context) => HubDetailPage(hubId: widget.session.hubId)));
                          _load();
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('View hub details'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
