import 'package:flutter/foundation.dart';

import '../../domain/explore_usecase.dart';
import '../../services/explore_repository.dart' as svc;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_viewmodel.g.dart';

@riverpod
class ExploreViewModel extends _$ExploreViewModel {

  int _feedPage = 1;
  int _followingPage = 1;
  static const int _pageSize = 30;
  bool _isFollowing = false;
  bool _isFetching = false;

  @override
  FutureOr<List<svc.ExplorePost>> build() async {
    return <svc.ExplorePost>[];
  }
  
  void showFollowing(bool following) {
    _isFollowing = following;
  }

  Future<void> refresh() async {
    if (_isFetching) return;
    _isFetching = true;
    state = const AsyncLoading();
    final ExploreUseCase useCase = ref.read(exploreUseCaseProvider);
    try {
      _feedPage = 1;
      _followingPage = 1;
      final List<svc.ExplorePost> items = _isFollowing
          ? await useCase.fetchFollowing(page: _followingPage, pageSize: _pageSize)
          : await useCase.fetchFeed(page: _feedPage, pageSize: _pageSize);
      if (_isFollowing) {
        _followingPage += 1;
      } else {
        _feedPage += 1;
      }
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError<List<svc.ExplorePost>>(e, st);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> loadMore() async {
    debugPrint('loadMore');
    debugPrint(state.value?.toString());
    if (_isFetching) return;
    _isFetching = true;
    final ExploreUseCase useCase = ref.read(exploreUseCaseProvider);
    final List<svc.ExplorePost> current = List<svc.ExplorePost>.of(state.value ?? <svc.ExplorePost>[]);
    try {
      final List<svc.ExplorePost> items = _isFollowing
          ? await useCase.fetchFollowing(page: _followingPage, pageSize: _pageSize)
          : await useCase.fetchFeed(page: _feedPage, pageSize: _pageSize);
      if (_isFollowing) {
        _followingPage += 1;
      } else {
        _feedPage += 1;
      }
      state = AsyncData(<svc.ExplorePost>[...current, ...items]);
    } catch (e, st) {
      state = AsyncError<List<svc.ExplorePost>>(e, st);
    } finally {
      _isFetching = false;
    }
  }
}

 
