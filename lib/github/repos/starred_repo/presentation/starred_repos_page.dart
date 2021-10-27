import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repvu/github/core/shared/providers.dart';

import '../../../../auth/shared/providers.dart';
import 'paginated_repos_list_view.dart';

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
      appBar: AppBar(
        title: const Center(
          child: Text('Starred Repos'),
        ),
        actions: [
          IconButton(
            icon: const Icon(MdiIcons.logout),
            onPressed: () {
              // watch(authNotifierProvider.notifier).signOut();
              context.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: const PaginatedReposListView(),
    );
  }
}
