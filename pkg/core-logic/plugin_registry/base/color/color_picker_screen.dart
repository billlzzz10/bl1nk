import '../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../appflowy/mobile/presentation/base/app_bar/app_bar.dart';
import '../../../../../appflowy/plugins/base/color/color_picker.dart';
import '../../../../../easy_localization/easy_localization.dart';
import '../../../../../flutter/material.dart';
import '../../../../../go_router/go_router.dart';

class MobileColorPickerScreen extends StatelessWidget {
  const MobileColorPickerScreen({super.key, this.title});

  final String? title;

  static const routeName = '/color_picker';
  static const pageTitle = 'title';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FlowyAppBar(
        titleText: title ?? LocaleKeys.titleBar_pageIcon.tr(),
      ),
      body: SafeArea(
        child: FlowyMobileColorPicker(
          onSelectedColor: (option) => context.pop(option),
        ),
      ),
    );
  }
}
