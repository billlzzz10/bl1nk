import '../../../../../../../../flutter/material.dart';

import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import '../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/button.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/text.dart';

class RemoveCalculationButton extends StatelessWidget {
  const RemoveCalculationButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GridSize.popoverItemHeight,
      child: FlowyButton(
        text: FlowyText(
          LocaleKeys.grid_calculationTypeLabel_none.tr(),
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          onTap();
          PopoverContainer.of(context).close();
        },
      ),
    );
  }
}
