import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/logged_in_navigation_bar.dart';
import '../services/auth_state.dart';
import '../widgets/signin_popup.dart';
import '../widgets/signup_popup.dart';
import '../services/explore_repository.dart';
import 'post_screen.dart';
// Edit popup is only for Wardrobe; not used here.

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isListUnfolded = false;
  String? _hoveredItem;
  String? _hoveredOotdId;
  String? _hoveredPostId;
  bool _showSignUpPopup = false;
  bool _showSignInPopup = false;
  bool _autoFillingLastRow = false;
  int _lastAutoFillAtCount = -1;

  final ExploreRepository _repository = const MockExploreRepository();

  // Data state for fetched content
  final List<OotdItem> _ootdItems = <OotdItem>[];
  final List<ExplorePost> _feedPosts = <ExplorePost>[];
  bool _isLoadingOotd = false;
  bool _isLoadingFeed = false;
  bool _isLoadingFollowing = false;
  int _ootdPage = 1;
  int _feedPage = 1;
  int _followingPage = 1;
  static const int _ootdPageSize = 12;
  static const int _feedPageSize = 30;
  static const int _followingPageSize = 30;

  // No initState required for fixed sizes
  @override
  void initState() {
    super.initState();
    // Defer first load to didChangeDependencies to be able to read AuthScope.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure data is fetched on page re-entry/rebuild if nothing is loaded
    if (_ootdItems.isEmpty &&
        _feedPosts.isEmpty &&
        !_isLoadingFeed &&
        !_isLoadingOotd) {
      _loadInitial();
    }
  }

  Future<void> _loadInitial() async {
    final bool isLoggedIn = AuthScope.of(context).isLoggedIn;
    if (isLoggedIn) {
      await Future.wait(<Future<void>>[
        _loadMoreOotd(reset: true),
        _loadMoreFollowing(reset: true),
      ]);
      return;
    }
    await Future.wait(<Future<void>>[
      _loadMoreOotd(reset: true),
      _loadMoreFeed(reset: true),
    ]);
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
      final List<OotdItem> items = await _repository.fetchOotd(
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

  Future<void> _loadMoreFeed({bool reset = false}) async {
    if (_isLoadingFeed) return;
    setState(() {
      _isLoadingFeed = true;
      if (reset) {
        _feedPosts.clear();
        _feedPage = 1;
      }
    });
    try {
      final List<ExplorePost> items = await _repository.fetchFeed(
        page: _feedPage,
        pageSize: _feedPageSize,
      );
      setState(() {
        _feedPosts.addAll(items);
        _feedPage += 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFeed = false;
        });
      }
    }
  }

  Future<void> _loadMoreFollowing({bool reset = false}) async {
    if (_isLoadingFollowing) return;
    setState(() {
      _isLoadingFollowing = true;
      if (reset) {
        _feedPosts.clear();
        _followingPage = 1;
      }
    });
    try {
      final List<ExplorePost> items = await _repository.fetchFollowing(
        page: _followingPage,
        pageSize: _followingPageSize,
      );
      setState(() {
        _feedPosts.addAll(items);
        _followingPage += 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFollowing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthScope.of(context).isLoggedIn;
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 24.0),
                            child: Text(
                              'Best OOTD',
                              style: GoogleFonts.notoSerif(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 180,
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
                                fontSize: 34,
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
                              return _buildJustifiedFeed(availableWidth);
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
                                onPressed: (isLoggedIn
                                        ? _isLoadingFollowing
                                        : _isLoadingFeed)
                                    ? null
                                    : () => (isLoggedIn
                                        ? _loadMoreFollowing()
                                        : _loadMoreFeed()),
                                child: (isLoggedIn
                                        ? _isLoadingFollowing
                                        : _isLoadingFeed)
                                    ? const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : const Text('Load more'),
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
            ],
          ),
          if (!isLoggedIn && _isListUnfolded)
            Positioned(
              top: 108,
              right: 10,
              child: Container(
                width: 186,
                height: 248,
                color: const Color(0xFFEBE6EB),
                child: Column(
                  children: [
                    _buildDropdownItem('About'),
                    _buildDropdownItem('Businesses'),
                    _buildDropdownItem('Terms of Service'),
                    _buildDropdownItem('Privacy Policy'),
                  ],
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
                final OotdItem item = _ootdItems[index];
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

  // Removed unused _computeColumns

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
              Navigator.of(context).pushNamed('/business');
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

  // Add helper to build justified feed rows
  Widget _buildJustifiedFeed(double maxWidth) {
    const double spacing = 16;
    const double targetRowHeight =
        260; // base row height; rows will scale to fit width
    // First pass: group items into rows at target height
    final List<List<ExplorePost>> rowsData = <List<ExplorePost>>[];
    List<ExplorePost> currentRow = <ExplorePost>[];
    double aspectSum = 0.0;

    for (final ExplorePost post in _feedPosts) {
      final double aspect = (post.width > 0 && post.height > 0)
          ? (post.width / post.height)
          : 1.0;
      final double prospectiveAspectSum = aspectSum + aspect;
      final int prospectiveCount = currentRow.length + 1;
      final double totalSpacing = spacing * (prospectiveCount - 1);
      final double prospectiveRowWidth =
          (targetRowHeight * prospectiveAspectSum) + totalSpacing;

      if (prospectiveRowWidth > maxWidth && currentRow.isNotEmpty) {
        rowsData.add(currentRow);
        currentRow = <ExplorePost>[];
        aspectSum = 0.0;
      }
      currentRow.add(post);
      aspectSum += aspect;
    }
    if (currentRow.isNotEmpty) {
      rowsData.add(currentRow);
    }

    // If last row has less than 4 items, trigger auto-load (no borrowing) until filled
    if (rowsData.isNotEmpty && rowsData.last.length < 4 && !_isLoadingFeed) {
      if (_lastAutoFillAtCount != _feedPosts.length) {
        _lastAutoFillAtCount = _feedPosts.length;
        _autoFillingLastRow = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadMoreFeed();
          }
        });
      }
    } else {
      _autoFillingLastRow = false;
    }

    // Render rows: justify all rows to fill width cleanly
    final List<Widget> rows = <Widget>[];
    for (int r = 0; r < rowsData.length; r++) {
      final List<ExplorePost> row = rowsData[r];
      if (row.isEmpty) continue;
      final int n = row.length;
      final double totalSpacing = spacing * (n - 1);
      double rowAspectSum = 0.0;
      for (final ExplorePost p in row) {
        rowAspectSum +=
            (p.width > 0 && p.height > 0) ? (p.width / p.height) : 1.0;
      }
      final double rowHeight = (maxWidth - totalSpacing) / rowAspectSum;
      final List<Widget> tiles = <Widget>[];
      for (final ExplorePost post in row) {
        final double aspect = (post.width > 0 && post.height > 0)
            ? (post.width / post.height)
            : 1.0;
        final double tileWidth = rowHeight * aspect;
        final bool isHovered = _hoveredPostId == post.id;
        tiles.add(
          SizedBox(
            width: tileWidth,
            height: rowHeight,
            child: MouseRegion(
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            image: DecorationImage(
                              image: AssetImage(post.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // No edit overlay on Explore page
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding:
              EdgeInsets.only(bottom: r == rowsData.length - 1 ? 0 : spacing),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List<Widget>.generate(tiles.length * 2 - 1, (int i) {
              if (i.isOdd) return const SizedBox(width: spacing);
              return tiles[i ~/ 2];
            }),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ...rows,
        if (_autoFillingLastRow || _isLoadingFeed)
          const Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: SizedBox(
              height: 24,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
      ],
    );
  }

  // Edit popup intentionally not included on Explore page.
}
