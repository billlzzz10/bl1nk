import '../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../flowy_infra_ui/style_widget/text.dart';
import '../../../../../../flutter/material.dart';

class NotificationHubTitle extends StatelessWidget {
  const NotificationHubTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16) +
          const EdgeInsets.only(top: 12, bottom: 4),
      child: FlowyText.semibold(
        LocaleKeys.notificationHub_title.tr(),
        color: Theme.of(context).colorScheme.tertiary,
        fontSize: 16,
      ),
    );
  }
}
