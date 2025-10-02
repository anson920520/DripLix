import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_receiver.dart';
import '../config/debug_flags.dart';

class SignInPopup extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onSignUp;

  const SignInPopup({
    Key? key,
    this.onClose,
    this.onSignUp,
  }) : super(key: key);

  @override
  State<SignInPopup> createState() => _SignInPopupState();
}

class _SignInPopupState extends State<SignInPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accountTypeController = TextEditingController();
  final TextEditingController _emailOrUsernameController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GlobalKey _accountTypeFieldKey = GlobalKey();
  double? _dropdownTop;
  double? _dropdownLeft;

  bool _isListUnfolded = false;
  bool _isAccountTypeDropdownOpen = false;

  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _accountTypeController.dispose();
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    Map<String, String?> errors = {};

    if (_accountTypeController.text.isEmpty) {
      errors['account type'] = 'Please select an account type';
    }

    if (_emailOrUsernameController.text.isEmpty) {
      errors['email or username'] = 'Email or username is required';
    }

    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Password is required';
    }

    setState(() {
      _fieldErrors = errors;
    });

    if (errors.isEmpty) {
      final receiver = const AuthReceiverService();
      receiver
          .receiveSignIn(
        accountType: _accountTypeController.text,
        emailOrUsername: _emailOrUsernameController.text,
        password: _passwordController.text,
      )
          .then((payload) {
        // TEST-ONLY: show submitted payload in a dialog for verification.
        // To remove later, delete this block or set DebugFlags.showAuthTestDialogs = false.
        if (DebugFlags.showAuthTestDialogs) {
          showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text('Sign-In Data Received (Test)'),
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

  void _toggleAccountTypeDropdown() {
    try {
      final BuildContext? fieldContext = _accountTypeFieldKey.currentContext;
      final RenderObject? stackRenderObject = context.findRenderObject();
      if (fieldContext != null && stackRenderObject is RenderBox) {
        final RenderBox fieldBox = fieldContext.findRenderObject() as RenderBox;
        final Offset globalTopLeft = fieldBox.localToGlobal(Offset.zero);
        final Offset topLeftInStack =
            stackRenderObject.globalToLocal(globalTopLeft);

        setState(() {
          _dropdownLeft = topLeftInStack.dx;
          _dropdownTop = topLeftInStack.dy + fieldBox.size.height + 6.0;
          _isAccountTypeDropdownOpen = !_isAccountTypeDropdownOpen;
          _isListUnfolded = _isAccountTypeDropdownOpen;
        });
        return;
      }
    } catch (_) {}

    setState(() {
      _isAccountTypeDropdownOpen = !_isAccountTypeDropdownOpen;
      _isListUnfolded = _isAccountTypeDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final hasErrors = _fieldErrors.isNotEmpty;

    double windowHeight = 415.0;
    if (hasErrors) {
      final baseHeight = 415.0;
      final errorCount = _fieldErrors.length;
      final errorSpace = errorCount * 20.0;
      final buffer = 40.0;
      windowHeight = baseHeight + errorSpace + buffer;
      final maxHeight = screenSize.height * 0.9;
      windowHeight = windowHeight.clamp(415.0, maxHeight);
    }

    return DefaultTextStyle(
      style: GoogleFonts.notoSerif(),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 400,
              height: windowHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 4, bottom: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAccountTypeField(),
                            const SizedBox(height: 14),
                            _buildInputField(
                              controller: _emailOrUsernameController,
                              label: 'Email or Username',
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['email or username'],
                            ),
                            const SizedBox(height: 14),
                            _buildInputField(
                              controller: _passwordController,
                              label: 'Password',
                              isPassword: true,
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['password'],
                            ),
                            const SizedBox(height: 18),
                            _buildForgotPassword(),
                            const SizedBox(height: 12),
                            _buildSignInButton(),
                            const SizedBox(height: 8),
                            _buildSignUpLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isAccountTypeDropdownOpen) _buildAccountTypeDropdownOverlay(),
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
          'Sign In',
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
                    Text(
                      label,
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 32),
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
                            final String key = label.toLowerCase();
                            if (_fieldErrors[key] != null) {
                              setState(() {
                                _fieldErrors[key] = null;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                        'assets/images/signin/cancel.png',
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

  Widget _buildAccountTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: _accountTypeFieldKey,
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
                    Text(
                      'Account Type',
                      style: GoogleFonts.notoSerif(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 32),
                        child: TextFormField(
                          controller: _accountTypeController,
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
                          onTap: _toggleAccountTypeDropdown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: InkWell(
                  onTap: _toggleAccountTypeDropdown,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      _isListUnfolded
                          ? 'assets/images/signin/unfolded_list_icon.png'
                          : 'assets/images/signin/folded_list_icon.png',
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
        if (_fieldErrors['account type'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _fieldErrors['account type']!,
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

  Widget _buildAccountTypeDropdownOverlay() {
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAccountTypeOption('Individual'),
              _buildAccountTypeOption('Businesses'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeOption(String option) {
    return InkWell(
      onTap: () {
        setState(() {
          _accountTypeController.text = option;
          _isAccountTypeDropdownOpen = false;
          _isListUnfolded = false;
          if (_fieldErrors['account type'] != null) {
            _fieldErrors['account type'] = null;
          }
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Forgot password clicked'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        child: Text(
          'Forgot password',
          style: GoogleFonts.notoSerif(
            color: const Color(0xFF3A12D8),
            decoration: TextDecoration.underline,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Center(
      child: InkWell(
        onTap: _handleSignIn,
        child: Container(
          width: 100,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/navigation/Sign_in_tab.png',
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
                    'Sign In',
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

  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.notoSerif(
            fontSize: 12,
            color: Colors.black,
          ),
          children: [
            TextSpan(
              text: "Don't have account? ",
              style: GoogleFonts.notoSerif(fontSize: 12, color: Colors.black),
            ),
            TextSpan(
              text: 'Sign up',
              style: GoogleFonts.notoSerif(
                color: const Color(0xFF3A12D8),
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  widget.onSignUp?.call();
                },
            ),
          ],
        ),
      ),
    );
  }
}
