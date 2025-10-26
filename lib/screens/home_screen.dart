import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/logged_in_navigation_bar.dart';
import '../services/auth_state.dart';
import '../widgets/signup_popup.dart';
import '../widgets/signin_popup.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _isListUnfolded = false;
  String? _hoveredItem;
  bool _showSignUpPopup = false;
  bool _showSignInPopup = false;
  final List<String> _bannerImages = [
    'assets/images/homepage/carousel_template_image_1.png',
    'assets/images/homepage/carousel_template_image_2.png',
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isLoggedIn = ref.watch(authProvider);
    final bool isCompactNav = screenWidth < 720;
    final bool isTightNav = screenWidth < 520;
    final bool showExploreInNav = !isTightNav; // search bar hidden on home nav
    final bool showAuthInNav = !isCompactNav;
    if (isLoggedIn) {
      // Redirect logged-in users to Explore as their home page.
      // Use addPostFrameCallback to avoid setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ModalRoute.of(context)?.settings.name != '/explore') {
          Navigator.of(context).pushReplacementNamed('/explore');
        }
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              isLoggedIn
                  ? const LoggedInNavigationBar()
                  : CustomNavigationBar(
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
                child: Stack(
                  children: [
                    // Carousel banner that fills the entire screen
                    Positioned.fill(
                      child: Image.asset(
                        _bannerImages[_currentIndex],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Text(
                                'Carousel Banner Image',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Overlay to mask the screen
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.3),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Navigation buttons
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildNavButton(
                          'assets/images/homepage/button/chevron_backward.png',
                          () {
                            setState(() {
                              _currentIndex =
                                  (_currentIndex - 1) % _bannerImages.length;
                            });
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _buildNavButton(
                          'assets/images/homepage/button/chevron_forward.png',
                          () {
                            setState(() {
                              _currentIndex =
                                  (_currentIndex + 1) % _bannerImages.length;
                            });
                          },
                        ),
                      ),
                    ),
                    // Center text content
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Header text container
                            Container(
                              width: screenWidth < 840 ? screenWidth - 40 : 800,
                              height: isMobile ? 100 : 120,
                              child: const Center(
                                child: Text(
                                  'Fit The Look You Love',
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Description text container
                            Container(
                              width: screenWidth < 840 ? screenWidth - 40 : 800,
                              height: isMobile ? 140 : 120,
                              child: Center(
                                child: Text(
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                                  style: TextStyle(
                                    fontSize: isMobile ? 14 : 16,
                                    color: Colors.white,
                                    height: 1.6,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Carousel indicators
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _bannerImages.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == entry.key
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Dropdown list when unfolded
          if (!isLoggedIn && _isListUnfolded)
            Positioned(
              top: 108, // Position below navigation bar
              right: 10, // Align with the folded list button
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

          // Sign up popup overlay
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

  Widget _buildNavButton(String imagePath, VoidCallback onTap) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: isMobile ? 56 : 80,
        height: isMobile ? 56 : 80,
        child: Image.asset(
          imagePath,
          width: isMobile ? 56 : 80,
          height: isMobile ? 56 : 80,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              imagePath.contains('forward')
                  ? Icons.chevron_right
                  : Icons.chevron_left,
              color: Colors.grey[400],
              size: isMobile ? 32 : 40,
            );
          },
        ),
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
