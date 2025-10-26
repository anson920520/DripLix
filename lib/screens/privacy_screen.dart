import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/signup_popup.dart';
import '../widgets/signin_popup.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'This is a placeholder Privacy Policy page. Replace this text with your actual policy. '
                        'We explain what data DripLix collects, how it is used, and your choices. '
                        'Consult your legal counsel to ensure compliance with applicable laws (e.g., GDPR, CCPA).',
                        style: TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ],
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
              color: Colors.black.withOpacity(0.5),
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
              color: Colors.black.withOpacity(0.5),
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
    final isHovered = _hoveredItem == text;

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
            } else {
              debugPrint('Tapped: $text');
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
                  ? Colors.white.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
