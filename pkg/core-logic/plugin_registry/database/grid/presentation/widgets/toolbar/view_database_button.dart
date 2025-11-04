import '../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/startup/startup.dart';
import '../../../../../../../../appflowy/workspace/application/tabs/tabs_bloc.dart';
import '../../../../../../../../appflowy/workspace/application/view/view_ext.dart';
import '../../../../../../../../appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/icon_button.dart';
import '../../../../../../../../flutter/material.dart';

class ViewDatabaseButton extends StatelessWidget {
  const ViewDatabaseButton({super.key, required this.view});

  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: FlowyIconButton(
        tooltipText: LocaleKeys.grid_rowPage_viewDatabase.tr(),
        width: 24,
        height: 24,
        iconPadding: const EdgeInsets.all(3),
        icon: const FlowySvg(FlowySvgs.database_fullscreen_s),
        onPressed: () {
          getIt<TabsBloc>().add(
            TabsEvent.openPlugin(
              plugin: view.plugin(),
              view: view,
            ),
          );
        },
      ),
    );
  }
}
