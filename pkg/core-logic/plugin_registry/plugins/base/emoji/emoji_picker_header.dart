import '../../../../../../appflowy/plugins/document/presentation/editor_plugins/base/string_extension.dart';
import '../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../flutter/material.dart';
import '../../../../../../flutter_emoji_mart/flutter_emoji_mart.dart';
import '../../../../../../universal_platform/universal_platform.dart';

class FlowyEmojiHeader extends StatelessWidget {
  const FlowyEmojiHeader({
    super.key,
    required this.category,
  });

  final Category category;

  @override
  Widget build(BuildContext context) {
    if (UniversalPlatform.isDesktop) {
      return Container(
        height: 22,
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: FlowyText.regular(
            category.id.capitalize(),
            color: Theme.of(context).hintColor,
          ),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 14.0,
                bottom: 4.0,
              ),
              child: FlowyText.regular(category.id),
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
        ],
      );
    }
  }
}
