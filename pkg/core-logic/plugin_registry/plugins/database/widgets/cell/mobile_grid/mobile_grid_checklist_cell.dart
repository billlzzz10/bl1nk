import '../../../../../../../../appflowy/mobile/presentation/bottom_sheet/show_mobile_bottom_sheet.dart';
import '../../../../../../../../appflowy/plugins/database/application/cell/bloc/checklist_cell_bloc.dart';
import '../../../../../../../../appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import '../../../../../../../../appflowy/plugins/database/widgets/cell_editor/checklist_progress_bar.dart';
import '../../../../../../../../appflowy/plugins/database/widgets/cell_editor/mobile_checklist_cell_editor.dart';
import '../../../../../../../../appflowy/plugins/database/widgets/row/cells/cell_container.dart';
import '../../../../../../../../flowy_infra_ui/flowy_infra_ui.dart';
import '../../../../../../../../flutter/material.dart';
import '../../../../../../../../flutter_bloc/flutter_bloc.dart';

import '../editable_cell_skeleton/checklist.dart';

class MobileGridChecklistCellSkin extends IEditableChecklistCellSkin {
  @override
  Widget build(
    BuildContext context,
    CellContainerNotifier cellContainerNotifier,
    ValueNotifier<bool> compactModeNotifier,
    ChecklistCellBloc bloc,
    PopoverController popoverController,
  ) {
    return BlocBuilder<ChecklistCellBloc, ChecklistCellState>(
      builder: (context, state) {
        return FlowyButton(
          radius: BorderRadius.zero,
          hoverColor: Colors.transparent,
          text: Container(
            alignment: Alignment.centerLeft,
            padding: GridSize.cellContentInsets,
            child: state.tasks.isEmpty
                ? const SizedBox.shrink()
                : ChecklistProgressBar(
                    tasks: state.tasks,
                    percent: state.percent,
                    textStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 15),
                  ),
          ),
          onTap: () => showMobileBottomSheet(
            context,
            builder: (context) {
              return BlocProvider.value(
                value: bloc,
                child: const MobileChecklistCellEditScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
