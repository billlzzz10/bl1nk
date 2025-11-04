import '../../../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../../../appflowy/mobile/presentation/database/view/database_filter_condition_list.dart';
import '../../../../../../../../../../appflowy/plugins/database/application/field/filter_entities.dart';
import '../../../../../../../../../../appflowy/plugins/database/grid/presentation/widgets/filter/condition_button.dart';
import '../../../../../../../../../../appflowy/workspace/presentation/widgets/pop_up_action.dart';
import '../../../../../../../../../../appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import '../../../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../../../flutter/widgets.dart';

class SelectOptionFilterConditionList extends StatelessWidget {
  const SelectOptionFilterConditionList({
    super.key,
    required this.filter,
    required this.fieldType,
    required this.popoverMutex,
    required this.onCondition,
  });

  final SelectOptionFilter filter;
  final FieldType fieldType;
  final PopoverMutex popoverMutex;
  final void Function(SelectOptionFilterConditionPB) onCondition;

  @override
  Widget build(BuildContext context) {
    final conditions = (fieldType == FieldType.SingleSelect
        ? SingleSelectOptionFilterCondition().conditions
        : MultiSelectOptionFilterCondition().conditions);
    return PopoverActionList<ConditionWrapper>(
      asBarrier: true,
      mutex: popoverMutex,
      direction: PopoverDirection.bottomWithCenterAligned,
      actions: conditions
          .map(
            (action) => ConditionWrapper(
              action.$1,
              filter.condition == action.$1,
            ),
          )
          .toList(),
      buildChild: (controller) {
        return ConditionButton(
          conditionName: filter.condition.i18n,
          onTap: () => controller.show(),
        );
      },
      onSelected: (action, controller) async {
        onCondition(action.inner);
        controller.close();
      },
    );
  }
}

class ConditionWrapper extends ActionCell {
  ConditionWrapper(this.inner, this.isSelected);

  final SelectOptionFilterConditionPB inner;
  final bool isSelected;

  @override
  Widget? rightIcon(Color iconColor) {
    return isSelected ? const FlowySvg(FlowySvgs.check_s) : null;
  }

  @override
  String get name => inner.i18n;
}

extension SelectOptionFilterConditionPBExtension
    on SelectOptionFilterConditionPB {
  String get i18n {
    return switch (this) {
      SelectOptionFilterConditionPB.OptionIs =>
        LocaleKeys.grid_selectOptionFilter_is.tr(),
      SelectOptionFilterConditionPB.OptionIsNot =>
        LocaleKeys.grid_selectOptionFilter_isNot.tr(),
      SelectOptionFilterConditionPB.OptionContains =>
        LocaleKeys.grid_selectOptionFilter_contains.tr(),
      SelectOptionFilterConditionPB.OptionDoesNotContain =>
        LocaleKeys.grid_selectOptionFilter_doesNotContain.tr(),
      SelectOptionFilterConditionPB.OptionIsEmpty =>
        LocaleKeys.grid_selectOptionFilter_isEmpty.tr(),
      SelectOptionFilterConditionPB.OptionIsNotEmpty =>
        LocaleKeys.grid_selectOptionFilter_isNotEmpty.tr(),
      _ => "",
    };
  }
}
