import '../../../../appflowy/startup/plugin/plugin.dart';
import '../../../../appflowy/workspace/application/view/view_listener.dart';
import '../../../../appflowy_backend/log.dart';
import '../../../../appflowy_backend/protobuf/flowy-folder/view.pb.dart';
import '../../../../flutter/material.dart';

class ViewPluginNotifier extends PluginNotifier<DeletedViewPB?> {
  ViewPluginNotifier({
    required this.view,
  }) : _viewListener = ViewListener(viewId: view.id) {
    _viewListener?.start(
      onViewUpdated: (updatedView) => view = updatedView,
      onViewMoveToTrash: (result) => result.fold(
        (deletedView) => isDeleted.value = deletedView,
        (err) => Log.error(err),
      ),
    );
  }

  ViewPB view;
  final ViewListener? _viewListener;

  @override
  final ValueNotifier<DeletedViewPB?> isDeleted = ValueNotifier(null);

  @override
  void dispose() {
    isDeleted.dispose();
    _viewListener?.stop();
  }
}
