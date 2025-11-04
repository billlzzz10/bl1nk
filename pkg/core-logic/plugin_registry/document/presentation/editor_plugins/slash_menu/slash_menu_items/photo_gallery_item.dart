import '../../../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/base/selectable_svg_widget.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/image/image_placeholder.dart';
import '../../../../../../../../appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import '../../../../../../../../appflowy_editor/appflowy_editor.dart';
import '../../../../../../../../easy_localization/easy_localization.dart';
import '../../../../../../../../flutter/material.dart';

import 'slash_menu_items.dart';

final _keywords = [
  LocaleKeys.document_plugins_photoGallery_imageKeyword.tr(),
  LocaleKeys.document_plugins_photoGallery_imageGalleryKeyword.tr(),
  LocaleKeys.document_plugins_photoGallery_photoKeyword.tr(),
  LocaleKeys.document_plugins_photoGallery_photoBrowserKeyword.tr(),
  LocaleKeys.document_plugins_photoGallery_galleryKeyword.tr(),
];

// photo gallery menu item
SelectionMenuItem photoGallerySlashMenuItem = SelectionMenuItem(
  getName: () => LocaleKeys.document_slashMenu_name_photoGallery.tr(),
  keywords: _keywords,
  handler: (editorState, _, __) async => editorState.insertPhotoGalleryBlock(),
  nameBuilder: slashMenuItemNameBuilder,
  icon: (_, isSelected, style) => SelectableSvgWidget(
    data: FlowySvgs.slash_menu_icon_photo_gallery_s,
    isSelected: isSelected,
    style: style,
  ),
);

extension on EditorState {
  Future<void> insertPhotoGalleryBlock() async {
    final imagePlaceholderKey = GlobalKey<ImagePlaceholderState>();
    await insertEmptyMultiImageBlock(imagePlaceholderKey);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => imagePlaceholderKey.currentState?.controller.show(),
    );
  }
}
