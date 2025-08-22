import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/auth_manager.dart';
import '../../services/auth_service.dart';
import 'register_model.dart';
export 'register_model.dart';

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  static String routeName = 'Register';
  static String routePath = '/register';

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  late RegisterModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RegisterModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
    _model.textController5 ??= TextEditingController();
    _model.textFieldFocusNode5 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Handle registration with API
  Future<void> _handleRegister() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        },
      );

             // Call register API
       final result = await AuthService.register(
         email: _model.textController3!.text.trim(),
         password: _model.textController5!.text,
         name: _model.textController1!.text.trim(),
         surname: _model.textController2!.text.trim(),
         phone: _model.textController4!.text.trim().isNotEmpty 
           ? _model.textController4!.text.trim() 
           : null,
       );

      // Hide loading indicator
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please check your email for verification.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login page
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
          ),
          child: isTablet && isLandscape
              ? _buildLandscapeLayout()
              : _buildPortraitLayout(),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 60 : 20,
        vertical: isTablet ? 40 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Glassmorphism Logo
          Container(
            width: isTablet ? 150 : 120,
            height: isTablet ? 150 : 120,
            margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 32 : 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.business_center,
                      size: isTablet ? 70 : 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Text(
              'Create Account',
              style: FlutterFlowTheme.of(context).title1.copyWith(
                color: Colors.white,
                fontSize: isTablet ? 36 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, isTablet ? 16 : 12, 0, 0),
              child: Text(
                'Join BusinessHub and grow your business',
                style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _model.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                                         Padding(
                       padding: EdgeInsetsDirectional.fromSTEB(0, isTablet ? 32 : 20, 0, isTablet ? 16 : 12),
                       child: _buildTextField(
                         controller: _model.textController1,
                         focusNode: _model.textFieldFocusNode1,
                         label: 'Name',
                         hint: 'Enter your name',
                         validator: _model.textController1Validator,
                       ),
                     ),
                     Padding(
                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 16 : 12),
                       child: _buildTextField(
                         controller: _model.textController2,
                         focusNode: _model.textFieldFocusNode2,
                         label: 'Surname',
                         hint: 'Enter your surname',
                         validator: _model.textController2Validator,
                       ),
                     ),
                     Padding(
                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 16 : 12),
                       child: _buildTextField(
                         controller: _model.textController3,
                         focusNode: _model.textFieldFocusNode3,
                         label: 'Email',
                         hint: 'Enter your email',
                         keyboardType: TextInputType.emailAddress,
                         validator: _model.textController3Validator,
                       ),
                     ),
                     Padding(
                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 16 : 12),
                       child: _buildTextField(
                         controller: _model.textController4,
                         focusNode: _model.textFieldFocusNode4,
                         label: 'Phone Number',
                         hint: 'Enter your phone number',
                         keyboardType: TextInputType.phone,
                         validator: _model.textController4Validator,
                       ),
                     ),
                     Padding(
                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 16 : 12),
                       child: _buildPasswordField(
                         controller: _model.textController5,
                         focusNode: _model.textFieldFocusNode5,
                         label: 'Password',
                         hint: 'Enter your password',
                         validator: _model.textController5Validator,
                         isVisible: _model.passwordVisibility1,
                         onVisibilityChanged: (value) {
                           setState(() {
                             _model.passwordVisibility1 = value;
                           });
                         },
                       ),
                     ),
                    FFButtonWidget(
                      onPressed: () async {
                        if (_model.formKey.currentState?.validate() ?? false) {
                          _handleRegister();
                        }
                      },
                      text: 'Create Account',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: isTablet ? 60 : 50,
                        color: Colors.white,
                        textColor: const Color(0xFF667eea),
                        borderColor: Colors.transparent,
                        borderWidth: 1,
                        borderRadius: isTablet ? 30 : 25,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, isTablet ? 32 : 20, 0, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isTablet ? 16 : 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                color: Colors.white,
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to login
                                  Navigator.pushNamed(context, '/login');
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    final screenSize = MediaQuery.of(context).size;
    
    return Row(
      children: [
        // Left side - Logo and branding
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glassmorphism Logo
                Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.business_center,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  'Create Account',
                  style: FlutterFlowTheme.of(context).title1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                  child: Text(
                    'Join BusinessHub and grow your business',
                    style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Register form
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _model.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                                             _buildTextField(
                         controller: _model.textController1,
                         focusNode: _model.textFieldFocusNode1,
                         label: 'Name',
                         hint: 'Enter your name',
                         validator: _model.textController1Validator,
                       ),
                       const SizedBox(height: 16),
                       _buildTextField(
                         controller: _model.textController2,
                         focusNode: _model.textFieldFocusNode2,
                         label: 'Surname',
                         hint: 'Enter your surname',
                         validator: _model.textController2Validator,
                       ),
                       const SizedBox(height: 16),
                       _buildTextField(
                         controller: _model.textController3,
                         focusNode: _model.textFieldFocusNode3,
                         label: 'Email',
                         hint: 'Enter your email',
                         keyboardType: TextInputType.emailAddress,
                         validator: _model.textController3Validator,
                       ),
                       const SizedBox(height: 16),
                       _buildTextField(
                         controller: _model.textController4,
                         focusNode: _model.textFieldFocusNode4,
                         label: 'Phone Number',
                         hint: 'Enter your phone number',
                         keyboardType: TextInputType.phone,
                         validator: _model.textController4Validator,
                       ),
                       const SizedBox(height: 16),
                       _buildPasswordField(
                         controller: _model.textController5,
                         focusNode: _model.textFieldFocusNode5,
                         label: 'Password',
                         hint: 'Enter your password',
                         validator: _model.textController5Validator,
                         isVisible: _model.passwordVisibility1,
                         onVisibilityChanged: (value) {
                           setState(() {
                             _model.passwordVisibility1 = value;
                           });
                         },
                       ),
                      const SizedBox(height: 30),
                      FFButtonWidget(
                        onPressed: () async {
                          if (_model.formKey.currentState?.validate() ?? false) {
                            // Navigate to verify email
                            Navigator.pushNamed(context, '/verify_email');
                          }
                        },
                        text: 'Create Account',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          color: Colors.white,
                          textColor: const Color(0xFF667eea),
                          borderColor: Colors.transparent,
                          borderWidth: 1,
                          borderRadius: 25,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign In',
                              style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to login
                                  Navigator.pushNamed(context, '/login');
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(BuildContext, String?)? validator,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: false,
        keyboardType: keyboardType,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 18 : 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: isTablet ? 16 : 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsetsDirectional.fromSTEB(
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
          ),
        ),
        validator: validator != null ? (value) => validator(context, value) : null,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String label,
    required String hint,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
    String? Function(BuildContext, String?)? validator,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 18 : 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: isTablet ? 16 : 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsetsDirectional.fromSTEB(
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.white.withOpacity(0.7),
              size: isTablet ? 24 : 20,
            ),
            onPressed: () => onVisibilityChanged(!isVisible),
          ),
        ),
        validator: validator != null ? (value) => validator(context, value) : null,
      ),
    );
  }
}
