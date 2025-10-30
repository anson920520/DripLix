import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/explore_repository.dart' as svc;

part 'explore_usecase.g.dart';

class ExploreUseCase {
  final svc.ExploreRepository _repo;
  const ExploreUseCase(this._repo);

  Future<List<svc.OotdItem>> fetchOotd({int page = 1, int pageSize = 12}) =>
      _repo.fetchOotd(page: page, pageSize: pageSize);

  Future<List<svc.ExplorePost>> fetchFeed({int page = 1, int pageSize = 30}) =>
      _repo.fetchFeed(page: page, pageSize: pageSize);

  Future<List<svc.ExplorePost>> fetchFollowing({int page = 1, int pageSize = 30}) =>
      _repo.fetchFollowing(page: page, pageSize: pageSize);

  Future<svc.PostDetail> fetchPost(String id) => _repo.fetchPost(id);
}

@riverpod
ExploreUseCase exploreUseCase(Ref ref) {
  final svc.ExploreRepository repo = ref.read(svc.exploreRepositoryProvider);
  return ExploreUseCase(repo);
}


