import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/shared/providers.dart';

class StarredReposPage extends ConsumerWidget {
  const StarredReposPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // watch(authNotifierProvider.notifier).signOut();
            context.read(authNotifierProvider.notifier).signOut();
          },
          child: const Text('Sign out'),
        ),
      ),
    );
  }
}
