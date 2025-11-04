import '../../../../../../../../appflowy/workspace/presentation/widgets/pop_up_action.dart';
import '../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../flutter/material.dart';

class DividerOptionAction extends CustomActionCell {
  @override
  Widget buildWithContext(
    BuildContext context,
    PopoverController controller,
    PopoverMutex? mutex,
  ) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Divider(
        height: 1.0,
        thickness: 1.0,
      ),
    );
  }
}
