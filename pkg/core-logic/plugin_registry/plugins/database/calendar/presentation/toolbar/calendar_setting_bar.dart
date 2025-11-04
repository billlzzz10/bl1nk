import '../../../../../../../../appflowy/plugins/database/application/database_controller.dart';
import '../../../../../../../../appflowy/plugins/database/grid/application/filter/filter_editor_bloc.dart';
import '../../../../../../../../appflowy/plugins/database/grid/presentation/grid_page.dart';
import '../../../../../../../../appflowy/plugins/database/grid/presentation/widgets/toolbar/filter_button.dart';
import '../../../../../../../../appflowy/plugins/database/grid/presentation/widgets/toolbar/view_database_button.dart';
import '../../../../../../../../appflowy/plugins/database/widgets/setting/setting_button.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/mention/mention_page_block.dart';
import '../../../../../../../../flowy_infra_ui/widget/spacing.dart';
import '../../../../../../../../flutter/material.dart';
import '../../../../../../../../flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../provider/provider.dart';

class CalendarSettingBar extends StatelessWidget {
  const CalendarSettingBar({
    super.key,
    required this.databaseController,
    required this.toggleExtension,
  });

  final DatabaseController databaseController;
  final ToggleExtensionNotifier toggleExtension;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FilterEditorBloc(
        viewId: databaseController.viewId,
        fieldController: databaseController.fieldController,
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: databaseController.isLoading,
        builder: (context, value, child) {
          if (value) {
            return const SizedBox.shrink();
          }
          final isReference =
              Provider.of<ReferenceState?>(context)?.isReference ?? false;
          return SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilterButton(
                  toggleExtension: toggleExtension,
                ),
                if (isReference) ...[
                  const HSpace(2),
                  ViewDatabaseButton(view: databaseController.view),
                ],
                const HSpace(2),
                SettingButton(
                  databaseController: databaseController,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
