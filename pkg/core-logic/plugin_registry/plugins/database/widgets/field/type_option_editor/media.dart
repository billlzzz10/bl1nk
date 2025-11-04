import '../../../../../../../../flutter/material.dart';

import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/plugins/database/application/field/type_option/type_option_data_parser.dart';
import '../../../../../../../../appflowy/plugins/database/grid/presentation/layout/sizes.dart';
import '../../../../../../../../appflowy/plugins/database/widgets/field/type_option_editor/builder.dart';
import '../../../../../../../../appflowy/workspace/presentation/widgets/toggle/toggle.dart';
import '../../../../../../../../appflowy_backend/protobuf/flowy-database2/field_entities.pb.dart';
import '../../../../../../../../appflowy_backend/protobuf/flowy-database2/media_entities.pb.dart';
import '../../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/button.dart';
import '../../../../../../../../flowy_infra_ui/style_widget/text.dart';
import '../../../../../../../../protobuf/protobuf.dart';

class MediaTypeOptionEditorFactory implements TypeOptionEditorFactory {
  const MediaTypeOptionEditorFactory();

  @override
  Widget? build({
    required BuildContext context,
    required String viewId,
    required FieldPB field,
    required PopoverMutex popoverMutex,
    required TypeOptionDataCallback onTypeOptionUpdated,
  }) {
    final typeOption = _parseTypeOptionData(field.typeOptionData);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: GridSize.popoverItemHeight,
      alignment: Alignment.centerLeft,
      child: FlowyButton(
        resetHoverOnRebuild: false,
        text: FlowyText(
          LocaleKeys.grid_media_showFileNames.tr(),
          lineHeight: 1.0,
        ),
        onHover: (_) => popoverMutex.close(),
        rightIcon: Toggle(
          value: !typeOption.hideFileNames,
          onChanged: (val) => onTypeOptionUpdated(
            _toggleHideFiles(typeOption, !val).writeToBuffer(),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  MediaTypeOptionPB _parseTypeOptionData(List<int> data) {
    return MediaTypeOptionDataParser().fromBuffer(data);
  }

  MediaTypeOptionPB _toggleHideFiles(
    MediaTypeOptionPB typeOption,
    bool hideFileNames,
  ) {
    typeOption.freeze();
    return typeOption.rebuild((to) => to.hideFileNames = hideFileNames);
  }
}
