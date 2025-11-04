import 'dart:async';

import '../../../../../../appflowy/core/config/kv.dart';
import '../../../../../../appflowy/core/config/kv_keys.dart';
import '../../../../../../appflowy/startup/startup.dart';
import '../../../../../../appflowy/user/application/user_settings_service.dart';
import '../../../../../../appflowy_backend/log.dart';
import '../../../../../../appflowy_backend/protobuf/flowy-user/user_setting.pb.dart';
import '../../../../../../flutter_bloc/flutter_bloc.dart';
import '../../../../../../freezed_annotation/freezed_annotation.dart';

part 'notification_settings_cubit.freezed.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  NotificationSettingsCubit() : super(NotificationSettingsState.initial()) {
    _initialize();
  }

  final Completer<void> _initCompleter = Completer();

  late final NotificationSettingsPB _notificationSettings;

  Future<void> _initialize() async {
    _notificationSettings =
        await UserSettingsBackendService().getNotificationSettings();

    final showNotificationSetting = await getIt<KeyValueStorage>()
        .getWithFormat(KVKeys.showNotificationIcon, (v) => bool.parse(v));

    emit(
      state.copyWith(
        isNotificationsEnabled: _notificationSettings.notificationsEnabled,
        isShowNotificationsIconEnabled: showNotificationSetting ?? true,
      ),
    );

    _initCompleter.complete();
  }

  Future<void> toggleNotificationsEnabled() async {
    await _initCompleter.future;

    _notificationSettings.notificationsEnabled = !state.isNotificationsEnabled;

    emit(
      state.copyWith(
        isNotificationsEnabled: _notificationSettings.notificationsEnabled,
      ),
    );

    await _saveNotificationSettings();
  }

  Future<void> toggleShowNotificationIconEnabled() async {
    await _initCompleter.future;

    emit(
      state.copyWith(
        isShowNotificationsIconEnabled: !state.isShowNotificationsIconEnabled,
      ),
    );
  }

  Future<void> _saveNotificationSettings() async {
    await _initCompleter.future;

    await getIt<KeyValueStorage>().set(
      KVKeys.showNotificationIcon,
      state.isShowNotificationsIconEnabled.toString(),
    );

    final result = await UserSettingsBackendService()
        .setNotificationSettings(_notificationSettings);
    result.fold(
      (r) => null,
      (error) => Log.error(error),
    );
  }
}

@freezed
class NotificationSettingsState with _$NotificationSettingsState {
  const NotificationSettingsState._();

  const factory NotificationSettingsState({
    required bool isNotificationsEnabled,
    required bool isShowNotificationsIconEnabled,
  }) = _NotificationSettingsState;

  factory NotificationSettingsState.initial() =>
      const NotificationSettingsState(
        isNotificationsEnabled: true,
        isShowNotificationsIconEnabled: true,
      );
}
