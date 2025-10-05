import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Map<String, String?> _fieldErrors = {};

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    Map<String, String?> errors = {};

    if (_emailController.text.isEmpty) {
      errors['email'] = 'Email is required';
    }

    if (_passwordController.text.isEmpty) {
      errors['password'] = 'Password is required';
    }

    setState(() {
      _fieldErrors = errors;
    });

    if (errors.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        final firebaseService = Provider.of<FirebaseService>(context, listen: false);
        final user = await firebaseService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Sign In Successful!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back, ${user?.email ?? "User"}!'),
                  const SizedBox(height: 8),
                  const Text('You have successfully signed in.'),
                ],
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

      } catch (e) {
        showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Sign In Failed'),
              content: Text('Error: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final hasErrors = _fieldErrors.isNotEmpty;

    double windowHeight = 380.0; // Reduced height since we removed account type
    if (hasErrors) {
      final baseHeight = 380.0;
      final errorCount = _fieldErrors.length;
      final errorSpace = errorCount * 20.0;
      final buffer = 40.0;
      windowHeight = baseHeight + errorSpace + buffer;
      final maxHeight = screenSize.height * 0.9;
      windowHeight = windowHeight.clamp(380.0, maxHeight);
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
                            _buildInputField(
                              controller: _emailController,
                              label: 'Email',
                              hasCancelButton: true,
                              errorMessage: _fieldErrors['email'],
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
        onTap: _isLoading ? null : _handleSignIn,
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
          child: _isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Image.asset(
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