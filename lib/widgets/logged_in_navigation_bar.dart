import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoggedInNavigationBar extends StatefulWidget {
  final int initialActiveIndex; // 0=Home,1=Wardrobe,2=Bookmark,3=Shop
  const LoggedInNavigationBar({super.key, this.initialActiveIndex = 0});

  @override
  State<LoggedInNavigationBar> createState() => _LoggedInNavigationBarState();
}

enum ConstantsRight {
  tryon,
  notifications,
  profile,
}
enum ConstantsCenter {
  home,
  wardrobe,
  bookmark,
  marketplace,
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

    return GestureDetector(
      onTap: _isSearchExpanded
          ? () {
              setState(() {
                _isSearchExpanded = false;
              });
            }
          : null,
      behavior: HitTestBehavior.translucent,
      child: Container(
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
              final bool isMobile = constraints.maxWidth < 720;
              final bool tightCenter = constraints.maxWidth < 880;
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Base Row layout with all elements always visible
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left cluster: Logo + Search button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Driplix logo (hidden when search expands)
                          Opacity(
                            opacity: _isSearchExpanded ? 0.0 : 1.0,
                            child: IgnorePointer(
                              ignoring: _isSearchExpanded,
                              // child: Image.asset(
                              //   'assets/images/navigation/Driplix Logo.png',
                              //   height: 40,
                              //   errorBuilder: (context, error, stackTrace) {
                              //     return const Text(
                              //       'DripLix',
                              //       style: TextStyle(
                              //         fontSize: 24,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.black,
                              //       ),
                              //     );
                              //   },
                              // ),
                              child: SvgPicture.asset(
                                'assets/images/navigation/Driplix Logo.svg',
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
                          const SizedBox(width: 8),
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
                                child: SvgPicture.asset(
                                  'assets/images/navigation/Searchbar/Search.svg',
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
                      
                      const Spacer(),

                      // Center cluster: hidden on mobile (moved to bottom nav)
                      if (!tightCenter && !isMobile) _buildCenterButtons(),

                      const Spacer(),

                      // Right cluster: always show, compact on mobile
                      _buildRightButtons(compact: isMobile),
                    ],
                  ),
                  
                  // SearchBar overlay (positioned on the left, covering logo when expanded)
                  if (_isSearchExpanded)
                    Positioned(
                      left: 0,
                      top: null,
                      bottom: null,
                      child: GestureDetector(
                        onTap: () {
                          // Prevent tap from closing search bar when clicking inside
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: screenWidth < 520 
                              ? 320 
                              : (screenWidth * 0.6).clamp(0.0, 520.0),
                          height: screenWidth < 520 ? 44 : (screenWidth < 720 ? 52 : 56),
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
                          clipBehavior: Clip.antiAlias,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              // Logo inside search bar
                              SvgPicture.asset(
                                'assets/images/navigation/Searchbar/Logo.svg',
                                height: screenWidth < 520 ? 20 : (screenWidth < 720 ? 24 : 28),
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.store_mall_directory,
                                      size: 24, color: Colors.black87);
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontSize: screenWidth < 520 ? 14 : 16,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    hintText: 'Search looks, brands, items',
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: screenWidth < 520 ? 14 : 16,
                                    ),
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
                                  child: SvgPicture.asset(
                                    'assets/images/navigation/Searchbar/Search.svg',
                                    width: screenWidth < 520 ? 20 : 24,
                                    height: screenWidth < 520 ? 20 : 24,
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
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget _buildCollapsedCenter() {
  //   return PopupMenuButton<ConstantsCenter>(
  //     tooltip: 'Navigate',
  //     icon: const Icon(Icons.apps, color: Colors.black),
  //     onSelected: (value) {
  //       if (value == ConstantsCenter.home) {
  //         final String? current = ModalRoute.of(context)?.settings.name;
  //         if (current != '/explore') {
  //           Navigator.of(context).pushReplacementNamed('/explore');
  //         }
  //         setState(() {
  //           _activeCenterIndex = 0;
  //         });
  //       } else if (value == ConstantsCenter.wardrobe) {
  //         final String? current = ModalRoute.of(context)?.settings.name;
  //         if (current != '/wardrobe') {
  //           Navigator.of(context).pushReplacementNamed('/wardrobe');
  //         }
  //         setState(() {
  //           _activeCenterIndex = 1;
  //         });
  //       } else if (value == ConstantsCenter.bookmark) {
  //         setState(() {
  //           _activeCenterIndex = 2;
  //         });
  //       } else if (value == ConstantsCenter.marketplace) {
  //         final String? current = ModalRoute.of(context)?.settings.name;
  //         if (current != '/marketplace') {
  //           Navigator.of(context).pushReplacementNamed('/marketplace');
  //         }
  //         setState(() {
  //           _activeCenterIndex = 3;
  //         });
  //       }
  //     },
  //     itemBuilder: (context) => const <PopupMenuEntry<ConstantsCenter>>[
  //       PopupMenuItem<ConstantsCenter>(value: ConstantsCenter.home, child: Text('Home')),
  //       PopupMenuItem<ConstantsCenter>(value: ConstantsCenter.wardrobe, child: Text('Wardrobe')),
  //       PopupMenuItem<ConstantsCenter>(value: ConstantsCenter.bookmark, child: Text('Bookmark')),
  //       PopupMenuItem<ConstantsCenter>(value: ConstantsCenter.marketplace, child: Text('Marketplace')),
  //     ],
  //   );
  // }

  // Widget _buildCollapsedRight() {
  //   return PopupMenuButton<ConstantsRight>(
  //     tooltip: 'More',
  //     icon: const Icon(Icons.more_horiz, color: Colors.black),
  //     onSelected: (value) {
  //       if (value == ConstantsRight.tryon) {
  //         // TODO: wire try on when available
  //       } else if (value == ConstantsRight.notifications) {
  //         // TODO: wire notifications when available
  //       } else if (value == ConstantsRight.profile) {
  //         final String? current = ModalRoute.of(context)?.settings.name;
  //         if (current != '/profile') {
  //           Navigator.of(context).pushReplacementNamed('/profile');
  //         }
  //       }
  //     },
  //     itemBuilder: (context) => const <PopupMenuEntry<ConstantsRight>>[
  //       PopupMenuItem<ConstantsRight>(value: ConstantsRight.tryon, child: Text('Try on')),
  //       PopupMenuItem<ConstantsRight>(
  //           value: ConstantsRight.notifications, child: Text('Notifications')),
  //       PopupMenuItem<ConstantsRight>(value: ConstantsRight.profile, child: Text('Profile')),
  //     ],
  //   );
  // }

  Widget _buildCenterButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _centerButton(
          index: 0,
          asset: 'assets/images/navigation/home_icon.svg',
          tooltip: 'Home',
        ),
        const SizedBox(width: 40),
        _centerButton(
          index: 1,
          asset: 'assets/images/navigation/Wardrobe_icon.svg',
          tooltip: 'Wardrobe',
        ),
        const SizedBox(width: 40),
        _centerButton(
          index: 2,
          asset: 'assets/images/navigation/book_icon.svg',
          tooltip: 'Bookmark',
        ),
        const SizedBox(width: 40),
        _centerButton(
          index: 3,
          asset: 'assets/images/navigation/shop_icon.svg',
          tooltip: 'Marketplace',
        ),
      ],
    );
  }

  Widget _centerButton({
    required int index,
    required String asset,
    String? selectedAsset,
    String? tooltip,
  }) {
    final bool isActive = _activeCenterIndex == index;
    final Widget image = SvgPicture.asset(
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

  Widget _buildRightButtons({bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconButton('assets/images/navigation/try_on.svg',
            isSvg: true, size: compact ? 24 : 28, tooltip: 'Try on'),
        const SizedBox(width: 8),
        _iconButton('assets/images/navigation/notifications.svg',
            isSvg: true, size: compact ? 24 : 28, tooltip: 'Notifications'),
        const SizedBox(width: 8),
        _iconButton('assets/images/navigation/Generic avatar (1).png',
            isSvg: false,
            size: compact ? 28 : 32, tooltip: 'Profile', onTap: () {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != '/profile') {
            Navigator.of(context).pushReplacementNamed('/profile');
            // showDialog(context: context, builder: (context) => UserProfileDropdown(asset: 'assets/images/navigation/Generic avatar (1).png', tooltip: 'Profile', onTap: () {
            //   Navigator.of(context).pushReplacementNamed('/profile');
            // }));
          }
        }),
      ],
    );
  }

  Widget _iconButton(String asset, {bool isSvg = true,
      required double size, String? tooltip, VoidCallback? onTap}) {
    final Widget image = isSvg ? SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.image_outlined, size: size, color: Colors.black);
      },
    ) : Image.asset(
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

class LoggedInBottomNavBar extends StatelessWidget {
  final int activeIndex; // 0=Home,1=Wardrobe,2=Bookmark,3=Shop; -1=none

  const LoggedInBottomNavBar({super.key, this.activeIndex = -1});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 720) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomItem(context, index: 0, asset: 'assets/images/navigation/home_icon.svg', route: '/explore'),
          _bottomItem(context, index: 1, asset: 'assets/images/navigation/Wardrobe_icon.svg', route: '/wardrobe'),
          _bottomItem(context, index: 2, asset: 'assets/images/navigation/book_icon.svg'),
          _bottomItem(context, index: 3, asset: 'assets/images/navigation/shop_icon.svg', route: '/marketplace'),
        ],
      ),
    );
  }

  Widget _bottomItem(BuildContext context, {required int index, required String asset, String? route}) {
    final bool isActive = activeIndex == index;
    return InkWell(
      onTap: () {
        if (route != null) {
          final String? current = ModalRoute.of(context)?.settings.name;
          if (current != route) {
            Navigator.of(context).pushReplacementNamed(route);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            asset,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.image, size: 24, color: Colors.black);
            },
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            width: isActive ? 36 : 0,
            height: 2,
            decoration: const BoxDecoration(color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class UserProfileDropdown extends StatelessWidget {
  final String asset;
  final String tooltip;
  final VoidCallback? onTap;
  const UserProfileDropdown({super.key, required this.asset, required this.tooltip, this.onTap});
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ConstantsRight>(
      tooltip: 'More',
      icon: const Icon(Icons.more_horiz, color: Colors.black),
      itemBuilder: (context) => const <PopupMenuEntry<ConstantsRight>>[
        PopupMenuItem<ConstantsRight>(value: ConstantsRight.tryon, child: Text('Drip Coin')),
        PopupMenuItem<ConstantsRight>(
            value: ConstantsRight.notifications, child: Text('Friends')),
        PopupMenuItem<ConstantsRight>(value: ConstantsRight.profile, child: Text('Follows')),
        PopupMenuItem<ConstantsRight>(value: ConstantsRight.profile, child: Text('Settings')),
        PopupMenuItem<ConstantsRight>(value: ConstantsRight.profile, child: Text('Support Center')),
      ],
    );
  }
}