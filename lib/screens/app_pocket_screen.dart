import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../model/pocket_transaction_model.dart';
import '../model/bank_detail_model.dart';
import '../providers/auth_provider.dart';
import '../services/pocket_service.dart';

/// App Pocket: balance, transactions, deposit, withdraw to bank.
class AppPocketScreen extends StatefulWidget {
  const AppPocketScreen({super.key});

  static String routePath = '/app-pocket';

  @override
  State<AppPocketScreen> createState() => _AppPocketScreenState();
}

class _AppPocketScreenState extends State<AppPocketScreen> {
  double _balance = 0;
  List<PocketTransactionModel> _transactions = [];
  List<BankDetailModel> _bankDetails = [];
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
        _balance = 0;
        _transactions = [];
        _bankDetails = [];
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        PocketService.getBalance(userId),
        PocketService.getTransactions(userId),
        PocketService.getBankDetails(userId),
      ]);
      if (mounted) {
        setState(() {
          _loading = false;
          _balance = results[0] as double;
          _transactions = results[1] as List<PocketTransactionModel>;
          _bankDetails = results[2] as List<BankDetailModel>;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deposit() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final amountController = TextEditingController();
    final commentController = TextEditingController();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deposit to App Pocket', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add money to your App Pocket. In production this will link to your card or EFT.',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (R)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixText: 'R ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: Text('Deposit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (submitted != true || !mounted) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final note = commentController.text.trim().isEmpty ? null : commentController.text.trim();

    try {
      await PocketService.addDeposit(userId, amount, note ?? 'Deposit to App Pocket');
      if (mounted) {
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('R ${amount.toStringAsFixed(2)} added to your App Pocket.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _withdraw() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    if (_bankDetails.isEmpty) {
      final added = await _showAddBankDetailDialog(userId);
      if (added != true || !mounted) return;
      await _load();
      _bankDetails = await PocketService.getBankDetails(userId);
    }

    if (_bankDetails.isEmpty || !mounted) return;

    BankDetailModel? selectedBank;
    double? withdrawAmount;

    final amountController = TextEditingController();
    var currentSelected = _bankDetails.first;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Withdraw to bank', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available: R ${_balance.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BankDetailModel>(
                    value: currentSelected,
                    decoration: InputDecoration(
                      labelText: 'Bank account',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: _bankDetails
                        .map((b) => DropdownMenuItem(
                              value: b,
                              child: Text(
                                '${b.bankName} •••${b.accountNumber.length >= 4 ? b.accountNumber.substring(b.accountNumber.length - 4) : b.accountNumber}',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDialogState(() => currentSelected = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount (R)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixText: 'R ',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Enter a valid amount'), backgroundColor: Colors.orange),
                    );
                    return;
                  }
                  if (amount > _balance) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Amount exceeds balance'), backgroundColor: Colors.orange),
                    );
                    return;
                  }
                  Navigator.pop(ctx, {'bank': currentSelected, 'amount': amount});
                },
                child: Text('Withdraw', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );

    if (result == null || !mounted) return;

    selectedBank = result['bank'] as BankDetailModel?;
    withdrawAmount = result['amount'] as double?;
    if (selectedBank == null || withdrawAmount == null) return;

    final amount = withdrawAmount;
    final selected = selectedBank;

    try {
      final ok = await PocketService.withdrawToBank(userId, amount, selected.id);
      if (mounted) {
        await _load();
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('R ${amount.toStringAsFixed(2)} withdrawal to ${selected.bankName} is processing.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Withdrawal failed. Check balance.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool?> _showAddBankDetailDialog(String userId) async {
    final accountHolder = TextEditingController();
    final bankName = TextEditingController();
    final accountNumber = TextEditingController();
    final branchCode = TextEditingController();

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add bank account', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: accountHolder,
                decoration: InputDecoration(
                  labelText: 'Account holder name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bankName,
                decoration: InputDecoration(
                  labelText: 'Bank name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: accountNumber,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: branchCode,
                decoration: InputDecoration(
                  labelText: 'Branch code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          FilledButton(
            onPressed: () async {
              if (accountHolder.text.trim().isEmpty ||
                  bankName.text.trim().isEmpty ||
                  accountNumber.text.trim().isEmpty ||
                  branchCode.text.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Fill all fields'), backgroundColor: Colors.orange),
                );
                return;
              }
              await PocketService.saveBankDetail(
                userId: userId,
                accountHolderName: accountHolder.text.trim(),
                bankName: bankName.text.trim(),
                accountNumber: accountNumber.text.trim(),
                branchCode: branchCode.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
          'App Pocket',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance card
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: const Color(0xFF06C698),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 28 : 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available balance',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'R ${_balance.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: isTablet ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _deposit,
                                    icon: const Icon(Icons.add, size: 20, color: Colors.white),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Deposit',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _balance > 0 ? _withdraw : null,
                                    icon: const Icon(Icons.account_balance, size: 20),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Withdraw',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF06C698),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bank details link
                    if (_bankDetails.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saved bank account${_bankDetails.length > 1 ? 's' : ''}',
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                            ),
                            TextButton(
                              onPressed: () async {
                                final userId = context.read<AuthProvider>().currentUser?.id;
                                if (userId != null) await _showAddBankDetailDialog(userId);
                                if (mounted) await _load();
                              },
                              child: Text('Add another', style: GoogleFonts.poppins(fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                    // Transactions
                    Row(
                      children: [
                        Icon(Icons.history, size: 22, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Recent transactions',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_transactions.isEmpty)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions yet',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Earnings from completed jobs and deposits will appear here.',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final t = _transactions[index];
                          IconData icon;
                          Color amountColor;
                          String typeLabel;
                          switch (t.type) {
                            case 'earning':
                              icon = Icons.work;
                              amountColor = Colors.green.shade700;
                              typeLabel = 'Job earning';
                              break;
                            case 'deposit':
                              icon = Icons.add_circle;
                              amountColor = Colors.green.shade700;
                              typeLabel = 'Deposit';
                              break;
                            case 'withdrawal':
                              icon = Icons.account_balance;
                              amountColor = Colors.orange.shade700;
                              typeLabel = 'Withdrawal';
                              break;
                            default:
                              icon = Icons.receipt;
                              amountColor = Colors.grey;
                              typeLabel = t.type;
                          }
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: amountColor.withOpacity(0.15),
                                child: Icon(icon, color: amountColor, size: 22),
                              ),
                              title: Text(
                                t.description ?? typeLabel,
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                _formatDate(t.createdAt),
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                              ),
                              trailing: Text(
                                '${t.isCredit ? '+' : '-'} R ${t.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: amountColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    return '${d.day}/${d.month}/${d.year}';
  }
}
