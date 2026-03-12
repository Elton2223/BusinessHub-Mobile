import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/rating_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Dialog to rate the other party (worker or employer) after a hub is completed.
/// [onRated] Optional callback called after a rating is successfully submitted (e.g. to pop the hub detail page).
Future<void> showRateUserDialog({
  required BuildContext context,
  required int hubId,
  required String toUserId,
  required String toUserName,
  required String role, // 'as_employer' | 'as_worker'
  VoidCallback? onRated,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _RateUserDialog(
      hubId: hubId,
      toUserId: toUserId,
      toUserName: toUserName,
      role: role,
      onRated: onRated,
    ),
  );
}

class _RateUserDialog extends StatefulWidget {
  const _RateUserDialog({
    required this.hubId,
    required this.toUserId,
    required this.toUserName,
    required this.role,
    this.onRated,
  });

  final int hubId;
  final String toUserId;
  final String toUserName;
  final String role;
  final VoidCallback? onRated;

  @override
  State<_RateUserDialog> createState() => _RateUserDialogState();
}

class _RateUserDialogState extends State<_RateUserDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user?.id == null) return;

    setState(() => _submitting = true);
    try {
      await RatingService.submitRating(
        hubId: widget.hubId,
        fromUserId: user!.id!,
        toUserId: widget.toUserId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        role: widget.role,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.role == 'as_employer' ? 'Rate the worker' : 'Rate the employer';
    return AlertDialog(
      title: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How was your experience with ${widget.toUserName}?',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  return IconButton(
                    icon: Icon(
                      _rating >= star ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () => setState(() => _rating = star),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment (optional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
        FilledButton(
          onPressed: _submitting || _rating < 1 ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Submit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
