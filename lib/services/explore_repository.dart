import 'dart:async';

/// Simple models for Explore content. These can be expanded later by the backend dev.
class OotdItem {
  final String id;
  final String imageUrl; // Can be a network URL or an asset path

  const OotdItem({required this.id, required this.imageUrl});
}

class ExplorePost {
  final String id;
  final String imageUrl; // Can be a network URL or an asset path

  const ExplorePost({required this.id, required this.imageUrl});
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
  Future<PostDetail> fetchPost(String postId);
}

/// Default mock implementation. Replace with real API client when ready.
class MockExploreRepository implements ExploreRepository {
  const MockExploreRepository();

  @override
  Future<List<OotdItem>> fetchOotd({int page = 1, int pageSize = 12}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Cycle placeholder assets
    return List<OotdItem>.generate(pageSize, (int index) {
      final bool even = (index + page) % 2 == 0;
      final String asset = even
          ? 'assets/images/homepage/carousel_template_image_1.png'
          : 'assets/images/homepage/carousel_template_image_2.png';
      return OotdItem(id: 'ootd_${page}_$index', imageUrl: asset);
    });
  }

  @override
  Future<List<ExplorePost>> fetchFeed({int page = 1, int pageSize = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<ExplorePost>.generate(pageSize, (int index) {
      final bool even = (index + page) % 2 == 0;
      final String asset = even
          ? 'assets/images/homepage/carousel_template_image_1.png'
          : 'assets/images/homepage/carousel_template_image_2.png';
      return ExplorePost(id: 'post_${page}_$index', imageUrl: asset);
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
      userAvatarUrl: 'assets/images/navigation/Driplix Logo.png',
      title: 'Title for $postId',
      text: 'This is mock post content for $postId. Replace with backend data.',
    );
  }
}
