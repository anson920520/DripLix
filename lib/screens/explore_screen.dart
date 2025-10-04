import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/navigation_bar.dart';
import '../widgets/signin_popup.dart';
import '../widgets/signup_popup.dart';
import '../services/explore_repository.dart';
import 'post_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isListUnfolded = false;
  String? _hoveredItem;
  bool _showSignUpPopup = false;
  bool _showSignInPopup = false;

  final ExploreRepository _repository = const MockExploreRepository();

  final List<OotdItem> _ootdItems = <OotdItem>[];
  final List<ExplorePost> _feedPosts = <ExplorePost>[];
  bool _isLoadingOotd = false;
  bool _isLoadingFeed = false;
  int _ootdPage = 1;
  int _feedPage = 1;
  static const int _ootdPageSize = 12;
  static const int _feedPageSize = 30;

  // No initState required for fixed sizes
  @override
  void initState() {
    super.initState();
    _loadInitial();
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

  @override
  Widget build(BuildContext context) {
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
                              'New drops For Your Fits',
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
                              const int crossAxisCount = 4;
                              final double spacing = 16;
                              final double tileWidth = (availableWidth -
                                      (spacing * (crossAxisCount - 1))) /
                                  crossAxisCount;
                              final double tileHeight = tileWidth * 1.2;
                              final int paddedCount = _feedPosts.isEmpty
                                  ? 0
                                  : ((_feedPosts.length + crossAxisCount - 1) ~/
                                          crossAxisCount) *
                                      crossAxisCount;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: spacing,
                                  crossAxisSpacing: spacing,
                                  childAspectRatio: tileWidth / tileHeight,
                                ),
                                itemCount: paddedCount,
                                itemBuilder: (context, index) {
                                  final int safeLength = _feedPosts.length;
                                  final String asset =
                                      _feedPosts[index % safeLength].imageUrl;
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PostScreen(
                                              postId:
                                                  _feedPosts[index % safeLength]
                                                      .id),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          image: DecorationImage(
                                            image: AssetImage(asset),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
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
                                onPressed: _isLoadingFeed
                                    ? null
                                    : () => _loadMoreFeed(),
                                child: _isLoadingFeed
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
          if (_isListUnfolded)
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
        const double aspect = 1.3; // fixed width for OOTD cards
        final double itemWidth = itemHeight * aspect;
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(scrollbars: false),
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
                      onPressed: _isLoadingOotd ? null : () => _loadMoreOotd(),
                      child: _isLoadingOotd
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('More'),
                    ),
                  ),
                );
              }
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PostScreen(postId: _ootdItems[index].id),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: Image.asset(
                      _ootdItems[index].imageUrl,
                      fit: BoxFit.cover,
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
              );
            },
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
              Navigator.of(context).pushNamed('/');
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
