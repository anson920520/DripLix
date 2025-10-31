import 'package:flutter/material.dart';
import 'dart:math';

class CustomNavigationBar extends StatefulWidget {
  final bool isListUnfolded;
  final VoidCallback onListToggle;
  final VoidCallback? onSignUp;
  final VoidCallback? onSignIn;
  final bool showSearchBar;

  const CustomNavigationBar({
    super.key,
    required this.isListUnfolded,
    required this.onListToggle,
    this.onSignUp,
    this.onSignIn,
    this.showSearchBar = false,
  });

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  final TextEditingController _searchController = TextEditingController();
  late String _activeHint;
  static const List<String> _searchHints = <String>[
    'Search outfits for fall',
    'Find jackets under \$100',
    'Discover streetwear brands',
    'Retro sneakers inspiration',
    'Minimalist wardrobe ideas',
    'Black denim looks',
  ];

  @override
  void initState() {
    super.initState();
    final int idx = Random().nextInt(_searchHints.length);
    _activeHint = _searchHints[idx];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isCompact = constraints.maxWidth < 720;
            final bool isTight = constraints.maxWidth < 520;

            // Decide which buttons can be shown inline
            final bool showExplore = !widget.showSearchBar && !isTight;
            final bool showAuth = !isCompact;
            // Remove overflow menu entirely when search bar is shown (Explore)
            final bool needsOverflowMenu =
                !(showExplore && showAuth) && !isCompact && !widget.showSearchBar;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo on the left
                Image.asset(
                  'assets/images/navigation/Driplix Logo.png',
                  height: isCompact ? 32 : 40,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      'DripLix',
                      style: TextStyle(
                        fontSize: isCompact ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                
                // SearchBar in the middle (conditionally shown)
                if (widget.showSearchBar)
                  Expanded(
                    child: isCompact
                        // Inline search bar for compact screens
                        ? _buildInlineSearchBar(isTight: isTight)
                        // Centered search card for larger screens
                        : _buildCenteredSearchCard(),
                  ),
                
                if (!widget.showSearchBar) const Spacer(),

                
                // Spacing between search bar and buttons when search bar is shown
                if (widget.showSearchBar) const SizedBox(width: 8),
                
                // Navigation buttons on the right
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showExplore)
                        _buildNavButton(
                          '',
                          'assets/images/navigation/Explore_tab.png',
                          onTap: () {
                            Navigator.of(context).pushNamed('/explore');
                          },
                        ),
                      if (showExplore) const SizedBox(width: 8),
                      if (showAuth)
                        _buildNavButton(
                          '',
                          'assets/images/navigation/Sign_in_tab.png',
                          onTap: widget.onSignIn,
                        ),
                      if (showAuth) const SizedBox(width: 8),
                      if (showAuth)
                        _buildNavButton(
                          '',
                          'assets/images/navigation/Sign_up_tab.png',
                          onTap: widget.onSignUp,
                        ),
                      if (showAuth) const SizedBox(width: 8),
                      _buildNavButton(
                        '',
                        widget.isListUnfolded
                            ? 'assets/images/navigation/unfolded_list_icon.png'
                            : 'assets/images/navigation/folded_list_icon.png',
                        onTap: widget.onListToggle,
                      ),
                      if (needsOverflowMenu) const SizedBox(width: 8),
                      if (needsOverflowMenu)
                        _buildOverflowMenu(
                          showExploreInMenu: !showExplore,
                          showSignInInMenu: !showAuth,
                          showSignUpInMenu: !showAuth,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverflowMenu({
    required bool showExploreInMenu,
    required bool showSignInInMenu,
    required bool showSignUpInMenu,
  }) {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz, color: Colors.black),
      onSelected: (value) {
        if (value == 'explore') {
          Navigator.of(context).pushNamed('/explore');
        } else if (value == 'signin') {
          widget.onSignIn?.call();
        } else if (value == 'signup') {
          widget.onSignUp?.call();
        }
      },
      itemBuilder: (context) {
        final List<PopupMenuEntry<String>> items = [];
        if (showExploreInMenu) {
          items.add(
            const PopupMenuItem<String>(
              value: 'explore',
              child: Text('Explore'),
            ),
          );
        }
        if (showSignInInMenu) {
          items.add(
            const PopupMenuItem<String>(
              value: 'signin',
              child: Text('Sign in'),
            ),
          );
        }
        if (showSignUpInMenu) {
          items.add(
            const PopupMenuItem<String>(
              value: 'signup',
              child: Text('Sign up'),
            ),
          );
        }
        if (items.isEmpty) {
          // Fallback to avoid empty menu (should not happen due to guard)
          items.add(
            const PopupMenuItem<String>(
              value: 'noop',
              child: Text('No extra actions'),
            ),
          );
        }
        return items;
      },
    );
  }

  Widget _buildNavButton(String text, String imagePath, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        width: 100.0,
        height: 70.0,
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100.0,
              height: 70.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: const Icon(
                Icons.circle,
                size: 40.0,
                color: Colors.black,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCenteredSearchCard() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompact = screenWidth < 720;
    final bool isTight = screenWidth < 520;
    final double height = isTight ? 44 : (isCompact ? 52 : 56);
    final double logoH = isTight ? 20 : (isCompact ? 24 : 28);
    final double iconSize = isTight ? 20 : 24;
    final double fontSize = isTight ? 14 : 16;
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECE6F0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // Logo inside search bar (left)
            Image.asset(
              'assets/images/navigation/Searchbar/Logo.png',
              height: logoH,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.store_mall_directory,
                    size: 24, color: Colors.black87);
              },
            ),
            const SizedBox(width: 12),
            // Input field
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: fontSize, color: Colors.black),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: _activeHint,
                  hintStyle: TextStyle(color: Colors.black54, fontSize: fontSize),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Search action button (image/icon)
            InkWell(
              onTap: () {
                // No-op for now; search will be implemented later.
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: isTight ? 36 : 40,
                height: isTight ? 36 : 40,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/navigation/Searchbar/Search.png',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.search, color: Colors.black);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineSearchBar({required bool isTight}) {
    final double height = isTight ? 44 : 52;
    final double logoH = isTight ? 20 : 24;
    final double iconSize = isTight ? 20 : 24;
    final double fontSize = isTight ? 14 : 16;
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECE6F0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Image.asset(
              'assets/images/navigation/Searchbar/Logo.png',
              height: logoH,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.store_mall_directory,
                    size: 20, color: Colors.black87);
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: fontSize, color: Colors.black),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: _activeHint,
                  hintStyle:
                      TextStyle(color: Colors.black54, fontSize: fontSize),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: isTight ? 36 : 40,
                height: isTight ? 36 : 40,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/navigation/Searchbar/Search.png',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.search, color: Colors.black);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
