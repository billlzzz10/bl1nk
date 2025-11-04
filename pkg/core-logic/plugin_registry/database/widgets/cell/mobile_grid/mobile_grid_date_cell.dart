import '../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../appflowy/mobile/presentation/bottom_sheet/show_mobile_bottom_sheet.dart';
import '../../../../../../../appflowy/mobile/presentation/database/date_picker/mobile_date_picker_screen.dart';
import '../../../../../../../appflowy/plugins/database/application/cell/bloc/date_cell_bloc.dart';
import '../../../../../../../appflowy/plugins/database/widgets/cell/editable_cell_skeleton/date.dart';
import '../../../../../../../appflowy/plugins/database/widgets/row/cells/cell_container.dart';
import '../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../flutter/material.dart';

class MobileGridDateCellSkin extends IEditableDateCellSkin {
  @override
  Widget build(
    BuildContext context,
    CellContainerNotifier cellContainerNotifier,
    ValueNotifier<bool> compactModeNotifier,
    DateCellBloc bloc,
    DateCellState state,
    PopoverController popoverController,
  ) {
    final dateStr = getDateCellStrFromCellData(
      state.fieldInfo,
      state.cellData,
    );
    return FlowyButton(
      radius: BorderRadius.zero,
      hoverColor: Colors.transparent,
      margin: EdgeInsets.zero,
      text: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (state.cellData.reminderId.isNotEmpty) ...[
                const FlowySvg(FlowySvgs.clock_alarm_s),
                const HSpace(6),
              ],
              FlowyText(
                dateStr,
                fontSize: 15,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        showMobileBottomSheet(
          context,
          builder: (context) {
            return MobileDateCellEditScreen(
              controller: bloc.cellController,
              showAsFullScreen: false,
            );
          },
        );
      },
    );
  }
}
