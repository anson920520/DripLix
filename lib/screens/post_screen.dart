import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/logged_in_navigation_bar.dart';
import '../services/explore_repository.dart';
import '../widgets/signin_popup.dart';
import '../widgets/signup_popup.dart';
import '../services/auth_state.dart';

class _DragScrollBehavior extends MaterialScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}

class PostScreen extends StatefulWidget {
  final String postId;

  const PostScreen({
    super.key,
    required this.postId,
  });

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  int _currentIndex = 0;
  final ExploreRepository _repository = const MockExploreRepository();
  final List<ExplorePost> _morePosts = <ExplorePost>[];
  bool _isLoadingMore = false;
  int _page = 1;
  static const int _pageSize = 24;
  PostDetail? _detail;
  bool _isLoadingDetail = false;
  final List<Size?> _imageSizes = <Size?>[];

  // Nav interactions
  bool _isListUnfolded = false;
  String? _hoveredItem;
  bool _showSignUpPopup = false;
  bool _showSignInPopup = false;

  // Actions state
  bool _liked = false;
  int _likeCount = 0;
  int _viewCount = 0;
  bool _bookmarked = false;
  bool _inWardrobe = false;

  @override
  void initState() {
    super.initState();
    _loadMore(reset: true);
    _loadDetail();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_morePosts.isEmpty && !_isLoadingMore) {
      _loadMore(reset: true);
    }
  }

  Future<void> _loadMore({bool reset = false}) async {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      if (reset) {
        _morePosts.clear();
        _page = 1;
      }
    });
    try {
      final List<ExplorePost> items =
          await _repository.fetchFeed(page: _page, pageSize: _pageSize);
      setState(() {
        _morePosts.addAll(items);
        _page += 1;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoadingDetail = true;
    });
    try {
      final PostDetail detail = await _repository.fetchPost(widget.postId);
      setState(() {
        _detail = detail;
        // Initialize counts for demo purposes
        _likeCount = (detail.id.hashCode.abs() % 500) + 20;
        _viewCount = (detail.id.hashCode.abs() % 5000) + 200;
        _imageSizes
          ..clear()
          ..addAll(List<Size?>.filled(detail.imageUrls.length, null));
      });
      _resolveImageSizes();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  void _resolveImageSizes() {
    if (_detail == null) return;
    for (int i = 0; i < _detail!.imageUrls.length; i++) {
      final String url = _detail!.imageUrls[i];
      final AssetImage provider = AssetImage(url);
      final ImageStream stream = provider.resolve(const ImageConfiguration());
      late final ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool sync) {
        final double w = info.image.width.toDouble();
        final double h = info.image.height.toDouble();
        if (mounted) {
          setState(() {
            if (i < _imageSizes.length) {
              _imageSizes[i] = Size(w, h);
            }
          });
        }
        stream.removeListener(listener);
      }, onError: (dynamic _, __) {
        stream.removeListener(listener);
      });
      stream.addListener(listener);
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _isLoadingDetail
                                ? const SizedBox(
                                    height: 200,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                  )
                                : _detail == null
                                    ? const SizedBox(
                                        height: 200,
                                        child: Center(
                                            child: Text('Failed to load post')),
                                      )
                                    : _buildPostCard(),
                            const SizedBox(height: 24),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Text(
                                  'Explore more',
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            _buildExploreMoreJustified(),
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
                                  onPressed:
                                      _isLoadingMore ? null : () => _loadMore(),
                                  child: _isLoadingMore
                                      ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : const Text('Load more'),
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

  Widget _buildPostCard() {
    // Compute display size for current image (bigger: up to 480x720)
    const double maxImageWidth = 480;
    const double maxImageHeight = 720;
    Size? natural = (_currentIndex < _imageSizes.length)
        ? _imageSizes[_currentIndex]
        : null;
    double displayW = maxImageWidth;
    double displayH = maxImageHeight;
    if (natural != null && natural.width > 0 && natural.height > 0) {
      final double scaleW = maxImageWidth / natural.width;
      final double scaleH = maxImageHeight / natural.height;
      final double scale = scaleW < scaleH ? scaleW : scaleH;
      displayW = natural.width * scale;
      displayH = natural.height * scale;
    }
    final double dotsAndGap = 24; // dots + spacing below image
    final double cardHeight =
        (displayH + dotsAndGap) + 32; // include vertical padding 16*2

    return Container(
      width: 900,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Row(
          children: [
            // Left column: image pager + dots below
            SizedBox(
              width: displayW,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxW = maxImageWidth;
                      final double maxH = maxImageHeight;
                      final Size? natCur = (_currentIndex < _imageSizes.length)
                          ? _imageSizes[_currentIndex]
                          : null;
                      double outerW = displayW;
                      double outerH = displayH;
                      if (natCur != null &&
                          natCur.width > 0 &&
                          natCur.height > 0) {
                        final double scaleW = maxW / natCur.width;
                        final double scaleH = maxH / natCur.height;
                        final double scale = scaleW < scaleH ? scaleW : scaleH;
                        outerW = natCur.width * scale;
                        outerH = natCur.height * scale;
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: outerW,
                              height: outerH,
                              child: PageView.builder(
                                itemCount: _detail!.imageUrls.length,
                                onPageChanged: (int idx) {
                                  setState(() {
                                    _currentIndex = idx;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final String url = _detail!.imageUrls[index];
                                  // compute page-specific display size
                                  Size? nat = (index < _imageSizes.length)
                                      ? _imageSizes[index]
                                      : null;
                                  double w = outerW;
                                  double h = outerH;
                                  if (nat != null &&
                                      nat.width > 0 &&
                                      nat.height > 0) {
                                    final double sW = maxImageWidth / nat.width;
                                    final double sH =
                                        maxImageHeight / nat.height;
                                    final double s = sW < sH ? sW : sH;
                                    w = nat.width * s;
                                    h = nat.height * s;
                                  }
                                  return Center(
                                    child: Image.asset(
                                      url,
                                      width: w,
                                      height: h,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: w,
                                          height: h,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(Icons.broken_image,
                                                color: Colors.black45),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ).letWithScrollConfig(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(
                                _detail!.imageUrls.length, (int i) {
                              final bool active = i == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 8 : 6,
                                height: active ? 8 : 6,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right: details + actions inside the card
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: const AssetImage(
                              'assets/images/post/Generic avatar.png'),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _detail!.userName,
                          style: GoogleFonts.notoSerif(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _detail!.title,
                      style: GoogleFonts.notoSerif(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _detail!.text,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Explore-more: same justified layout as Explore page
  Widget _buildExploreMoreJustified() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        const double spacing = 16;
        const double targetRowHeight = 260;

        // Group into rows
        final List<List<ExplorePost>> rowsData = <List<ExplorePost>>[];
        List<ExplorePost> currentRow = <ExplorePost>[];
        double aspectSum = 0.0;
        for (final ExplorePost post in _morePosts) {
          final double aspect = (post.width > 0 && post.height > 0)
              ? (post.width / post.height)
              : 1.0;
          final double prosAspectSum = aspectSum + aspect;
          final int prosCount = currentRow.length + 1;
          final double totalSpacing = spacing * (prosCount - 1);
          final double prosWidth =
              (targetRowHeight * prosAspectSum) + totalSpacing;
          if (prosWidth > maxWidth && currentRow.isNotEmpty) {
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

        // Auto-load more until last row has 4 items
        if (rowsData.isNotEmpty &&
            rowsData.last.length < 4 &&
            !_isLoadingMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadMore();
            }
          });
        }

        // Render justified rows
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
            tiles.add(
              SizedBox(
                width: tileWidth,
                height: rowHeight,
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
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        image: DecorationImage(
                          image: AssetImage(post.imageUrl),
                          fit: BoxFit.cover,
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
              padding: EdgeInsets.only(
                  bottom: r == rowsData.length - 1 ? 0 : spacing),
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
          children: rows,
        );
      },
    );
  }

  Widget _buildActionsCard() {
    return SizedBox(
      width: 481,
      height: 54,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _assetIconButton(
              assetPath: 'assets/images/post/favorite.png',
              size: 24,
              onTap: () {
                final AuthState auth = AuthScope.of(context);
                if (!auth.isLoggedIn) {
                  setState(() {
                    _showSignInPopup = true;
                  });
                  return;
                }
                setState(() {
                  _liked = !_liked;
                  _likeCount += _liked ? 1 : -1;
                });
              },
              tooltip: 'Like',
            ),
            const SizedBox(width: 8),
            Text('$_likeCount',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            _assetIconButton(
              assetPath: 'assets/images/post/View.png',
              size: 24,
              onTap: () {},
              tooltip: 'Views',
            ),
            const SizedBox(width: 8),
            Text('$_viewCount',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            _assetIconButton(
              assetPath: 'assets/images/post/Share.png',
              size: 24,
              onTap: () {
                final AuthState auth = AuthScope.of(context);
                if (!auth.isLoggedIn) {
                  setState(() {
                    _showSignInPopup = true;
                  });
                  return;
                }
              },
              tooltip: 'Share',
            ),
            const SizedBox(width: 12),
            _assetIconButton(
              assetPath: 'assets/images/post/bookmark.png',
              size: 24,
              onTap: () {
                final AuthState auth = AuthScope.of(context);
                if (!auth.isLoggedIn) {
                  setState(() {
                    _showSignInPopup = true;
                  });
                  return;
                }
                setState(() {
                  _bookmarked = !_bookmarked;
                });
              },
              tooltip: 'Bookmark',
            ),
            const SizedBox(width: 12),
            _assetIconButton(
              assetPath: 'assets/images/post/Wardrobe.png',
              size: 24,
              onTap: () {
                final AuthState auth = AuthScope.of(context);
                if (!auth.isLoggedIn) {
                  setState(() {
                    _showSignInPopup = true;
                  });
                  return;
                }
                setState(() {
                  _inWardrobe = !_inWardrobe;
                });
              },
              tooltip: 'Wardrobe',
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetIconButton({
    required String assetPath,
    required double size,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.image_outlined, size: size, color: Colors.black54);
      },
    );
    final Widget button = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: image,
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: button);
    }
    return button;
  }
}

extension _WithScrollConfig on Widget {
  Widget letWithScrollConfig() {
    return ScrollConfiguration(
      behavior: const _DragScrollBehavior(),
      child: this,
    );
  }
}
