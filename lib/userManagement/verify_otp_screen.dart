import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/neumorphic_theme.dart';
import '../utils/responsive_utils.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({Key? key}) : super(key: key);

  static String routeName = 'VerifyOtp';
  static String routePath = '/verify-otp';

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen>
    with ResponsiveWidgetMixin {
  final _otpController = TextEditingController();
  late String _email;
  late String _otp;
  bool _didNavigate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _email = (args['email']?.toString() ?? '').trim();
      _otp = (args['otp']?.toString() ?? '').trim();
    } else {
      _email = '';
      _otp = '';
    }
  }

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_didNavigate) return;
    // Use only digits (in case keyboard adds spaces or formatting)
    final text = _otpController.text.replaceAll(RegExp(r'\D'), '');
    if (text.length >= 6) {
      final enteredOtp = text.length > 6 ? text.substring(0, 6) : text;
      if (enteredOtp == _otp && mounted) {
        _didNavigate = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/reset-password',
              arguments: {'email': _email},
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final isTablet = responsive.isTablet;

    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Enter OTP',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 48 : 24,
                vertical: isTablet ? 40 : 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Enter the 6-digit OTP sent to $_email',
                      style: GoogleFonts.poppins(
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: isTablet ? 16 : 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 32 : 24),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        hintText: '000000',
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 18 : 14,
                        ),
                        labelStyle: GoogleFonts.poppins(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: isTablet ? 16 : 14,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.6),
                          fontSize: isTablet ? 20 : 18,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
