import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/domain/fresh.dart';
import '../../../core/domain/github_failure.dart';
import '../../../core/domain/github_repo.dart';
import '../../../core/infrastructure/pagination_config.dart';
import '../infrastructure/starred_repos_repository.dart';

part 'starred_repos_notifier.freezed.dart';

@freezed
class StarredReposState with _$StarredReposState {
  const StarredReposState._();
  const factory StarredReposState.initial(
    Fresh<List<GithubRepo>> repos,
  ) = _Initial;
  const factory StarredReposState.loadInProgress(
    Fresh<List<GithubRepo>> repos,
    int itemsPerPage,
  ) = _LoadInProgress;
  const factory StarredReposState.loadSuccess(
    Fresh<List<GithubRepo>> repos, {
    required bool isNextPageAvailbale,
  }) = _LoadSuccess;
  const factory StarredReposState.loadFailure(
    Fresh<List<GithubRepo>> repos,
    GithubFailure failure,
  ) = _LoadFailure;
}

class StarredReposNotifier extends StateNotifier<StarredReposState> {
  StarredReposNotifier(this._reposRepository)
      : super(StarredReposState.initial(Fresh.yes([])));

  final StarredReposRepository _reposRepository;
  int _page = 1;

  Future<void> getNextStarredReposPage() async {
    // state = StarredReposState.loadFailure(
    //   state.repos,
    //   const GithubFailure.api(404),
    // );

    state = StarredReposState.loadInProgress(
      state.repos,
      PaginationConfig.itemsPerPage,
    );

    final failureOrRepos = await _reposRepository.getStarredReposPage(_page);

    state = failureOrRepos.fold(
      (l) => StarredReposState.loadFailure(state.repos, l),
      (r) {
        _page++;
        return StarredReposState.loadSuccess(
          r.copyWith(
            entity: [
              ...state.repos.entity,
              ...r.entity,
            ],
          ),
          isNextPageAvailbale: r.isNextPageAvailable ?? false,
        );
      },
    );
  }
}
