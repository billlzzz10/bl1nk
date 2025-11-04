import '../../../../../../../../appflowy/core/helpers/url_launcher.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/copy_and_paste/clipboard_service.dart';
import '../../../../../../../../appflowy/plugins/shared/share/constants.dart';
import '../../../../../../../../appflowy/startup/startup.dart';
import '../../../../../../../../appflowy/workspace/presentation/widgets/dialogs.dart';
import '../../../../../../../../appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flutter/material.dart';

class SettingsPageSitesConstants {
  static const threeDotsButtonWidth = 26.0;
  static const alignPadding = 6.0;

  static final dateFormat = DateFormat('MMM d, yyyy');

  static final publishedViewHeaderTitles = [
    LocaleKeys.settings_sites_publishedPage_page.tr(),
    LocaleKeys.settings_sites_publishedPage_pathName.tr(),
    LocaleKeys.settings_sites_publishedPage_date.tr(),
  ];

  static final namespaceHeaderTitles = [
    LocaleKeys.settings_sites_namespaceHeader.tr(),
    LocaleKeys.settings_sites_homepageHeader.tr(),
  ];

  // the published view name is longer than the other two, so we give it more flex
  static final publishedViewItemFlexes = [1, 1, 1];
}

class SettingsPageSitesEvent {
  static void visitSite(
    PublishInfoViewPB publishInfoView, {
    String? nameSpace,
  }) {
    // visit the site
    final url = ShareConstants.buildPublishUrl(
      nameSpace: nameSpace ?? publishInfoView.info.namespace,
      publishName: publishInfoView.info.publishName,
    );
    afLaunchUrlString(url);
  }

  static void copySiteLink(
    BuildContext context,
    PublishInfoViewPB publishInfoView, {
    String? nameSpace,
  }) {
    final url = ShareConstants.buildPublishUrl(
      nameSpace: nameSpace ?? publishInfoView.info.namespace,
      publishName: publishInfoView.info.publishName,
    );
    getIt<ClipboardService>().setData(ClipboardServiceData(plainText: url));
    showToastNotification(
      message: LocaleKeys.message_copy_success.tr(),
    );
  }
}
