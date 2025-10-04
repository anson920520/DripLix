import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/navigation_bar.dart';
import '../services/explore_repository.dart';

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
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          CustomNavigationBar(
            isListUnfolded: false,
            onListToggle: () {},
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              'Explore more',
                              style: GoogleFonts.notoSerif(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        _buildExploreMoreGrid(),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
    );
  }

  Widget _buildPostCard() {
    return Container(
      width: 900,
      height: 540,
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
              width: 320,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 320,
                      height: 480,
                      child: PageView.builder(
                        itemCount: _detail!.imageUrls.length,
                        onPageChanged: (int idx) {
                          setState(() {
                            _currentIndex = idx;
                          });
                        },
                        itemBuilder: (context, index) {
                          final String url = _detail!.imageUrls[index];
                          return Image.asset(
                            url,
                            width: 320,
                            height: 480,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image,
                                      color: Colors.black45),
                                ),
                              );
                            },
                          );
                        },
                      ).letWithScrollConfig(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(_detail!.imageUrls.length,
                        (int i) {
                      final bool active = i == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                          radius: 24,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: const AssetImage(
                              'assets/images/post/Generic avatar.png'),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _detail!.userName,
                          style: GoogleFonts.notoSerif(
                            fontSize: 18,
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

  Widget _buildExploreMoreGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth;
        const int crossAxisCount = 4;
        final double spacing = 16;
        final double tileWidth =
            (availableWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;
        final double tileHeight = tileWidth * 1.2;
        final int paddedCount = _morePosts.isEmpty
            ? 0
            : ((_morePosts.length + crossAxisCount - 1) ~/ crossAxisCount) *
                crossAxisCount;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: tileWidth / tileHeight,
          ),
          itemCount: paddedCount,
          itemBuilder: (context, index) {
            final int safeLength = _morePosts.length;
            final String asset = _morePosts[index % safeLength].imageUrl;
            return ClipRRect(
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
            );
          },
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
              onTap: () {},
              tooltip: 'Share',
            ),
            const SizedBox(width: 12),
            _assetIconButton(
              assetPath: 'assets/images/post/bookmark.png',
              size: 24,
              onTap: () {
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
