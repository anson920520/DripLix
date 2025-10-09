import 'dart:async';

/// Simple models for Explore content. These can be expanded later by the backend dev.
class OotdItem {
  final String id;
  final String imageUrl; // Can be a network URL or an asset path
  final int width;
  final int height;

  const OotdItem({
    required this.id,
    required this.imageUrl,
    required this.width,
    required this.height,
  });
}

class ExplorePost {
  final String id;
  final String imageUrl; // Can be a network URL or an asset path
  final int width;
  final int height;

  const ExplorePost({
    required this.id,
    required this.imageUrl,
    required this.width,
    required this.height,
  });
}

class PostDetail {
  final String id;
  final List<String> imageUrls;
  final String userName;
  final String userAvatarUrl;
  final String title;
  final String text;

  const PostDetail({
    required this.id,
    required this.imageUrls,
    required this.userName,
    required this.userAvatarUrl,
    required this.title,
    required this.text,
  });
}

/// Repository interface to allow swapping implementations (mock vs real backend)
abstract class ExploreRepository {
  Future<List<OotdItem>> fetchOotd({int page = 1, int pageSize = 12});
  Future<List<ExplorePost>> fetchFeed({int page = 1, int pageSize = 30});
  Future<List<ExplorePost>> fetchFollowing({int page = 1, int pageSize = 30});
  Future<PostDetail> fetchPost(String postId);
}

/// Default mock implementation. Replace with real API client when ready.
class MockExploreRepository implements ExploreRepository {
  const MockExploreRepository();

  @override
  Future<List<OotdItem>> fetchOotd({int page = 1, int pageSize = 12}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Prefer wider presets for OOTD
    final List<List<int>> sizePresets = <List<int>>[
      <int>[1400, 900], // very wide
      <int>[1300, 900], // wide
      <int>[1200, 900], // wide
      <int>[1100, 900], // slightly wide
      <int>[1000, 900], // slightly wide
      <int>[900, 900], // square
      <int>[1000, 1000], // square
      <int>[1600, 900], // extra wide
      <int>[1500, 900], // extra wide
    ];
    return List<OotdItem>.generate(pageSize, (int index) {
      final bool even = (index + page) % 2 == 0;
      final String asset = even
          ? 'assets/images/homepage/carousel_template_image_1.png'
          : 'assets/images/homepage/carousel_template_image_2.png';
      final List<int> s = sizePresets[(index + page) % sizePresets.length];
      return OotdItem(
        id: 'ootd_${page}_$index',
        imageUrl: asset,
        width: s[0],
        height: s[1],
      );
    });
  }

  @override
  Future<List<ExplorePost>> fetchFeed({int page = 1, int pageSize = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Emit varied intrinsic sizes to drive layout decisions
    final List<List<int>> sizePresets = <List<int>>[
      <int>[800, 1200], // tall
      <int>[1200, 800], // wide
      <int>[1000, 1000], // square
      <int>[1400, 900], // very wide
      <int>[900, 1400], // very tall
      <int>[1100, 900], // slightly wide
      <int>[900, 1100], // slightly tall
    ];
    return List<ExplorePost>.generate(pageSize, (int index) {
      final bool even = (index + page) % 2 == 0;
      final String asset = even
          ? 'assets/images/homepage/carousel_template_image_1.png'
          : 'assets/images/homepage/carousel_template_image_2.png';
      final List<int> s = sizePresets[(index + page) % sizePresets.length];
      return ExplorePost(
        id: 'post_${page}_$index',
        imageUrl: asset,
        width: s[0],
        height: s[1],
      );
    });
  }

  @override
  Future<List<ExplorePost>> fetchFollowing(
      {int page = 1, int pageSize = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // Mock: Use same assets but different id prefix to distinguish
    final List<List<int>> sizePresets = <List<int>>[
      <int>[900, 1400],
      <int>[1200, 800],
      <int>[1000, 1000],
      <int>[1400, 900],
      <int>[800, 1200],
      <int>[1100, 900],
      <int>[900, 1100],
    ];
    return List<ExplorePost>.generate(pageSize, (int index) {
      final bool even = (index + page) % 2 == 0;
      final String asset = even
          ? 'assets/images/homepage/carousel_template_image_2.png'
          : 'assets/images/homepage/carousel_template_image_1.png';
      final List<int> s = sizePresets[(index + page) % sizePresets.length];
      return ExplorePost(
        id: 'following_${page}_$index',
        imageUrl: asset,
        width: s[0],
        height: s[1],
      );
    });
  }

  @override
  Future<PostDetail> fetchPost(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    // Return mock data based on id; in real impl, call API
    final bool even = postId.hashCode % 2 == 0;
    final List<String> images = even
        ? <String>[
            'assets/images/homepage/carousel_template_image_1.png',
            'assets/images/homepage/carousel_template_image_2.png',
          ]
        : <String>[
            'assets/images/homepage/carousel_template_image_2.png',
            'assets/images/homepage/carousel_template_image_1.png',
          ];
    return PostDetail(
      id: postId,
      imageUrls: images,
      userName: 'User $postId',
      userAvatarUrl: 'assets/images/post/Generic avatar.png',
      title: 'Title for $postId',
      text: 'This is mock post content for $postId. Replace with backend data.',
    );
  }
}
