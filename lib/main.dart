import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/presentation/app.dart';

void main() {
  runApp(
    ProviderScope(
      child: RepovuApp(),
    ),
  );
}
