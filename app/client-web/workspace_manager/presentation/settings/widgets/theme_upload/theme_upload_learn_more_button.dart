import '../../../../../../../appflowy/core/helpers/url_launcher.dart';
import '../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../appflowy/shared/error_page/error_page.dart';
import '../../../../../../../appflowy/workspace/presentation/settings/widgets/theme_upload/theme_upload_view.dart';
import '../../../../../../../appflowy/workspace/presentation/widgets/dialogs.dart';
import '../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../flowy_infra/theme_extension.dart';
import '../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../flowy_infra_ui/widget/buttons/secondary_button.dart';
import '../../../../../../../flutter/material.dart';

class ThemeUploadLearnMoreButton extends StatelessWidget {
  const ThemeUploadLearnMoreButton({super.key});

  static const learnMoreURL =
      'https://docs.appflowy.io/docs/appflowy/product/themes';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ThemeUploadWidget.buttonSize.height,
      child: IntrinsicWidth(
        child: SecondaryButton(
          outlineColor: AFThemeExtension.of(context).onBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FlowyText.medium(
              fontSize: ThemeUploadWidget.buttonFontSize,
              LocaleKeys.document_plugins_autoGeneratorLearnMore.tr(),
            ),
          ),
          onPressed: () async {
            final uri = Uri.parse(learnMoreURL);
            await afLaunchUri(
              uri,
              context: context,
              onFailure: (_) async {
                if (context.mounted) {
                  await Dialogs.show(
                    context,
                    child: FlowyDialog(
                      child: FlowyErrorPage.message(
                        LocaleKeys
                            .settings_appearance_themeUpload_urlUploadFailure
                            .tr()
                            .replaceAll(
                              '{}',
                              uri.toString(),
                            ),
                        howToFix: LocaleKeys.errorDialog_howToFixFallback.tr(),
                      ),
                    ),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
