import '../../../../../../../appflowy/plugins/database/application/cell/bloc/timestamp_cell_bloc.dart';
import '../../../../../../../appflowy/plugins/database/widgets/row/cells/cell_container.dart';
import '../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../flutter/widgets.dart';

import '../editable_cell_skeleton/timestamp.dart';

class DesktopRowDetailTimestampCellSkin extends IEditableTimestampCellSkin {
  @override
  Widget build(
    BuildContext context,
    CellContainerNotifier cellContainerNotifier,
    ValueNotifier<bool> compactModeNotifier,
    TimestampCellBloc bloc,
    TimestampCellState state,
  ) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6.0),
      child: FlowyText(
        state.dateStr,
        maxLines: null,
      ),
    );
  }
}
