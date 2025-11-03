import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/logged_in_navigation_bar.dart';
import '../services/auth_state.dart';
import '../widgets/signin_popup.dart';
import '../widgets/signup_popup.dart';
import '../presentation/viewmodel/explore_viewmodel.dart';
import '../services/explore_repository.dart' as svc;
import 'post_screen.dart';
// Edit popup is only for Wardrobe; not used here.

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  bool _isListUnfolded = false;
  String? _hoveredItem;
  String? _hoveredOotdId;
  String? _hoveredPostId;
  bool _showSignUpPopup = false;
  bool _showSignInPopup = false;

  // Data state for OOTD（保持原实现，后续可迁移到ViewModel）
  final List<svc.OotdItem> _ootdItems = <svc.OotdItem>[];
  bool _isLoadingOotd = false;
  int _ootdPage = 1;
  static const int _ootdPageSize = 12;
  final svc.ExploreRepository _mockRepo = const svc.MockExploreRepository();

  // No initState required for fixed sizes
  @override
  void initState() {
    super.initState();
    // Defer first load to didChangeDependencies to be able to read auth state.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure data is fetched on page re-entry/rebuild if nothing is loaded
    if (_ootdItems.isEmpty && !_isLoadingOotd) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    final bool isLoggedIn = ref.read(authProvider);
    // feed通过ViewModel加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(exploreViewModelProvider.notifier).showFollowing(isLoggedIn);
      ref.read(exploreViewModelProvider.notifier).refresh();
    });
    await _loadMoreOotd(reset: true);
  }

  Future<void> _loadMoreOotd({bool reset = false}) async {
    if (_isLoadingOotd) return;
    setState(() {
      _isLoadingOotd = true;
      if (reset) {
        _ootdItems.clear();
        _ootdPage = 1;
      }
    });
    try {
      final List<svc.OotdItem> items = await _mockRepo.fetchOotd(
        page: _ootdPage,
        pageSize: _ootdPageSize,
      );
      setState(() {
        _ootdItems.addAll(items);
        _ootdPage += 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOotd = false;
        });
      }
    }
  }

  // Feed通过ViewModel管理，移除本地加载函数

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = ref.watch(authProvider);
    final postsAsync = ref.watch(exploreViewModelProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isCompactNav = screenWidth < 720;
    final bool isTightNav = screenWidth < 520;
    const bool showExploreInNav = false; // Explore tab hidden when search bar shows
    final bool showAuthInNav = !isCompactNav;
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
                      showSearchBar: true,
                    ),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1370),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTightNav
                              ? 12
                              : (isCompactNav ? 16 : 0),
                        ),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 24.0),
                            child: Text(
                              'Best OOTD',
                              style: GoogleFonts.notoSerif(
                                fontSize: screenWidth < 480 ? 24 : 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: screenWidth < 480 ? 140 : 180,
                            child: _buildOotdStrip(),
                          ),
                          if (_isLoadingOotd)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                height: 24,
                                child: Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Text(
                              isLoggedIn
                                  ? 'Following'
                                  : 'New drops For Your Fits',
                              style: GoogleFonts.notoSerif(
                                fontSize: screenWidth < 480 ? 24 : 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final double availableWidth =
                                  constraints.maxWidth;
                              final List<svc.ExplorePost> posts = postsAsync.when(
                                data: (data) => data,
                                loading: () => <svc.ExplorePost>[],
                                error: (_, __) => <svc.ExplorePost>[],
                              );
                              return _buildJustifiedFeed(availableWidth, posts);
                            },
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.black12,
                                  disabledForegroundColor: Colors.white70,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                onPressed: postsAsync.isLoading
                                    ? null
                                    : () => ref
                                        .read(exploreViewModelProvider.notifier)
                                        .loadMore(),
                                child: const Text('Load more'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (!isLoggedIn && _isListUnfolded)
            Positioned(
              top: 108,
              right: 10,
              child: Container(
                width: isCompactNav ? 160 : 186,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 140,
                ),
                color: const Color(0xFFEBE6EB),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildDropdownItem('About', compact: isCompactNav),
                      _buildDropdownItem('Businesses', compact: isCompactNav),
                      _buildDropdownItem('Terms of Service', compact: isCompactNav),
                      _buildDropdownItem('Privacy Policy', compact: isCompactNav),
                      if (!showAuthInNav) _buildDropdownItem('Sign in', compact: isCompactNav),
                      if (!showAuthInNav) _buildDropdownItem('Sign up', compact: isCompactNav),
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
                color: Colors.black.withValues(alpha: 0.5),
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
                color: Colors.black.withValues(alpha: 0.5),
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
          // Logged-in bottom nav on mobile
          if (isLoggedIn && isCompactNav)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LoggedInBottomNavBar(activeIndex: 0),
            ),
        ],
      ),
    );
  }

  Widget _buildOotdStrip() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 180;
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
                  !_isLoadingOotd) {
                _loadMoreOotd();
              }
              return false;
            },
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _ootdItems.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _ootdItems.length) {
                  return SizedBox(
                    width: 120,
                    height: itemHeight,
                    child: Center(
                      child: OutlinedButton(
                        onPressed:
                            _isLoadingOotd ? null : () => _loadMoreOotd(),
                        child: _isLoadingOotd
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('More'),
                      ),
                    ),
                  );
                }
                final svc.OotdItem item = _ootdItems[index];
                final double aspect = (item.width > 0 && item.height > 0)
                    ? (item.width / item.height)
                    : 1.3;
                final double itemWidth = itemHeight * aspect;
                final bool isHovered = _hoveredOotdId == item.id;
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredOotdId = item.id;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredOotdId = null;
                    });
                  },
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    scale: isHovered ? 1.03 : 1.0,
                    curve: Curves.easeOut,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PostScreen(postId: item.id),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: itemWidth,
                          height: itemHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.image,
                                          color: Colors.black45),
                                    ),
                                  );
                                },
                              ),
                              // No edit overlay on Explore page
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Calculate column count based on screen width
  int _calculateColumnCount(double width) {
    if (width < 600) {
      return 1;
    } else if (width < 900) {
      return 2;
    } else if (width < 1200) {
      return 3;
    } else {
      return 4;
    }
  }

  Widget _buildDropdownItem(String text, {bool compact = false}) {
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
        transform: Matrix4.identity()..scaleByVector3(Vector3.all(isHovered ? 1.05 : 1.0)),
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
            }
            setState(() {
              _isListUnfolded = false;
            });
          },
          child: Container(
            width: compact ? 160 : 186,
            height: compact ? 52 : 62,
            padding: EdgeInsets.symmetric(
                vertical: compact ? 12 : 16, horizontal: compact ? 14 : 20),
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
                  fontSize: compact ? 14 : 16,
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

  // Build masonry waterfall feed layout
  Widget _buildJustifiedFeed(double maxWidth, List<svc.ExplorePost> feedPosts) {
    if (feedPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    const double spacing = 16.0;
    final int columnCount = _calculateColumnCount(maxWidth);

    return MasonryGridView.count(
      crossAxisCount: columnCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: feedPosts.length,
      itemBuilder: (context, index) {
        final svc.ExplorePost post = feedPosts[index];
        final bool isHovered = _hoveredPostId == post.id;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Get the actual width allocated by MasonryGridView
            // final double actualWidth = constraints.maxWidth;
            // final double aspect = (post.width > 0 && post.height > 0)
            //     ? (post.width / post.height)
            //     : 1.0;
            // final double itemHeight = actualWidth / aspect;

            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  _hoveredPostId = post.id;
                });
              },
              onExit: (_) {
                setState(() {
                  _hoveredPostId = null;
                });
              },
              child: AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: isHovered ? 1.03 : 1.0,
                curve: Curves.easeOut,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostScreen(postId: post.id),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      // height: itemHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Image.asset(
                        post.imageUrl,
                        // width: actualWidth,
                        // height: itemHeight,
                        fit: BoxFit.scaleDown,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.black45),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Edit popup intentionally not included on Explore page.
}

