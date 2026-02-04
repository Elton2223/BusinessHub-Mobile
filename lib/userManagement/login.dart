import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/neumorphic_theme.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_utils.dart';
import '../home_page.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'Login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with ResponsiveWidgetMixin {
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
    final responsive = context.responsive;
    final isLandscape = responsive.isLandscape;
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: NeumorphicTheme.baseColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: NeumorphicTheme.baseColor,
          ),
          child: responsive.isTablet && isLandscape
              ? _buildLandscapeLayout()
              : _buildPortraitLayout(),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    final responsive = context.responsive;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.isTablet ? 60 : 20,
        vertical: responsive.isTablet ? 40 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Logo Container
          Container(
            width: responsive.isTablet ? 150 : 120,
            height: responsive.isTablet ? 150 : 120,
            margin: EdgeInsetsDirectional.fromSTEB(0, 0, 0, responsive.isTablet ? 32 : 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(responsive.isTablet ? 40 : 30),
              color: FlutterFlowTheme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF989898),
                  offset: const Offset(24, 24),
                  blurRadius: 47,
                ),
                BoxShadow(
                  color: const Color(0xFFFFFFFF),
                  offset: const Offset(-24, -24),
                  blurRadius: 47,
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
                size: responsive.isTablet ? 70 : 50,
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
                fontSize: responsive.isTablet ? 36 : 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0, responsive.isTablet ? 16 : 12, 0, 0),
              child: Text(
                'Sign in to continue to BusinessHub',
                style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  fontSize: responsive.isTablet ? 18 : 16,
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
                      padding: EdgeInsetsDirectional.fromSTEB(0, responsive.isTablet ? 32 : 20, 0, responsive.isTablet ? 16 : 12),
                      child: _buildTextField(
                        controller: _model.textController1!,
                        focusNode: _model.textFieldFocusNode1!,
                        label: 'Email',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => _model.textController1Validator(context, value),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, responsive.isTablet ? 32 : 24),
                      child: _buildPasswordField(
                        controller: _model.textController2!,
                        focusNode: _model.textFieldFocusNode2!,
                        label: 'Password',
                        hint: 'Enter your password',
                        validator: (value) => _model.textController2Validator(context, value),
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
                            Container(
                              width: double.infinity,
                              height: responsive.isTablet ? 60 : 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(responsive.isTablet ? 30 : 25),
                                color: authProvider.isLoading ? Colors.grey : FlutterFlowTheme.of(context).primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF989898),
                                    offset: const Offset(6, 6),
                                    blurRadius: 12,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFFFFFF),
                                    offset: const Offset(-6, -6),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                                                            child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : () async {
                                  print('🔍 Login button pressed');
                                  print('🔍 Email: ${_model.textController1!.text}');
                                  print('🔍 Password length: ${_model.textController2!.text.length}');
                                  
                                  if (_model.formKey.currentState?.validate() ?? false) {
                                    print('🔍 Form validation passed');
                                    final success = await authProvider.login(
                                      email: _model.textController1!.text,
                                      password: _model.textController2!.text,
                                    );
                                    
                                    print('🔍 Login result: $success');
                                    
                                    if (success) {
                                      print('🔍 Login successful, navigating to home');
                                      print('🔍 Current context: $context');
                                      print('🔍 Navigator: ${Navigator.of(context)}');
                                      
                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Login successful! Redirecting...'),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      
                                      // Try navigation with error handling
                                      try {
                                        print('🔍 Attempting navigation to /home');
                                        Navigator.pushReplacementNamed(context, '/home');
                                        print('🔍 Navigation completed successfully');
                                      } catch (e) {
                                        print('❌ Navigation error: $e');
                                        // Fallback navigation
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const HomePage()),
                                        );
                                      }
                                    } else {
                                      print('🔍 Login failed, error: ${authProvider.errorMessage}');
                                      // Show error message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Login failed: ${authProvider.errorMessage}'),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } else {
                                    print('🔍 Form validation failed');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  minimumSize: Size(
                                    responsive.isTablet ? 200 : 160,
                                    responsive.isTablet ? 60 : 50,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(responsive.isTablet ? 30 : 25),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        width: responsive.isTablet ? 24 : 20,
                                        height: responsive.isTablet ? 24 : 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: FlutterFlowTheme.of(context).title1.copyWith(
                                          color: Colors.white,
                                          fontSize: responsive.isTablet ? 18 : 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, responsive.isTablet ? 24 : 16, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Don\'t have an account? ',
                                    style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                      color: FlutterFlowTheme.of(context).secondaryText,
                                      fontSize: responsive.isTablet ? 16 : 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      Navigator.pushNamed(context, '/register');
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                        color: FlutterFlowTheme.of(context).primaryColor,
                                        fontSize: responsive.isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
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
    final responsive = context.responsive;
    
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(responsive.isTablet ? 60 : 40),
                bottomRight: Radius.circular(responsive.isTablet ? 60 : 40),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_center,
                    size: responsive.isTablet ? 120 : 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: responsive.isTablet ? 32 : 24),
                  Text(
                    'BusinessHub',
                    style: FlutterFlowTheme.of(context).title1.copyWith(
                      color: Colors.white,
                      fontSize: responsive.isTablet ? 48 : 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: responsive.isTablet ? 16 : 12),
                  Text(
                    'Your Business, Our Priority',
                    style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: responsive.isTablet ? 20 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(responsive.isTablet ? 60 : 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back',
                  style: FlutterFlowTheme.of(context).title1.copyWith(
                    color: FlutterFlowTheme.of(context).primaryText,
                    fontSize: responsive.isTablet ? 36 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: responsive.isTablet ? 16 : 12),
                Text(
                  'Sign in to continue to BusinessHub',
                  style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: responsive.isTablet ? 18 : 16,
                  ),
                ),
                SizedBox(height: responsive.isTablet ? 40 : 32),
                _buildTextField(
                  controller: _model.textController1!,
                  focusNode: _model.textFieldFocusNode1!,
                  label: 'Email',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _model.textController1Validator(context, value),
                ),
                SizedBox(height: responsive.isTablet ? 24 : 16),
                _buildPasswordField(
                  controller: _model.textController2!,
                  focusNode: _model.textFieldFocusNode2!,
                  label: 'Password',
                  hint: 'Enter your password',
                  validator: (value) => _model.textController2Validator(context, value),
                  isVisible: _model.passwordVisibility,
                  onVisibilityChanged: (value) {
                    setState(() {
                      _model.passwordVisibility = value;
                    });
                  },
                ),
                SizedBox(height: responsive.isTablet ? 32 : 24),
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
                        SizedBox(
                          width: double.infinity,
                          height: responsive.isTablet ? 60 : 50,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading ? null : () async {
                              print('🔍 Landscape login button pressed');
                              print('🔍 Email: ${_model.textController1!.text}');
                              print('🔍 Password length: ${_model.textController2!.text.length}');
                              
                              if (_model.formKey.currentState?.validate() ?? false) {
                                print('🔍 Landscape form validation passed');
                                final success = await authProvider.login(
                                  email: _model.textController1!.text,
                                  password: _model.textController2!.text,
                                );
                                
                                print('🔍 Landscape login result: $success');
                                
                                if (success) {
                                  print('🔍 Landscape login successful, navigating to home');
                                  print('🔍 Current context: $context');
                                  print('🔍 Navigator: ${Navigator.of(context)}');
                                  
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Login successful! Redirecting...'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  // Try navigation with error handling
                                  try {
                                    print('🔍 Attempting landscape navigation to /home');
                                    Navigator.pushReplacementNamed(context, '/home');
                                    print('🔍 Landscape navigation completed successfully');
                                  } catch (e) {
                                    print('❌ Landscape navigation error: $e');
                                    // Fallback navigation
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomePage()),
                                    );
                                  }
                                } else {
                                  print('🔍 Landscape login failed, error: ${authProvider.errorMessage}');
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Login failed: ${authProvider.errorMessage}'),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }
                              } else {
                                print('🔍 Landscape form validation failed');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FlutterFlowTheme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(responsive.isTablet ? 30 : 25),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? SizedBox(
                                    width: responsive.isTablet ? 24 : 20,
                                    height: responsive.isTablet ? 24 : 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Sign In',
                                    style: FlutterFlowTheme.of(context).title1.copyWith(
                                      color: Colors.white,
                                      fontSize: responsive.isTablet ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: responsive.isTablet ? 24 : 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account? ',
                              style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                color: FlutterFlowTheme.of(context).secondaryText,
                                fontSize: responsive.isTablet ? 16 : 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                'Sign Up',
                                style: FlutterFlowTheme.of(context).bodyText1.copyWith(
                                  color: FlutterFlowTheme.of(context).primaryColor,
                                  fontSize: responsive.isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final responsive = context.responsive;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF989898),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFFFFFFF),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(responsive.isTablet ? 20 : 16),
          labelStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: responsive.isTablet ? 16 : 14,
          ),
          hintStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.5),
            fontSize: responsive.isTablet ? 16 : 14,
          ),
        ),
        style: TextStyle(
          color: FlutterFlowTheme.of(context).primaryText,
          fontSize: responsive.isTablet ? 16 : 14,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required String? Function(String?)? validator,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    final responsive = context.responsive;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF989898),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFFFFFFF),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !isVisible,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(responsive.isTablet ? 20 : 16),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: responsive.isTablet ? 24 : 20,
            ),
            onPressed: () => onVisibilityChanged(!isVisible),
          ),
          labelStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: responsive.isTablet ? 16 : 14,
          ),
          hintStyle: TextStyle(
            color: FlutterFlowTheme.of(context).secondaryText.withOpacity(0.5),
            fontSize: responsive.isTablet ? 16 : 14,
          ),
        ),
        style: TextStyle(
          color: FlutterFlowTheme.of(context).primaryText,
          fontSize: responsive.isTablet ? 16 : 14,
        ),
      ),
    );
  }
}
