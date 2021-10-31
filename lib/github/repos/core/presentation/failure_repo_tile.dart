import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/domain/github_failure.dart';
import 'paginated_repos_list_view.dart';

class FailureRepoTile extends ConsumerWidget {
  const FailureRepoTile({
    Key? key,
    required this.failure,
  }) : super(key: key);

  final GithubFailure failure;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return ListTileTheme(
      textColor: Theme.of(context).colorScheme.onError,
      iconColor: Theme.of(context).colorScheme.onError,
      child: Card(
        color: Theme.of(context).errorColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          title: const Text('An error occurred. Please try again.'),
          subtitle: Text(
            failure.map(api: (_) => 'Error: ${_.errorCode}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const SizedBox(
            height: double.infinity,
            child: Icon(
              Icons.error,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .findAncestorWidgetOfExactType<PaginatedReposListView>()
                  ?.getNextPage(watch);
            },
          ),
        ),
      ),
    );
  }
}
