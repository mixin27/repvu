import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth/application/auth_notifier.dart';
import '../../auth/shared/providers.dart';
import '../../core/presentation/routes/app_router.gr.dart';

final initializationProvider = FutureProvider<Unit>((ref) async {
  // we don't need to use watch()
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateAuthStatus();
  return unit;
});

class RepovuApp extends ConsumerWidget {
  RepovuApp({
    Key? key,
  }) : super(key: key);

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return ProviderListener(
      provider: initializationProvider,
      onChange: (context, value) {},
      child: ProviderListener<AuthState>(
        provider: authNotifierProvider,
        onChange: (context, state) {
          state.maybeMap(
            orElse: () {},
            authenticated: (_) {
              appRouter.pushAndPopUntil(
                const StarredReposRoute(),
                predicate: (route) => false,
              );
            },
            unauthenticated: (_) {
              appRouter.pushAndPopUntil(
                const SignInRoute(),
                predicate: (route) => false,
              );
            },
          );
        },
        child: MaterialApp.router(
          title: 'Repvu',
          routeInformationParser: appRouter.defaultRouteParser(),
          routerDelegate: appRouter.delegate(),
        ),
      ),
    );
  }
}
