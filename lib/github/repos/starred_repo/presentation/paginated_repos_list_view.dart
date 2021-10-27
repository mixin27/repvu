import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/presentation/toasts.dart';
import '../../../core/presentation/no_result_display.dart';
import '../../../core/shared/providers.dart';
import '../application/starred_repos_notifier.dart';
import 'failure_repo_tile.dart';
import 'loading_repo_tile.dart';
import 'repo_tile.dart';

class PaginatedReposListView extends StatefulWidget {
  const PaginatedReposListView({
    Key? key,
  }) : super(key: key);

  @override
  State<PaginatedReposListView> createState() => _PaginatedReposListViewState();
}

class _PaginatedReposListViewState extends State<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownNoConnectionToast = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final state = watch(starredReposNotifierProvider);

        watch<StarredReposState>(starredReposNotifierProvider).map(
          initial: (_) => canLoadNextPage = true,
          loadInProgress: (_) => canLoadNextPage = false,
          loadSuccess: (_) {
            if (!_.repos.isFresh && !hasAlreadyShownNoConnectionToast) {
              hasAlreadyShownNoConnectionToast = true;
              showNoConnectionToast(
                "You're not online. Some information may be outdated.",
                context,
              );
            }
            canLoadNextPage = _.isNextPageAvailbale;
          },
          loadFailure: (_) => canLoadNextPage = false,
        );

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            final limit =
                metrics.maxScrollExtent - metrics.viewportDimension / 3;

            if (canLoadNextPage && metrics.pixels >= limit) {
              canLoadNextPage = false;
              watch(starredReposNotifierProvider.notifier)
                  .getNextStarredReposPage();
            }
            return false;
          },
          child: state.maybeWhen(
            loadSuccess: (repos, _) => repos.entity.isEmpty,
            orElse: () => false,
          )
              ? const NoResultDisplay(
                  message:
                      "That's about everyting we could find in your starred repos right now.",
                )
              : _PaginatedListView(state: state),
        );
      },
    );
  }
}

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({
    Key? key,
    required this.state,
  }) : super(key: key);

  final StarredReposState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.map(
        initial: (_) => 0,
        loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
        loadSuccess: (_) => _.repos.entity.length,
        loadFailure: (_) => _.repos.entity.length + 1,
      ),
      itemBuilder: (context, index) {
        return state.map(
          initial: (_) => Container(),
          loadInProgress: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(
                repo: _.repos.entity[index],
              );
            } else {
              return const LoadingRepoTile();
            }
          },
          loadSuccess: (_) => RepoTile(
            repo: _.repos.entity[index],
          ),
          loadFailure: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(
                repo: _.repos.entity[index],
              );
            } else {
              return FailureRepoTile(
                failure: _.failure,
              );
            }
          },
        );
      },
    );
  }
}
