import '../../../../../../../../flutter/material.dart';

import '../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/hover.dart';

class UnsupportedImageWidget extends StatelessWidget {
  const UnsupportedImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FlowyHover(
        style: HoverStyle(borderRadius: BorderRadius.circular(4)),
        child: SizedBox(
          height: 52,
          child: Row(
            children: [
              const HSpace(10),
              const FlowySvg(
                FlowySvgs.image_placeholder_s,
                size: Size.square(24),
              ),
              const HSpace(10),
              FlowyText(LocaleKeys.document_imageBlock_unableToLoadImage.tr()),
            ],
          ),
        ),
      ),
    );
  }
}
