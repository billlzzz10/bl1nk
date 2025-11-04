import '../../../../../../appflowy/generated/flowy_svgs.g.dart';
import '../../../../../../appflowy/generated/locale_keys.g.dart';
import '../../../../../../appflowy/plugins/database/tab_bar/tab_bar_view.dart';
import '../../../../../../appflowy/startup/plugin/plugin.dart';
import '../../../../../../appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import '../../../../../../easy_localization/easy_localization.dart';

class CalendarPluginBuilder extends PluginBuilder {
  @override
  Plugin build(dynamic data) {
    if (data is ViewPB) {
      return DatabaseTabBarViewPlugin(pluginType: pluginType, view: data);
    } else {
      throw FlowyPluginException.invalidData;
    }
  }

  @override
  String get menuName => LocaleKeys.calendar_menuName.tr();

  @override
  FlowySvgData get icon => FlowySvgs.icon_calendar_s;

  @override
  PluginType get pluginType => PluginType.calendar;

  @override
  ViewLayoutPB get layoutType => ViewLayoutPB.Calendar;
}

class CalendarPluginConfig implements PluginConfig {
  @override
  bool get creatable => true;
}
