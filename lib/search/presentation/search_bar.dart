import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '../shared/providers.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({
    Key? key,
    required this.title,
    required this.hint,
    required this.body,
    required this.onShouldNavigateToResultPage,
    required this.onSignOutButtonPressed,
  }) : super(key: key);

  final String title;
  final String hint;
  final Widget body;
  final void Function(String searchTerm) onShouldNavigateToResultPage;
  final void Function() onSignOutButtonPressed;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late FloatingSearchBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloatingSearchBarController();

    Future.microtask(
      () => context
          .read(searchHistoryNotifierProvider.notifier)
          .watchSearchTerms(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void pushPageAndPutFirstInHistory(String searchTerm, ScopedReader watch) {
      widget.onShouldNavigateToResultPage(searchTerm);
      watch(searchHistoryNotifierProvider.notifier)
          .putSearchTermFirst(searchTerm);
      _controller.close();
    }

    void pushPageAndAddToHistory(String searchTerm, ScopedReader watch) {
      widget.onShouldNavigateToResultPage(searchTerm);
      watch(searchHistoryNotifierProvider.notifier).addSearchTerm(searchTerm);
      _controller.close();
    }

    return Consumer(
      builder: (context, watch, child) {
        final searchHistoryState = watch(searchHistoryNotifierProvider);

        return FloatingSearchBar(
          controller: _controller,
          body: FloatingSearchBarScrollNotifier(
            child: widget.body,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'Tap to search',
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          hint: widget.hint,
          actions: [
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            ),
            FloatingSearchBarAction(
              child: IconButton(
                icon: const Icon(MdiIcons.logout),
                splashRadius: 18,
                onPressed: () {
                  widget.onSignOutButtonPressed();
                },
              ),
            ),
          ],
          onQueryChanged: (query) {
            watch(searchHistoryNotifierProvider.notifier)
                .watchSearchTerms(filter: query);
          },
          onSubmitted: (query) {
            pushPageAndAddToHistory(query, watch);
          },
          builder: (context, transition) {
            return Material(
              color: Theme.of(context).cardColor,
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8),
              clipBehavior: Clip.hardEdge,
              child: searchHistoryState.map(
                data: (history) {
                  if (_controller.query.isEmpty && history.value.isEmpty) {
                    return Container(
                      height: 56,
                      alignment: Alignment.center,
                      child: Text(
                        'Start searching',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  } else if (history.value.isEmpty) {
                    return ListTile(
                      title: Text(_controller.query),
                      leading: const Icon(Icons.search),
                      onTap: () {
                        pushPageAndAddToHistory(_controller.query, watch);
                      },
                    );
                  }
                  return Column(
                    children: history.value
                        .map(
                          (term) => ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(
                              term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                watch(searchHistoryNotifierProvider.notifier)
                                    .deleteSearchTerm(term);
                              },
                            ),
                            onTap: () {
                              pushPageAndPutFirstInHistory(term, watch);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
                loading: (_) => const ListTile(
                  title: LinearProgressIndicator(),
                ),
                error: (_) => ListTile(
                  title: Text('Unexpected error ${_.error}'),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
