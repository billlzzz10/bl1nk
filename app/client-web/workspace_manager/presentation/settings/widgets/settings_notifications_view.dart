import '../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../appflowy/workspace/application/settings/notifications/notification_settings_cubit.dart';
import '../../../../../../appflowy/workspace/presentation/settings/shared/setting_list_tile.dart';
import '../../../../../../appflowy/workspace/presentation/settings/shared/settings_body.dart';
import '../../../../../../appflowy/workspace/presentation/widgets/toggle/toggle.dart';
import '../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../flutter/material.dart';
import '../../../../../../flutter_bloc/flutter_bloc.dart';

class SettingsNotificationsView extends StatelessWidget {
  const SettingsNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
      builder: (context, state) {
        return SettingsBody(
          title: LocaleKeys.settings_menu_notifications.tr(),
          children: [
            SettingListTile(
              label: LocaleKeys.settings_notifications_enableNotifications_label
                  .tr(),
              hint: LocaleKeys.settings_notifications_enableNotifications_hint
                  .tr(),
              trailing: [
                Toggle(
                  value: state.isNotificationsEnabled,
                  onChanged: (_) => context
                      .read<NotificationSettingsCubit>()
                      .toggleNotificationsEnabled(),
                ),
              ],
            ),
            SettingListTile(
              label: LocaleKeys
                  .settings_notifications_showNotificationsIcon_label
                  .tr(),
              hint: LocaleKeys.settings_notifications_showNotificationsIcon_hint
                  .tr(),
              trailing: [
                Toggle(
                  value: state.isShowNotificationsIconEnabled,
                  onChanged: (_) => context
                      .read<NotificationSettingsCubit>()
                      .toggleShowNotificationIconEnabled(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
