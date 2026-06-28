import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'settings_bloc.freezed.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<SettingsLoadRequested>(_onLoadRequested);
    on<SettingsThemeChanged>(_onThemeChanged);
    on<SettingsNotificationsToggled>(_onNotificationsToggled);
    on<SettingsSyncToggled>(_onSyncToggled);
  }

  Future<void> _onLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    // TODO: Load settings from repository
    emit(state.copyWith(isLoading: false));
  }

  void _onThemeChanged(
    SettingsThemeChanged event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(themeMode: event.themeMode));
    // TODO: Save to repository
  }

  void _onNotificationsToggled(
    SettingsNotificationsToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(notificationsEnabled: !state.notificationsEnabled));
    // TODO: Save to repository
  }

  void _onSyncToggled(
    SettingsSyncToggled event,
    Emitter<SettingsState> emit,
  ) {
    emit(state.copyWith(syncWithGoogleCalendar: !state.syncWithGoogleCalendar));
    // TODO: Save to repository
  }
}

@Freezed(fromJson: false, toJson: false)
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.loadRequested() = SettingsLoadRequested;
  const factory SettingsEvent.themeChanged(ThemeMode themeMode) = SettingsThemeChanged;
  const factory SettingsEvent.notificationsToggled() = SettingsNotificationsToggled;
  const factory SettingsEvent.syncToggled() = SettingsSyncToggled;
}

@Freezed(fromJson: false, toJson: false)
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool syncWithGoogleCalendar,
    @Default(15) int reminderMinutes,
    @Default(true) bool isLoading,
  }) = _SettingsState;
}
