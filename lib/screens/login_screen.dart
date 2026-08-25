import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

enum _AuthMode { signIn, signUp, confirmSignUp }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  _AuthMode _mode = _AuthMode.signIn;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUserLoggedIn());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _checkUserLoggedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on Exception catch (e) {
      safePrint('Error checking session: $e');
    }
  }

  Future<void> _handlePrimaryAction() async {
    if (_isBusy || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isBusy = true);

    try {
      switch (_mode) {
        case _AuthMode.signIn:
          await _signIn();
          break;
        case _AuthMode.signUp:
          await _signUp();
          break;
        case _AuthMode.confirmSignUp:
          await _confirmSignUp();
          break;
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } on Exception catch (e) {
      safePrint('Authentication error: $e');
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _signIn() async {
    final result = await Amplify.Auth.signIn(
      username: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (result.isSignedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
      return;
    }

    if (result.nextStep.signInStep == AuthSignInStep.confirmSignInWithNewPassword) {
      await _showNewPasswordDialog();
      return;
    }

    _showMessage('Additional sign-in step required: ${result.nextStep.signInStep.name}');
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final userAttributes = <AuthUserAttributeKey, String>{
      AuthUserAttributeKey.email: email,
    };

    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      userAttributes[AuthUserAttributeKey.name] = name;
    }

    final result = await Amplify.Auth.signUp(
      username: email,
      password: _passwordController.text,
      options: SignUpOptions(userAttributes: userAttributes),
    );

    if (result.isSignUpComplete) {
      _showMessage('Account created. You can sign in now.');
      _switchMode(_AuthMode.signIn);
    } else {
      _showMessage('Check your email for the confirmation code.');
      _switchMode(_AuthMode.confirmSignUp, keepPassword: true);
    }
  }

  Future<void> _confirmSignUp() async {
    final result = await Amplify.Auth.confirmSignUp(
      username: _emailController.text.trim(),
      confirmationCode: _codeController.text.trim(),
    );

    if (!result.isSignUpComplete) {
      _showMessage('Confirmation is not complete yet. Please try the code again.');
      return;
    }

    _showMessage('Email confirmed. Signing you in...');
    await _signIn();
  }

  Future<void> _resendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email first.');
      return;
    }

    setState(() => _isBusy = true);
    try {
      await Amplify.Auth.resendSignUpCode(username: email);
      _showMessage('A new confirmation code has been sent.');
      _switchMode(_AuthMode.confirmSignUp, keepPassword: true);
    } on AuthException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter your email first.');
      return;
    }

    setState(() => _isBusy = true);
    try {
      await Amplify.Auth.resetPassword(username: email);
      _showMessage('Password reset instructions have been sent to your email.');
    } on AuthException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _showNewPasswordDialog() async {
    final newPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New password required'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Set a permanent password to finish your first sign-in.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  validator: _validatePassword,
                  decoration: const InputDecoration(
                    labelText: 'New password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(dialogFormKey.currentState?.validate() ?? false)) {
                  return;
                }

                try {
                  final confirmResult = await Amplify.Auth.confirmSignIn(
                    confirmationValue: newPasswordController.text,
                  );
                  if (!mounted) {
                    return;
                  }

                  Navigator.pop(dialogContext);
                  if (confirmResult.isSignedIn) {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  }
                } on AuthException catch (e) {
                  _showMessage(e.message);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    newPasswordController.dispose();
  }

  void _switchMode(_AuthMode mode, {bool keepPassword = false}) {
    setState(() {
      _mode = mode;
      _codeController.clear();
      if (!keepPassword) {
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSignIn = _mode == _AuthMode.signIn;
    final isSignUp = _mode == _AuthMode.signUp;
    final isConfirming = _mode == _AuthMode.confirmSignUp;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(colorScheme),
                    const SizedBox(height: 32),
                    SegmentedButton<_AuthMode>(
                      segments: const [
                        ButtonSegment(
                          value: _AuthMode.signIn,
                          icon: Icon(Icons.login),
                          label: Text('Login'),
                        ),
                        ButtonSegment(
                          value: _AuthMode.signUp,
                          icon: Icon(Icons.person_add_alt_1),
                          label: Text('Sign up'),
                        ),
                      ],
                      selected: {isConfirming ? _AuthMode.signUp : _mode},
                      onSelectionChanged: _isBusy
                          ? null
                          : (selection) => _switchMode(selection.first),
                    ),
                    const SizedBox(height: 28),
                    if (isConfirming) _buildConfirmIntro(colorScheme),
                    if (isSignUp)
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full name',
                        hint: 'Farm operator',
                        icon: Icons.badge_outlined,
                        colorScheme: colorScheme,
                        textInputAction: TextInputAction.next,
                      ),
                    if (isSignUp) const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'name@farm.com',
                      icon: Icons.mail_outline,
                      colorScheme: colorScheme,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    if (isConfirming)
                      _buildTextField(
                        controller: _codeController,
                        label: 'Confirmation code',
                        hint: '123456',
                        icon: Icons.pin_outlined,
                        colorScheme: colorScheme,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: _validateCode,
                      )
                    else ...[
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        colorScheme: colorScheme,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                        textInputAction: isSignUp ? TextInputAction.next : TextInputAction.done,
                        validator: _validatePassword,
                      ),
                      if (isSignUp) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm password',
                          hint: 'Re-enter your password',
                          icon: Icons.lock_reset,
                          colorScheme: colorScheme,
                          isPassword: true,
                          isPasswordVisible: _isConfirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                          },
                          textInputAction: TextInputAction.done,
                          validator: _validateConfirmPassword,
                        ),
                      ],
                    ],
                    const SizedBox(height: 10),
                    if (isSignIn)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isBusy ? null : _resetPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    if (isConfirming)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _isBusy ? null : _resendCode,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Resend code'),
                        ),
                      ),
                    const SizedBox(height: 18),
                    _buildPrimaryButton(colorScheme),
                    const SizedBox(height: 24),
                    _buildModeFooter(colorScheme),
                    if (isSignIn) ...[
                      const SizedBox(height: 32),
                      _buildDivider(colorScheme),
                      const SizedBox(height: 24),
                      _buildGoogleButton(colorScheme),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          'Hydrotek Farm',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _mode == _AuthMode.signIn
              ? 'Precision growth for the modern era'
              : 'Create your operator account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmIntro(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'Enter the confirmation code sent to your email to activate your account.',
        style: TextStyle(color: colorScheme.onSurfaceVariant, height: 1.4),
      ),
    );
  }

  Widget _buildPrimaryButton(ColorScheme colorScheme) {
    return FilledButton.icon(
      onPressed: _isBusy ? null : _handlePrimaryAction,
      icon: _isBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(_mode == _AuthMode.signIn ? Icons.login : Icons.arrow_forward),
      label: Text(_primaryButtonLabel),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildModeFooter(ColorScheme colorScheme) {
    final prompt = _mode == _AuthMode.signIn ? 'New user?' : 'Already have an account?';
    final action = _mode == _AuthMode.signIn ? 'Create account' : 'Login';

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$prompt ',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: _isBusy
              ? null
              : () => _switchMode(_mode == _AuthMode.signIn ? _AuthMode.signUp : _AuthMode.signIn),
          child: Text(action),
        ),
      ],
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant.withOpacity(0.35))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant.withOpacity(0.35))),
      ],
    );
  }

  Widget _buildGoogleButton(ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: _isBusy ? null : _signInWithGoogle,
      icon: const Icon(Icons.g_mobiledata, size: 28),
      label: const Text('Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isBusy = true);
    try {
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.google,
        options: const SignInWithWebUIOptions(
          pluginOptions: CognitoSignInWithWebUIPluginOptions(
            isPreferPrivateSession: true,
          ),
        ),
      );
      if (result.isSignedIn && mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ColorScheme colorScheme,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    final fillColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerHighest
        : const Color(0xFFE5E9E5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: !_isBusy,
          obscureText: isPassword && !isPasswordVisible,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    tooltip: isPasswordVisible ? 'Hide password' : 'Show password',
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: onVisibilityToggle,
                  )
                : null,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.65)),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.45), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ],
    );
  }

  String get _primaryButtonLabel {
    switch (_mode) {
      case _AuthMode.signIn:
        return 'Login';
      case _AuthMode.signUp:
        return 'Create account';
      case _AuthMode.confirmSignUp:
        return 'Confirm account';
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (_mode == _AuthMode.confirmSignUp) {
      return null;
    }
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (_mode == _AuthMode.signUp && password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_mode != _AuthMode.signUp) {
      return null;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateCode(String? value) {
    if (_mode != _AuthMode.confirmSignUp) {
      return null;
    }
    if ((value?.trim() ?? '').isEmpty) {
      return 'Confirmation code is required';
    }
    return null;
  }
}
