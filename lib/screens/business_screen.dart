import 'package:flutter/material.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/signin_popup.dart';
import '../widgets/signup_popup.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  bool _isListUnfolded = false;
  String? _hoveredItem;
  bool _showSignUpPopup = false;
  bool _showSignInPopup = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompactNav = screenWidth < 720;
    final bool isTightNav = screenWidth < 520;
    final bool showExploreInNav = !isTightNav;
    final bool showAuthInNav = !isCompactNav;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              CustomNavigationBar(
                isListUnfolded: _isListUnfolded,
                onListToggle: () {
                  setState(() {
                    _isListUnfolded = !_isListUnfolded;
                  });
                },
                onSignUp: () {
                  setState(() {
                    _showSignUpPopup = true;
                  });
                },
                onSignIn: () {
                  setState(() {
                    _showSignInPopup = true;
                  });
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 32.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Grow your business with DripLix',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'DripLix is where fashion enthusiasts effortlessly mix and match their wardrobe items to create personalized Outfit of the Day (OOTD) concepts. For fashion merchants, we offer a unique opportunity to upload product images, enhancing customer satisfaction and reducing returns. Our platform also provides targeted marketing channels to help merchants attract specific consumer groups and drive business growth. Join DripLix to transform the shopping experience!',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showSignUpPopup = true;
                                      });
                                    },
                                    child: const Text(
                                      'Sign up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 44,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            title:
                                                const Text('Request a meeting'),
                                            content: const Text(
                                              'Thanks for your interest! A team member will reach out shortly. ',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'Request meeting',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isListUnfolded)
            Positioned(
              top: 108,
              right: 10,
              child: Container(
                width: 186,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 140,
                ),
                color: const Color(0xFFEBE6EB),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDropdownItem('About'),
                      _buildDropdownItem('Businesses'),
                      _buildDropdownItem('Terms of Service'),
                      _buildDropdownItem('Privacy Policy'),
                      if (!showExploreInNav) _buildDropdownItem('Explore'),
                      if (!showAuthInNav) _buildDropdownItem('Sign in'),
                      if (!showAuthInNav) _buildDropdownItem('Sign up'),
                    ],
                  ),
                ),
              ),
            ),
          if (_showSignUpPopup)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: SignUpPopup(
                onClose: () {
                  setState(() {
                    _showSignUpPopup = false;
                  });
                },
                onSignIn: () {
                  setState(() {
                    _showSignUpPopup = false;
                    _showSignInPopup = true;
                  });
                },
              ),
            ),
          if (_showSignInPopup)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: SignInPopup(
                onClose: () {
                  setState(() {
                    _showSignInPopup = false;
                  });
                },
                onSignUp: () {
                  setState(() {
                    _showSignInPopup = false;
                    _showSignUpPopup = true;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String text) {
    final bool isHovered = _hoveredItem == text;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredItem = text;
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredItem = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: InkWell(
          onTap: () {
            if (text == 'Terms of Service') {
              Navigator.of(context).pushNamed('/terms');
            } else if (text == 'Privacy Policy') {
              Navigator.of(context).pushNamed('/privacy');
            } else if (text == 'About') {
              Navigator.of(context).pushNamed('/about');
            } else if (text == 'Businesses') {
              // Already here
            } else if (text == 'Explore') {
              Navigator.of(context).pushNamed('/explore');
            } else if (text == 'Sign in') {
              setState(() {
                _showSignInPopup = true;
              });
            } else if (text == 'Sign up') {
              setState(() {
                _showSignUpPopup = true;
              });
            }
            setState(() {
              _isListUnfolded = false;
            });
          },
          child: Container(
            width: 186,
            height: 62,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: isHovered
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isHovered ? Colors.black87 : Colors.black,
                  fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
