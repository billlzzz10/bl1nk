import '../../../../../../../appflowy/env/cloud_env.dart';
import '../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../appflowy/startup/startup.dart';
import '../../../../../../../appflowy/user/application/sign_in_bloc.dart';
import '../../../../../../../appflowy/user/presentation/screens/sign_in_screen/widgets/widgets.dart';
import '../../../../../../../appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import '../../../../../../../appflowy_backend/protobuf/flowy-user/user_profile.pb.dart';
import '../../../../../../../appflowy_result/appflowy_result.dart';
import '../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../flowy_infra_ui/style_widget/snap_bar.dart';
import '../../../../../../../flutter/material.dart';
import '../../../../../../../flutter_bloc/flutter_bloc.dart';

class SettingThirdPartyLogin extends StatelessWidget {
  const SettingThirdPartyLogin({
    super.key,
    required this.didLogin,
  });

  final VoidCallback didLogin;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SignInBloc>(),
      child: BlocConsumer<SignInBloc, SignInState>(
        listener: (context, state) {
          final successOrFail = state.successOrFail;
          if (successOrFail != null) {
            _handleSuccessOrFail(successOrFail, context);
          }
        },
        builder: (_, state) {
          final indicator = state.isSubmitting
              ? const LinearProgressIndicator(minHeight: 1)
              : const SizedBox.shrink();

          final promptMessage = state.isSubmitting
              ? FlowyText.medium(
                  LocaleKeys.signIn_syncPromptMessage.tr(),
                  maxLines: null,
                )
              : const SizedBox.shrink();

          return Column(
            children: [
              promptMessage,
              const VSpace(6),
              indicator,
              const VSpace(6),
              if (isAuthEnabled) const ThirdPartySignInButtons(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleSuccessOrFail(
    FlowyResult<UserProfilePB, FlowyError> result,
    BuildContext context,
  ) async {
    result.fold(
      (user) async {
        didLogin();
        await runAppFlowy();
      },
      (error) => showSnapBar(context, error.msg),
    );
  }
}
