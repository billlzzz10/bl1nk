import '../../../../../../../../appflowy/util/theme_extension.dart';
import '../../../../../../../../flutter/material.dart';

extension SpacePermissionColorExtension on BuildContext {
  Color get enableBorderColor => Theme.of(this).isLightMode
      ? const Color(0x1E171717)
      : const Color(0xFF3A3F49);
}
