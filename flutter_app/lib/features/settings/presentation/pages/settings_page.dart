import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/settings_bloc.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsBloc>()..add(const SettingsLoadRequested()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              _buildSection(
                context,
                title: 'Appearance',
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    subtitle: Text(_themeModeLabel(state.themeMode)),
                    onTap: () => _showThemeDialog(context, state.themeMode),
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Notifications',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications),
                    title: const Text('Enable Notifications'),
                    subtitle: const Text('Receive task reminders'),
                    value: state.notificationsEnabled,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(
                            const SettingsNotificationsToggled(),
                          );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.timer),
                    title: const Text('Reminder Time'),
                    subtitle: Text('${state.reminderMinutes} minutes before'),
                    enabled: state.notificationsEnabled,
                    onTap: state.notificationsEnabled
                        ? () => _showReminderDialog(context)
                        : null,
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Sync',
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.sync),
                    title: const Text('Google Calendar Sync'),
                    subtitle: const Text('Sync tasks with Google Calendar'),
                    value: state.syncWithGoogleCalendar,
                    onChanged: (_) {
                      context.read<SettingsBloc>().add(
                            const SettingsSyncToggled(),
                          );
                    },
                  ),
                ],
              ),
              _buildSection(
                context,
                title: 'Account',
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () => _showSignOutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeLabel(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  context.read<SettingsBloc>().add(
                        SettingsThemeChanged(value),
                      );
                  Navigator.pop(dialogContext);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    // TODO: Implement reminder time picker
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthSignOutPressed());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
