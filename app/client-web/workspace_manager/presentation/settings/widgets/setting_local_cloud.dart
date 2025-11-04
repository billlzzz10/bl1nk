import '../../../../../../appflowy/env/cloud_env.dart';
import '../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../appflowy/workspace/presentation/settings/widgets/_restart_app_button.dart';
import '../../../../../../appflowy/workspace/presentation/widgets/dialogs.dart';
import '../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../flutter/material.dart';

class SettingLocalCloud extends StatelessWidget {
  const SettingLocalCloud({super.key, required this.restartAppFlowy});

  final VoidCallback restartAppFlowy;

  @override
  Widget build(BuildContext context) {
    return RestartButton(
      onClick: () => onPressed(context),
      showRestartHint: true,
    );
  }

  void onPressed(BuildContext context) {
    NavigatorAlertDialog(
      title: LocaleKeys.settings_menu_restartAppTip.tr(),
      confirm: () async {
        await useLocalServer();
        restartAppFlowy();
      },
    ).show(context);
  }
}
