import '../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/workspace/presentation/widgets/pop_up_action.dart';
import '../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';

import '../../../../../../../../flowy_infra/theme_extension.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/icon_button.dart';
import '../../../../../../../../flutter/material.dart';

class DisclosureButton extends StatefulWidget {
  const DisclosureButton({
    super.key,
    required this.popoverMutex,
    required this.onAction,
  });

  final PopoverMutex popoverMutex;
  final Function(FilterDisclosureAction) onAction;

  @override
  State<DisclosureButton> createState() => _DisclosureButtonState();
}

class _DisclosureButtonState extends State<DisclosureButton> {
  @override
  Widget build(BuildContext context) {
    return PopoverActionList<FilterDisclosureActionWrapper>(
      asBarrier: true,
      mutex: widget.popoverMutex,
      actions: FilterDisclosureAction.values
          .map((action) => FilterDisclosureActionWrapper(action))
          .toList(),
      buildChild: (controller) {
        return FlowyIconButton(
          hoverColor: AFThemeExtension.of(context).lightGreyHover,
          width: 20,
          icon: FlowySvg(
            FlowySvgs.details_s,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => controller.show(),
        );
      },
      onSelected: (action, controller) async {
        widget.onAction(action.inner);
        controller.close();
      },
    );
  }
}

enum FilterDisclosureAction {
  delete,
}

class FilterDisclosureActionWrapper extends ActionCell {
  FilterDisclosureActionWrapper(this.inner);

  final FilterDisclosureAction inner;

  @override
  Widget? leftIcon(Color iconColor) => null;

  @override
  String get name => inner.name;
}

extension FilterDisclosureActionExtension on FilterDisclosureAction {
  String get name {
    switch (this) {
      case FilterDisclosureAction.delete:
        return LocaleKeys.grid_settings_deleteFilter.tr();
    }
  }
}
