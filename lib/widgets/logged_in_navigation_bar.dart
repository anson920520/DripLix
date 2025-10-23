import 'dart:math';

import 'package:flutter/material.dart';

class LoggedInNavigationBar extends StatefulWidget {
  final int initialActiveIndex; // 0=Home,1=Wardrobe,2=Bookmark,3=Shop
  const LoggedInNavigationBar({super.key, this.initialActiveIndex = 0});

  @override
  State<LoggedInNavigationBar> createState() => _LoggedInNavigationBarState();
}

class _LoggedInNavigationBarState extends State<LoggedInNavigationBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  late int _activeCenterIndex; // 0=Home,1=Wardrobe,2=Bookmark,3=Shop

  @override
  void initState() {
    super.initState();
    _activeCenterIndex = widget.initialActiveIndex;
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
                final bool tightCenter =
                    constraints.maxWidth < 880; // hides some center icons
                final bool veryTight =
                    constraints.maxWidth < 640; // collapse right icons
                return Row(
                  children: [
                    // Left cluster: Logo + Search button
                    SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Driplix logo (covered when search expands)
                          Opacity(
                            opacity: _isSearchExpanded ? 0.0 : 1.0,
                            child: IgnorePointer(
                              ignoring: _isSearchExpanded,
                              child: Image.asset(
                                'assets/images/navigation/Driplix Logo.png',
                                height: 40,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'DripLix',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 59,
                            height: 50,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isSearchExpanded = !_isSearchExpanded;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/navigation/Searchbar/Search.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.search,
                                        color: Colors.black);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Center cluster: 4 buttons, may overflow to menu
                    if (!tightCenter)
                      _buildCenterButtons()
                    else
                      _buildCollapsedCenter(),

                    const Spacer(),

                    // Right cluster: may overflow to menu
                    if (!veryTight)
                      _buildRightButtons()
                    else
                      _buildCollapsedRight(),
                  ],
                );
              },
            ),
          ),

          // Search overlay on the leftmost, covering the logo area
          if (_isSearchExpanded)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _isSearchExpanded = false;
                  });
                },
              ),
            ),
          Positioned(
            left: 16,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: _isSearchExpanded ? min(screenWidth * 0.5, 520) : 0,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFECE6F0),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isSearchExpanded
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: _isSearchExpanded
                  ? Row(
                      children: [
                        const SizedBox(width: 12),
                        // Match navigation_bar.dart: left logo inside bar
                        Image.asset(
                          'assets/images/navigation/Searchbar/Logo.png',
                          height: 28,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.store_mall_directory,
                                size: 24, color: Colors.black87);
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Search looks, brands, items',
                              hintStyle: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // No-op for now; search behavior to be implemented later.
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/navigation/Searchbar/Search.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.search,
                                    color: Colors.black);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedCenter() {
    return PopupMenuButton<String>(
      tooltip: 'Navigate',
      icon: const Icon(Icons.apps, color: Colors.black),
      onSelected: (value) {
        if (value == 'home') {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/explore') {
            Navigator.of(context).pushReplacementNamed('/explore');
          }
          setState(() {
            _activeCenterIndex = 0;
          });
        } else if (value == 'wardrobe') {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/wardrobe') {
            Navigator.of(context).pushReplacementNamed('/wardrobe');
          }
          setState(() {
            _activeCenterIndex = 1;
          });
        } else if (value == 'bookmark') {
          setState(() {
            _activeCenterIndex = 2;
          });
        } else if (value == 'marketplace') {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/marketplace') {
            Navigator.of(context).pushReplacementNamed('/marketplace');
          }
          setState(() {
            _activeCenterIndex = 3;
          });
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'home', child: Text('Home')),
        PopupMenuItem<String>(value: 'wardrobe', child: Text('Wardrobe')),
        PopupMenuItem<String>(value: 'bookmark', child: Text('Bookmark')),
        PopupMenuItem<String>(value: 'marketplace', child: Text('Marketplace')),
      ],
    );
  }

  Widget _buildCollapsedRight() {
    return PopupMenuButton<String>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz, color: Colors.black),
      onSelected: (value) {
        if (value == 'tryon') {
          // TODO: wire try on when available
        } else if (value == 'notifications') {
          // TODO: wire notifications when available
        } else if (value == 'profile') {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/profile') {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(value: 'tryon', child: Text('Try on')),
        PopupMenuItem<String>(
            value: 'notifications', child: Text('Notifications')),
        PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
      ],
    );
  }

  Widget _buildCenterButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _centerButton(
          index: 0,
          asset: 'assets/images/navigation/home_icon.png',
          tooltip: 'Home',
        ),
        const SizedBox(width: 40),
        _centerButton(
          index: 1,
          asset: 'assets/images/navigation/Wardrobe_icon.png',
          tooltip: 'Wardrobe',
        ),
        const SizedBox(width: 40),
        _centerButton(
          index: 2,
          asset: 'assets/images/navigation/book_icon.png',
          tooltip: 'Bookmark',
        ),
        const SizedBox(width: 40),
        _centerButton(
          index: 3,
          asset: 'assets/images/navigation/shop_icon.png',
          tooltip: 'Marketplace',
        ),
      ],
    );
  }

  Widget _centerButton({
    required int index,
    required String asset,
    String? tooltip,
  }) {
    final bool isActive = _activeCenterIndex == index;
    final Widget image = Image.asset(
      asset,
      width: 40,
      height: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.image, size: 32, color: Colors.black);
      },
    );
    final Widget button = InkWell(
      onTap: () {
        if (index == 0) {
          // Home: navigate to explore page for logged-in users
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/explore') {
            Navigator.of(context).pushReplacementNamed('/explore');
          }
          setState(() {
            _activeCenterIndex = index;
          });
        } else if (index == 1) {
          // Wardrobe
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/wardrobe') {
            Navigator.of(context).pushReplacementNamed('/wardrobe');
          }
          setState(() {
            _activeCenterIndex = index;
          });
        } else if (index == 3) {
          // Marketplace
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/marketplace') {
            Navigator.of(context).pushReplacementNamed('/marketplace');
          }
          setState(() {
            _activeCenterIndex = index;
          });
        } else {
          setState(() {
            _activeCenterIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 60, height: 40, child: Center(child: image)),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: isActive ? 50 : 0,
            height: 2,
            decoration: const BoxDecoration(color: Colors.black),
          ),
        ],
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }

  Widget _buildRightButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton('assets/images/navigation/try_on.png', tooltip: 'Try on'),
        const SizedBox(width: 8),
        _iconButton('assets/images/navigation/notifications.png',
            tooltip: 'Notifications'),
        const SizedBox(width: 8),
        _iconButton('assets/images/navigation/Generic avatar (1).png',
            size: 32, tooltip: 'Profile', onTap: () {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/profile') {
            Navigator.of(context).pushReplacementNamed('/profile');
          }
        }),
      ],
    );
  }

  Widget _iconButton(String asset,
      {double size = 28, String? tooltip, VoidCallback? onTap}) {
    final Widget image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.image_outlined, size: size, color: Colors.black);
      },
    );
    final Widget button = InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: image,
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}
