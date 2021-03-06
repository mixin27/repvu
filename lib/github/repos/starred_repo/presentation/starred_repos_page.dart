import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../auth/shared/providers.dart';
import '../../../../core/presentation/routes/app_router.gr.dart';
import '../../../../search/presentation/search_bar.dart';
import '../../../core/shared/providers.dart';
import '../../core/presentation/paginated_repos_list_view.dart';

class StarredReposPage extends StatefulWidget {
  const StarredReposPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StarredReposPage> createState() => _StarredReposPageState();
}

class _StarredReposPageState extends State<StarredReposPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(
      () => context
          .read(starredReposNotifierProvider.notifier)
          .getNextStarredReposPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SearchBar(
        title: 'Starred Repos',
        hint: 'Search all repositories...',
        onSignOutButtonPressed: () {
          context.read(authNotifierProvider.notifier).signOut();
        },
        onShouldNavigateToResultPage: (searchTerm) {
          AutoRouter.of(context).push(
            SearchedReposRoute(searchTerm: searchTerm),
          );
        },
        body: PaginatedReposListView(
          paginatedReposNotifierProvider: starredReposNotifierProvider,
          getNextPage: (watch) {
            watch(starredReposNotifierProvider.notifier)
                .getNextStarredReposPage();
          },
          noResultMessage:
              "That's about everyting we could find in your starred repos right now.",
        ),
      ),
    );
  }
}
