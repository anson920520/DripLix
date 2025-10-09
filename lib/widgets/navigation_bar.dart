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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isCompact = constraints.maxWidth < 600;
                final bool isTight = constraints.maxWidth < 420;

                return Row(
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
                    const Spacer(),
                    // Navigation buttons on the right
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isTight && !widget.showSearchBar)
                                _buildNavButton(
                                  '',
                                  'assets/images/navigation/Explore_tab.png',
                                  onTap: () {
                                    Navigator.of(context).pushNamed('/explore');
                                  },
                                ),
                              if (!isTight && !widget.showSearchBar)
                                const SizedBox(width: 8),
                              if (!isCompact)
                                _buildNavButton(
                                  '',
                                  'assets/images/navigation/Sign_in_tab.png',
                                  onTap: widget.onSignIn,
                                ),
                              if (!isCompact) const SizedBox(width: 8),
                              if (!isCompact)
                                _buildNavButton(
                                  '',
                                  'assets/images/navigation/Sign_up_tab.png',
                                  onTap: widget.onSignUp,
                                ),
                              if (!isCompact) const SizedBox(width: 8),
                              _buildNavButton(
                                '',
                                widget.isListUnfolded
                                    ? 'assets/images/navigation/unfolded_list_icon.png'
                                    : 'assets/images/navigation/folded_list_icon.png',
                                onTap: widget.onListToggle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.showSearchBar) _buildCenteredSearchCard(),
        ],
      ),
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
    return SizedBox(
      width: 720,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECE6F0),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
              height: 28,
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: _activeHint,
                  hintStyle: const TextStyle(color: Colors.black54),
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
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/navigation/Searchbar/Search.png',
                  width: 24,
                  height: 24,
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
