import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/explore_repository.dart' as svc;

final exploreRepositoryProvider = Provider<svc.ExploreRepository>((ref) {
  // TODO: 切换为真实实现时在此替换
  return const svc.MockExploreRepository();
});


