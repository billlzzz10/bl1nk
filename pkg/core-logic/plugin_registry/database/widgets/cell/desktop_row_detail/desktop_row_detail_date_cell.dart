import '../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../appflowy/plugins/database/application/cell/bloc/date_cell_bloc.dart';
import '../../../../../../../appflowy/plugins/database/widgets/cell/editable_cell_skeleton/date.dart';
import '../../../../../../../appflowy/plugins/database/widgets/cell_editor/date_cell_editor.dart';
import '../../../../../../../appflowy/plugins/database/widgets/row/cells/cell_container.dart';
import '../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../flutter/material.dart';

class DesktopRowDetailDateCellSkin extends IEditableDateCellSkin {
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
    final text =
        dateStr.isEmpty ? LocaleKeys.grid_row_textPlaceholder.tr() : dateStr;
    final color = dateStr.isEmpty ? Theme.of(context).hintColor : null;

    return AppFlowyPopover(
      controller: popoverController,
      triggerActions: PopoverTriggerFlags.none,
      direction: PopoverDirection.bottomWithLeftAligned,
      constraints: BoxConstraints.loose(const Size(260, 620)),
      margin: EdgeInsets.zero,
      asBarrier: true,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FlowyText(
                text,
                color: color,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.cellData.reminderId.isNotEmpty) ...[
              const HSpace(4),
              FlowyTooltip(
                message: LocaleKeys.grid_field_reminderOnDateTooltip.tr(),
                child: const FlowySvg(FlowySvgs.clock_alarm_s),
              ),
            ],
          ],
        ),
      ),
      popupBuilder: (BuildContext popoverContent) {
        return DateCellEditor(
          cellController: bloc.cellController,
          onDismissed: () => cellContainerNotifier.isFocus = false,
        );
      },
      onClose: () {
        cellContainerNotifier.isFocus = false;
      },
    );
  }
}
