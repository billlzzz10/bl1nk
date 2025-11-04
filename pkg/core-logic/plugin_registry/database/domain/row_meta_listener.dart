import 'dart:typed_data';

import '../../../../../appflowy/core/notification/grid_notification.dart';
import '../../../../../appflowy_backend/log.dart';
import '../../../../../appflowy_backend/protobuf/flowy-database2/protobuf.dart';
import '../../../../../appflowy_backend/protobuf/flowy-error/protobuf.dart';
import '../../../../../appflowy_result/appflowy_result.dart';

typedef RowMetaCallback = void Function(RowMetaPB);

class RowMetaListener {
  RowMetaListener(this.rowId);

  final String rowId;

  RowMetaCallback? _callback;
  DatabaseNotificationListener? _listener;

  void start({required RowMetaCallback callback}) {
    _callback = callback;
    _listener = DatabaseNotificationListener(
      objectId: rowId,
      handler: _handler,
    );
  }

  void _handler(
    DatabaseNotification ty,
    FlowyResult<Uint8List, FlowyError> result,
  ) {
    switch (ty) {
      case DatabaseNotification.DidUpdateRowMeta:
        result.fold(
          (payload) {
            if (_callback != null) {
              _callback!(RowMetaPB.fromBuffer(payload));
            }
          },
          (error) => Log.error(error),
        );
        break;
      default:
        break;
    }
  }

  Future<void> stop() async {
    await _listener?.stop();
    _callback = null;
  }
}
