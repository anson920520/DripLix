import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_receiver.dart';
import '../services/auth_state.dart';
import '../config/debug_flags.dart';

class SignUpPopup extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onSignIn;

  const SignUpPopup({
    Key? key,
    this.onClose,
    this.onSignIn,
  }) : super(key: key);

  @override
  ConsumerState<SignUpPopup> createState() => _SignUpPopupState();
}

class _SignUpPopupState extends ConsumerState<SignUpPopup> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _genderController = TextEditingController();

  // Track the exact position of the gender field for precise dropdown placement
  final GlobalKey _genderFieldKey = GlobalKey();
  double? _dropdownTop;
  double? _dropdownLeft;

  bool _isListUnfolded = false;
  bool _isGenderDropdownOpen = false;
  bool _agreeTerms = false;
  bool _agreeMarketing = false;
  bool _showTermsPopup = false;

  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    // Validate all fields
    Map<String, String?> errors = {};

    if (_usernameController.text.isEmpty) {
      errors['username'] = 'Username is required';
    }

    if (_emailController.text.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!_emailController.text.contains('@')) {
      errors['email'] = 'Please enter a valid email';
    }

    if (_verificationCodeController.text.isEmpty) {
      errors['verificationCode'] = 'Verification code is required';
    }

    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Password is required';
    } else if (_passwordController.text.length < 6) {
      errors['password'] = 'Password must be at least 6 characters';
    }

    if (_confirmPasswordController.text.isEmpty) {
      errors['confirmPassword'] = 'Please confirm your password';
    } else if (_confirmPasswordController.text != _passwordController.text) {
      errors['confirmPassword'] = 'Passwords do not match';
    }

    if (_genderController.text.isEmpty) {
      errors['gender'] = 'Please select your gender';
    }

    if (!_agreeTerms) {
      errors['terms'] = 'You must agree to Terms & Conditions';
    }

    setState(() {
      _fieldErrors = errors;
    });

    // If no errors, proceed with sign up
    if (errors.isEmpty) {
      const receiver = AuthReceiverService();
      receiver
          .receiveSignUp(
        username: _usernameController.text,
        email: _emailController.text,
        verificationCode: _verificationCodeController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        gender: _genderController.text,
        agreeTerms: _agreeTerms,
        agreeMarketing: _agreeMarketing,
      )
          .then((payload) {
        // Mark app as logged in upon successful sign-up
        ref.read(authProvider.notifier).setLoggedIn(true);
        // TEST-ONLY: show submitted payload in a dialog for verification.
        // To remove later, delete this block or set DebugFlags.showAuthTestDialogs = false.
        if (DebugFlags.showAuthTestDialogs && mounted) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Sign-Up Data Received (Test)'),
                content: SingleChildScrollView(
                  child: Text(payload.toString()),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      widget.onClose?.call();
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          widget.onClose?.call();
        }
      });
    }
  }

  void _toggleGenderDropdown() {
    try {
      final BuildContext? genderContext = _genderFieldKey.currentContext;
      final RenderObject? stackRenderObject = context.findRenderObject();
      if (genderContext != null && stackRenderObject is RenderBox) {
        final RenderBox genderBox =
            genderContext.findRenderObject() as RenderBox;
        // Get the gender field's top-left in global coordinates
        final Offset genderGlobalTopLeft = genderBox.localToGlobal(Offset.zero);
        // Convert to the Stack's local coordinates
        final Offset genderTopLeftInStack =
            stackRenderObject.globalToLocal(genderGlobalTopLeft);

        setState(() {
          _dropdownLeft = genderTopLeftInStack.dx; // align left edges
          _dropdownTop = genderTopLeftInStack.dy +
              genderBox.size.height +
              6.0; // just below field
          _isGenderDropdownOpen = !_isGenderDropdownOpen;
          _isListUnfolded = _isGenderDropdownOpen;
        });
        return;
      }
    } catch (_) {
      // Fallback to simple toggle if position can't be computed
    }

    setState(() {
      _isGenderDropdownOpen = !_isGenderDropdownOpen;
      _isListUnfolded = _isGenderDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final hasErrors = _fieldErrors.isNotEmpty;

    // Calculate dynamic height based on error presence
    double windowHeight = 647.0; // Default fixed size

    if (hasErrors) {
      // Calculate required height when errors are present
      const baseHeight = 647.0;
      final errorCount = _fieldErrors.length;
      final errorSpace = errorCount * 20.0; // 20px per error message
      const buffer = 40.0; // Extra buffer
      windowHeight = baseHeight + errorSpace + buffer;

      // Ensure it doesn't exceed 90% of screen height
      final maxHeight = screenSize.height * 0.9;
      windowHeight = windowHeight.clamp(647.0, maxHeight);
    }

    return DefaultTextStyle(
      style: GoogleFonts.notoSerif(),
      child: Stack(
        children: [
          // Main popup
          Center(
            child: Container(
              width: 400,
              height: windowHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  // Form content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 4, bottom: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Username field
                            _buildInputField(
                              controller: _usernameController,
                              label: 'Username',
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['username'],
                            ),
                            const SizedBox(height: 6),

                            // Email field
                            _buildInputField(
                              controller: _emailController,
                              label: 'Email',
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['email'],
                            ),
                            const SizedBox(height: 6),

                            // Verification code field
                            _buildVerificationCodeField(),
                            const SizedBox(height: 6),

                            // Password field
                            _buildInputField(
                              controller: _passwordController,
                              label: 'Password',
                              isPassword: true,
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['password'],
                            ),
                            const SizedBox(height: 6),

                            // Confirm password field
                            _buildInputField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              isPassword: true,
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['confirmPassword'],
                            ),
                            const SizedBox(height: 6),

                            // Gender field
                            _buildGenderField(),
                            const SizedBox(height: 12),

                            // Checkboxes
                            _buildCheckboxes(),
                            const SizedBox(height: 12),

                            // Sign up button
                            _buildSignUpButton(),
                            const SizedBox(height: 8),

                            // Sign in link
                            _buildSignInLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Terms & Conditions popup
          if (_showTermsPopup) _buildTermsPopup(),

          // Gender dropdown overlay - moved outside main popup container
          if (_isGenderDropdownOpen) _buildGenderDropdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: 400,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Text(
          'Sign Up',
          style: GoogleFonts.notoSerif(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool hasCancelButton = false,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 350,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E0E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      label,
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Input field
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 32,
                        ),
                        child: TextFormField(
                          controller: controller,
                          obscureText: isPassword,
                          style: GoogleFonts.notoSerif(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF333333),
                            height: 1.2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Input',
                          ),
                          onChanged: (value) {
                            if (_fieldErrors[label.toLowerCase()] != null) {
                              setState(() {
                                _fieldErrors[label.toLowerCase()] = null;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Cancel button
              if (hasCancelButton)
                Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () {
                      controller.clear();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/images/signup/cancel.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 20),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Error message
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorMessage,
              style: GoogleFonts.notoSerif(
                color: Colors.red,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 350,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E0E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      'Verification Code',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Input field
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 32,
                        ),
                        child: TextFormField(
                          controller: _verificationCodeController,
                          style: GoogleFonts.notoSerif(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF333333),
                            height: 1.2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Input',
                          ),
                          onChanged: (value) {
                            if (_fieldErrors['verificationCode'] != null) {
                              setState(() {
                                _fieldErrors['verificationCode'] = null;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Get code button
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    // Handle get code
                  },
                  child: Container(
                    width: 60,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset(
                      'assets/images/signup/get_code.png',
                      width: 60,
                      height: 30,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          child: const Center(
                            child: Text(
                              'Get Code',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error message
        if (_fieldErrors['verificationCode'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _fieldErrors['verificationCode']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _genderFieldKey,
          width: 350,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE6E0E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      'Gender',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Input field
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 32,
                        ),
                        child: TextFormField(
                          controller: _genderController,
                          readOnly: true,
                          style: GoogleFonts.notoSerif(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF333333),
                            height: 1.2,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Select',
                          ),
                          onTap: _toggleGenderDropdown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Gender dropdown button
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: _toggleGenderDropdown,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      _isListUnfolded
                          ? 'assets/images/signup/unfolded_list_icon.png'
                          : 'assets/images/signup/folded_list_icon.png',
                      width: 20,
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isListUnfolded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Error message
        if (_fieldErrors['gender'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _fieldErrors['gender']!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 10,
                height: 1.1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      children: [
        // Terms & Conditions checkbox
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _agreeTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeTerms = value ?? false;
                    if (_agreeTerms && _fieldErrors['terms'] != null) {
                      _fieldErrors.remove('terms');
                    }
                  });
                },
                activeColor: const Color(0xFF6750A4),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeTerms = !_agreeTerms;
                    if (_agreeTerms && _fieldErrors['terms'] != null) {
                      _fieldErrors.remove('terms');
                    }
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.notoSerif(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to '),
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: GoogleFonts.notoSerif(
                          color: const Color(0xFF3A12D8),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              _showTermsPopup = true;
                            });
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_fieldErrors['terms'] != null) const SizedBox(height: 4),
        if (_fieldErrors['terms'] != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _fieldErrors['terms']!,
                style: GoogleFonts.notoSerif(
                  color: Colors.red,
                  fontSize: 10,
                  height: 1.1,
                ),
              ),
            ),
          ),
        const SizedBox(height: 2),
        // Marketing checkbox
        Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: _agreeMarketing,
                onChanged: (value) {
                  setState(() {
                    _agreeMarketing = value ?? false;
                  });
                },
                activeColor: const Color(0xFF6750A4),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _agreeMarketing = !_agreeMarketing;
                  });
                },
                child: Text(
                  'I agree to receive marketing information',
                  style: GoogleFonts.notoSerif(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Center(
      child: InkWell(
        onTap: () {
          _handleSignUp();
        },
        child: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/signup/Sign_up_tab (1).png',
            width: 100,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 100,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF6750A4),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.notoSerif(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            color: Colors.black,
          ),
          children: [
            TextSpan(
                text: 'Already have an account? ',
                style:
                    GoogleFonts.notoSerif(fontSize: 12, color: Colors.black)),
            TextSpan(
              text: 'Sign in',
              style: GoogleFonts.notoSerif(
                color: const Color(0xFF3A12D8),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  widget.onSignIn?.call();
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdownOverlay() {
    // Position overlay using measured coordinates from _toggleGenderDropdown()
    final double effectiveTop = _dropdownTop ?? 0.0;
    final double effectiveLeft = _dropdownLeft ?? 24.0;

    return Positioned(
      top: effectiveTop,
      left: effectiveLeft,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildGenderOption('Male'),
              _buildGenderOption('Female'),
              _buildGenderOption('Other'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String option) {
    return InkWell(
      onTap: () {
        setState(() {
          _genderController.text = option;
          _isGenderDropdownOpen = false;
          _isListUnfolded = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: Text(
          option,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsPopup() {
    return Center(
      child: Container(
        width: 600,
        height: 500,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showTermsPopup = false;
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Content
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(
                    'Terms and Conditions content goes here...',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
