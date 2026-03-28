import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_overflow_menu.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text(
          AppStrings.tagline,
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [AppOverflowMenu()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name =
                    state is AuthSuccess ? state.user.fullName : 'Rider';
                return Text(
                  'Hi, $name!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.subTagline,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  _InputHint(label: AppStrings.yourLocation),
                  SizedBox(height: 10),
                  _InputHint(label: AppStrings.whereGoing),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: AppColors.white,
                ),
                child: const Text(AppStrings.planMyTrip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputHint extends StatelessWidget {
  const _InputHint({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final hintColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: hintColor, size: 18),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: hintColor)),
      ],
    );
  }
}
