import '../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../appflowy/mobile/application/mobile_router.dart';
import '../../../../../../appflowy/startup/startup.dart';
import '../../../../../../appflowy/workspace/application/tabs/tabs_bloc.dart';
import '../../../../../../appflowy/workspace/application/view/view_ext.dart';
import '../../../../../../appflowy/workspace/presentation/widgets/dialogs.dart';
import '../../../../../../appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import '../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../flutter/material.dart';
import '../../../../../../universal_platform/universal_platform.dart';

/// Opens a message in the right hand sidebar on desktop, and push the page
/// on mobile
void openPageFromMessage(BuildContext context, ViewPB? view) {
  if (view == null) {
    showToastNotification(
      message: LocaleKeys.chat_openPagePreviewFailedToast.tr(),
      type: ToastificationType.error,
    );
    return;
  }
  if (UniversalPlatform.isDesktop) {
    getIt<TabsBloc>().add(
      TabsEvent.openSecondaryPlugin(
        plugin: view.plugin(),
      ),
    );
  } else {
    context.pushView(view);
  }
}

void showSaveMessageSuccessToast(BuildContext context, ViewPB? view) {
  if (view == null) {
    return;
  }
  showToastNotification(
    richMessage: TextSpan(
      children: [
        TextSpan(
          text: LocaleKeys.chat_addToNewPageSuccessToast.tr(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFFFFFF),
              ),
        ),
        const TextSpan(
          text: ' ',
        ),
        TextSpan(
          text: view.nameOrDefault,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    ),
  );
}
