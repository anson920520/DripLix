import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'explore_repository.g.dart';

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
  final String title;
  final String userName;

  const ExplorePost({
    required this.id,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.title,
    required this.userName,
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

  static List<ExplorePost>? _cachedPosts;

  Future<List<ExplorePost>> _loadMockPosts() async {
    if (_cachedPosts != null) return _cachedPosts!;
    final String jsonString =
        await rootBundle.loadString('assets/getAllMockPost.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    // Support two shapes: {posts: [...]} or legacy {data:{products:[...]}}
    List<dynamic>? raw = data['posts'] as List<dynamic>?;
    raw ??= (data['data'] != null && data['data']['products'] is List)
        ? (data['data']['products'] as List<dynamic>)
        : <dynamic>[];
    _cachedPosts = raw.map((dynamic it) {
      final Map<String, dynamic> m = it as Map<String, dynamic>;
      // Normalize keys
      final String image = (m['imageUrl'] ?? m['image_url']) as String;
      final int w = (m['width'] as num?)?.toInt() ?? 1000;
      final int h = (m['height'] as num?)?.toInt() ?? 1000;
      return ExplorePost(
        id: (m['id'] as String?) ?? (m['postId'] as String? ?? 'post_${raw!.indexOf(it)}'),
        imageUrl: image,
        width: w,
        height: h,
        title: (m['title'] as String?) ?? (m['postName'] as String? ?? ''),
        userName: (m['userName'] as String?) ?? (m['user'] as String? ?? 'user'),
      );
    }).toList();
    return _cachedPosts!;
  }

  @override
  Future<List<OotdItem>> fetchOotd({int page = 1, int pageSize = 12}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final List<ExplorePost> posts = await _loadMockPosts();
    final List<ExplorePost> slice = _slice(posts, page, pageSize);
    return slice
        .map((p) => OotdItem(id: p.id, imageUrl: p.imageUrl, width: p.width, height: p.height))
        .toList();
  }

  @override
  Future<List<ExplorePost>> fetchFeed({int page = 1, int pageSize = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final List<ExplorePost> posts = await _loadMockPosts();
    return _slice(posts, page, pageSize);
  }

  @override
  Future<List<ExplorePost>> fetchFollowing(
      {int page = 1, int pageSize = 30}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final List<ExplorePost> posts = await _loadMockPosts();
    return _slice(posts, page, pageSize);
  }

  @override
  Future<PostDetail> fetchPost(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final List<ExplorePost> posts = await _loadMockPosts();
    final ExplorePost p = posts.firstWhere((e) => e.id == postId,
        orElse: () => posts.first);
    return PostDetail(
      id: p.id,
      imageUrls: <String>[p.imageUrl],
      userName: p.userName,
      userAvatarUrl: 'assets/images/post/Generic avatar.png',
      title: p.title,
      text: 'Mock content for ${p.title} by ${p.userName}. Replace with API.',
    );
  }

  List<T> _slice<T>(List<T> items, int page, int pageSize) {
    final int start = (page - 1) * pageSize;
    if (start >= items.length) return <T>[];
    final int end = (start + pageSize).clamp(0, items.length);
    return items.sublist(start, end);
  }
}

@riverpod
ExploreRepository exploreRepository(Ref ref) {
  // TODO: 当真实 API 可用时，替换为真实实现
  return const MockExploreRepository();
}
