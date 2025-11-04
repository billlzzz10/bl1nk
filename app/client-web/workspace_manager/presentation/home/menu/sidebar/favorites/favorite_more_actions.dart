import '../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/startup/startup.dart';
import '../../../../../../../../appflowy/workspace/application/favorite/favorite_bloc.dart';
import '../../../../../../../../appflowy/workspace/application/sidebar/folder/folder_bloc.dart';
import '../../../../../../../../appflowy/workspace/application/tabs/tabs_bloc.dart';
import '../../../../../../../../appflowy/workspace/application/view/view_bloc.dart';
import '../../../../../../../../appflowy/workspace/application/view/view_ext.dart';
import '../../../../../../../../appflowy/workspace/application/view/view_service.dart';
import '../../../../../../../../appflowy/workspace/presentation/home/menu/view/view_action_type.dart';
import '../../../../../../../../appflowy/workspace/presentation/home/menu/view/view_more_action_button.dart';
import '../../../../../../../../appflowy/workspace/presentation/widgets/dialog_v2.dart';
import '../../../../../../../../appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import '../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/icon_button.dart';
import '../../../../../../../../flowy_infra_ui/widget/flowy_tooltip.dart';
import '../../../../../../../../flutter/material.dart';
import '../../../../../../../../flutter_bloc/flutter_bloc.dart';

class FavoriteMoreActions extends StatelessWidget {
  const FavoriteMoreActions({super.key, required this.view});

  final ViewPB view;

  @override
  Widget build(BuildContext context) {
    return FlowyTooltip(
      message: LocaleKeys.menuAppHeader_moreButtonToolTip.tr(),
      child: ViewMoreActionPopover(
        view: view,
        spaceType: FolderSpaceType.favorite,
        isExpanded: false,
        onEditing: (value) =>
            context.read<ViewBloc>().add(ViewEvent.setIsEditing(value)),
        onAction: (action, _) {
          switch (action) {
            case ViewMoreActionType.favorite:
            case ViewMoreActionType.unFavorite:
              context.read<FavoriteBloc>().add(FavoriteEvent.toggle(view));
              PopoverContainer.maybeOf(context)?.closeAll();
              break;
            case ViewMoreActionType.rename:
              showAFTextFieldDialog(
                context: context,
                title: LocaleKeys.disclosureAction_rename.tr(),
                initialValue: view.nameOrDefault,
                maxLength: 256,
                onConfirm: (newValue) {
                  // can not use bloc here because it has been disposed.
                  ViewBackendService.updateView(
                    viewId: view.id,
                    name: newValue,
                  );
                },
              );
              PopoverContainer.maybeOf(context)?.closeAll();
              break;

            case ViewMoreActionType.openInNewTab:
              getIt<TabsBloc>().openTab(view);
              break;
            case ViewMoreActionType.delete:
            case ViewMoreActionType.duplicate:
            default:
              throw UnsupportedError('$action is not supported');
          }
        },
        buildChild: (popover) => FlowyIconButton(
          width: 24,
          icon: const FlowySvg(FlowySvgs.workspace_three_dots_s),
          onPressed: () {
            popover.show();
          },
        ),
      ),
    );
  }
}
