import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../bloc/auth_bloc.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          authenticated: (_) {
            context.router.replace(const HomeRoute());
          },
          unauthenticated: () {
            context.router.replace(const LoginRoute());
          },
          error: (message) {
            context.router.replace(const LoginRoute());
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month,
                size: 80,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 24),
              Text(
                'Cronograma',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Actividades',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 48),
              const LoadingIndicator(
                size: 32,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
