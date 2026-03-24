import 'package:flutter/material.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MoveSmart());
}

class MoveSmart extends StatelessWidget {
  const MoveSmart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Move Smart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login:   (context) => const Placeholder(),
        AppRoutes.home:    (context) => const Placeholder(),
        AppRoutes.profile: (context) => const Placeholder(),
      },
    );
  }
}
