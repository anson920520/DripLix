import 'package:flutter/material.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/signup_popup.dart';
import '../widgets/signin_popup.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _isListUnfolded = false;
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
                              'About DripLix',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'DripLix is an innovative virtual fitting room designed for fashion enthusiasts, where users can effortlessly mix and match their existing wardrobe items to create personalized Outfit of the Day (OOTD) concepts. In this vibrant online space, users can seamlessly share their virtual closets with friends and easily search for related items across multiple platforms with just one click, enabling smart price comparisons. DripLix transforms the way people shop, inspiring creativity while enhancing the overall shopping experience in a positive and engaging environment.',
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 28),
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
                                  Navigator.of(context).pushNamed('/explore');
                                },
                                child: const Text(
                                  'Explore',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                      _buildDropdownItem(context, 'About'),
                      _buildDropdownItem(context, 'Businesses'),
                      _buildDropdownItem(context, 'Terms of Service'),
                      _buildDropdownItem(context, 'Privacy Policy'),
                      if (!showExploreInNav)
                        _buildDropdownItem(context, 'Explore'),
                      if (!showAuthInNav)
                        _buildDropdownItem(context, 'Sign in'),
                      if (!showAuthInNav)
                        _buildDropdownItem(context, 'Sign up'),
                    ],
                  ),
                ),
              ),
            ),
          if (_showSignUpPopup)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSignUpPopup = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: GestureDetector(
                  onTap: () {}, // 阻止事件冒泡
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
              ),
            ),
          if (_showSignInPopup)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSignInPopup = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: GestureDetector(
                  onTap: () {}, // 阻止事件冒泡
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(BuildContext context, String text) {
    return InkWell(
      onTap: () {
        if (text == 'Terms of Service') {
          Navigator.of(context).pushNamed('/terms');
        } else if (text == 'Privacy Policy') {
          Navigator.of(context).pushNamed('/privacy');
        } else if (text == 'About') {
          // Already here; just close the list
        } else if (text == 'Businesses') {
          Navigator.of(context).pushNamed('/business');
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
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
