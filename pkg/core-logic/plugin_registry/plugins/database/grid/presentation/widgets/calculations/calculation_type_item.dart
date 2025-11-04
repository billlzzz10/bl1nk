import '../../../../../../../../../flutter/material.dart';

import '../../../../../../../../../appflowy/plugins/database/application/calculations/calculation_type_ext.dart';
import '../../../../../../../../../appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import '../../../../../../../../../appflowy_backend/protobuf/flowy-database2/calculation_entities.pbenum.dart';
import '../../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../../flowy_infra_ui/style_widget/button.dart';
import '../../../../../../../../../flowy_infra_ui/style_widget/text.dart';

class CalculationTypeItem extends StatelessWidget {
  const CalculationTypeItem({
    super.key,
    required this.type,
    required this.onTap,
  });

  final CalculationType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: GridSize.popoverItemHeight,
      child: FlowyButton(
        text: FlowyText(
          type.label,
          overflow: TextOverflow.ellipsis,
          lineHeight: 1.0,
        ),
        onTap: () {
          onTap();
          PopoverContainer.of(context).close();
        },
      ),
    );
  }
}
