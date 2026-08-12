import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'theme/kurama_theme.dart';
import 'app_router.dart';

/// Root widget. Receives an [AppScope] from [AppBootstrap] so all downstream
/// widgets can access typed dependencies without global state.
class KuramaApp extends StatelessWidget {
  final AppScope scope;

  const KuramaApp({super.key, required this.scope});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kurama App',
      debugShowCheckedModeBanner: false,
      theme: buildKuramaTheme(),
      darkTheme: buildKuramaTheme(),
      themeMode: ThemeMode.dark,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.home,
    );
  }
}
