import '../../../../../../../appflowy/workspace/presentation/widgets/date_picker/utils/layout.dart';
import '../../../../../../../flutter/material.dart';

import '../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../flowy_infra_ui/style_widget/button.dart';
import '../../../../../../../flowy_infra_ui/style_widget/text.dart';

class ClearDateButton extends StatelessWidget {
  const ClearDateButton({
    super.key,
    required this.onClearDate,
  });

  final VoidCallback onClearDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: DatePickerSize.itemHeight,
        child: FlowyButton(
          text: FlowyText(LocaleKeys.datePicker_clearDate.tr()),
          onTap: () {
            onClearDate();
            PopoverContainer.of(context).close();
          },
        ),
      ),
    );
  }
}
