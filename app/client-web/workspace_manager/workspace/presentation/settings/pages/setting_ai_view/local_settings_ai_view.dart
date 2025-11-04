import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/workspace/application/settings/ai/settings_ai_bloc.dart';
import '../../../../../../../../appflowy/workspace/presentation/settings/pages/setting_ai_view/local_ai_setting.dart';
import '../../../../../../../../appflowy/workspace/presentation/settings/shared/settings_body.dart';
import '../../../../../../../../appflowy_backend/protobuf/flowy-user/protobuf.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flutter/material.dart';
import '../../../../../../../../flutter_bloc/flutter_bloc.dart';

class LocalSettingsAIView extends StatelessWidget {
  const LocalSettingsAIView({
    super.key,
    required this.userProfile,
    required this.workspaceId,
  });

  final UserProfilePB userProfile;
  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsAIBloc>(
      create: (_) => SettingsAIBloc(userProfile, workspaceId)
        ..add(const SettingsAIEvent.started()),
      child: SettingsBody(
        title: LocaleKeys.settings_aiPage_title.tr(),
        description: "",
        children: [
          const LocalAISetting(),
        ],
      ),
    );
  }
}
