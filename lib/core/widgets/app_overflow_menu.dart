import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../constants/app_routes.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class AppOverflowMenu extends StatelessWidget {
  const AppOverflowMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.home:
            Navigator.pushNamed(context, AppRoutes.home);
            break;
          case _MenuAction.profile:
            Navigator.pushNamed(context, AppRoutes.profile);
            break;
          case _MenuAction.settings:
            Navigator.pushNamed(context, AppRoutes.settings);
            break;
          case _MenuAction.logout:
            context.read<AuthBloc>().add(SignOutRequested());
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _MenuAction.home,
          child: ListTile(
            leading: Icon(Icons.home_outlined),
            title: Text('Home'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.profile,
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Profile'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.settings,
          child: ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _MenuAction.logout,
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

enum _MenuAction { home, profile, settings, logout }
