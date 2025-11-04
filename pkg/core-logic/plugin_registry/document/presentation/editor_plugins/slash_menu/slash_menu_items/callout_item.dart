import '../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import '../../../../../../../../appflowy_editor/appflowy_editor.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flutter/material.dart';

import 'slash_menu_item_builder.dart';

final _keywords = [
  'callout',
];

/// Callout menu item
SelectionMenuItem calloutSlashMenuItem = SelectionMenuItem.node(
  getName: LocaleKeys.document_plugins_callout.tr,
  keywords: _keywords,
  nodeBuilder: (editorState, context) =>
      calloutNode(defaultColor: Colors.transparent),
  replace: (_, node) => node.delta?.isEmpty ?? false,
  updateSelection: (_, path, __, ___) {
    return Selection.single(path: path, startOffset: 0);
  },
  nameBuilder: slashMenuItemNameBuilder,
  iconBuilder: (editorState, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_callout_s,
    isSelected: isSelected,
    style: style,
  ),
);
