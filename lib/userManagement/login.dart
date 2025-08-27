import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/auth_manager.dart';
import '../providers/auth_provider.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primaryBackground,
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
          // Logo Container
          Container(
            width: isTablet ? 150 : 120,
            height: isTablet ? 150 : 120,
            margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 32 : 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isTablet ? 40 : 30),
              color: FlutterFlowTheme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: FlutterFlowTheme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.business_center,
                size: isTablet ? 70 : 50,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Text(
              'Welcome Back',
              style: FlutterFlowTheme.of(context).title1.copyWith(
                color: FlutterFlowTheme.of(context).primaryText,
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
                'Sign in to continue to BusinessHub',
                style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
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
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _model.textController1Validator,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, isTablet ? 32 : 24),
                      child: _buildPasswordField(
                        controller: _model.textController2,
                        focusNode: _model.textFieldFocusNode2,
                        label: 'Password',
                        hint: 'Enter your password',
                        validator: _model.textController2Validator,
                        isVisible: _model.passwordVisibility,
                        onVisibilityChanged: (value) {
                          setState(() {
                            _model.passwordVisibility = value;
                          });
                        },
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            if (authProvider.errorMessage != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            FFButtonWidget(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () async {
                                      if (_model.formKey.currentState?.validate() ?? false) {
                                        final success = await authProvider.login(
                                          email: _model.textController1!.text,
                                          password: _model.textController2!.text,
                                        );
                                        
                                        if (success) {
                                          // Sign in with AuthManager for compatibility
                                          AuthManager.signIn(_model.textController1!.text);
                                          // Navigate to home page
                                          Navigator.pushNamed(context, '/home');
                                        }
                                      }
                                    },
                              text: authProvider.isLoading ? 'Signing In...' : 'Sign In',
                                                             options: FFButtonOptions(
                                 width: double.infinity,
                                 height: isTablet ? 60 : 50,
                                 color: authProvider.isLoading ? Colors.grey : FlutterFlowTheme.of(context).primaryColor,
                                 textColor: Colors.white,
                                 borderColor: Colors.transparent,
                                 borderWidth: 1,
                                 borderRadius: isTablet ? 30 : 25,
                               ),
                            ),
                          ],
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, isTablet ? 32 : 20, 0, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                                                         TextSpan(
                               text: 'Don\'t have an account? ',
                               style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                 color: FlutterFlowTheme.of(context).secondaryText,
                                 fontSize: isTablet ? 16 : 14,
                               ),
                             ),
                             TextSpan(
                               text: 'Sign Up',
                               style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                 color: FlutterFlowTheme.of(context).primaryColor,
                                 fontSize: isTablet ? 16 : 14,
                                 fontWeight: FontWeight.bold,
                               ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to register
                                  Navigator.pushNamed(context, '/register');
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
                // Logo ContainerR
                Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 32),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: FlutterFlowTheme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: FlutterFlowTheme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.business_center,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Welcome Back',
                  style: FlutterFlowTheme.of(context).title1.copyWith(
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                  child: Text(
                    'Sign in to continue to BusinessHub',
                    style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right side - Login form
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
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: _model.textController1Validator,
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _model.textController2,
                        focusNode: _model.textFieldFocusNode2,
                        label: 'Password',
                        hint: 'Enter your password',
                        validator: _model.textController2Validator,
                        isVisible: _model.passwordVisibility,
                        onVisibilityChanged: (value) {
                          setState(() {
                            _model.passwordVisibility = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Column(
                            children: [
                              if (authProvider.errorMessage != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              FFButtonWidget(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_model.formKey.currentState?.validate() ?? false) {
                                          final success = await authProvider.login(
                                            email: _model.textController1!.text,
                                            password: _model.textController2!.text,
                                          );
                                          
                                          if (success) {
                                            // Sign in with AuthManager for compatibility
                                            AuthManager.signIn(_model.textController1!.text);
                                            // Navigate to profile page
                                            Navigator.pushReplacementNamed(context, '/profile');
                                          }
                                        }
                                      },
                                text: authProvider.isLoading ? 'Signing In...' : 'Sign In',
                                                                 options: FFButtonOptions(
                                   width: double.infinity,
                                   height: 50,
                                   color: authProvider.isLoading ? Colors.grey : FlutterFlowTheme.of(context).primaryColor,
                                   textColor: Colors.white,
                                   borderColor: Colors.transparent,
                                   borderWidth: 1,
                                   borderRadius: 25,
                                 ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                                                         TextSpan(
                               text: 'Don\'t have an account? ',
                               style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                 color: FlutterFlowTheme.of(context).secondaryText,
                                 fontSize: 14,
                               ),
                             ),
                             TextSpan(
                               text: 'Sign Up',
                               style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                 color: FlutterFlowTheme.of(context).primaryColor,
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                               ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to register
                                  Navigator.pushNamed(context, '/register');
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
        color: Colors.grey[100],
        border: Border.all(
          color: FlutterFlowTheme.of(context).lineColor,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: false,
        keyboardType: keyboardType,
        style: TextStyle(
          color: FlutterFlowTheme.of(context).primaryText,
          fontSize: isTablet ? 18 : 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: isTablet ? 16 : 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsetsDirectional.fromSTEB(
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
          ),
          alignLabelWithHint: true,
        ),
        textAlign: TextAlign.center,
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
        color: Colors.grey[100],
        border: Border.all(
          color: FlutterFlowTheme.of(context).lineColor,
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        style: TextStyle(
          color: FlutterFlowTheme.of(context).primaryText,
          fontSize: isTablet ? 18 : 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: isTablet ? 16 : 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.7),
            fontSize: isTablet ? 16 : 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsetsDirectional.fromSTEB(
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
            isTablet ? 20 : 16,
          ),
          alignLabelWithHint: true,
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: isTablet ? 24 : 20,
            ),
            onPressed: () => onVisibilityChanged(!isVisible),
          ),
        ),
        textAlign: TextAlign.center,
        validator: validator != null ? (value) => validator(context, value) : null,
      ),
    );
  }
}
