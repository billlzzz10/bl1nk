import '../../../../../../../appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import '../../../../../../../appflowy_popover/appflowy_popover.dart';
import '../../../../../../../flutter/material.dart';

import 'builder.dart';

class TimeTypeOptionEditorFactory implements TypeOptionEditorFactory {
  const TimeTypeOptionEditorFactory();

  @override
  Widget? build({
    required BuildContext context,
    required String viewId,
    required FieldPB field,
    required PopoverMutex popoverMutex,
    required TypeOptionDataCallback onTypeOptionUpdated,
  }) =>
      null;
}
