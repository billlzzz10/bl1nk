import 'dart:async';
import 'dart:typed_data';

import '../../../../../appflowy/core/notification/notification_helper.dart';
import '../../../../../appflowy_backend/protobuf/flowy-ai/notification.pb.dart';
import '../../../../../appflowy_backend/protobuf/flowy-error/errors.pb.dart';
import '../../../../../appflowy_backend/protobuf/flowy-notification/protobuf.dart';
import '../../../../../appflowy_backend/rust_stream.dart';
import '../../../../../appflowy_result/appflowy_result.dart';

class ChatNotificationParser
    extends NotificationParser<ChatNotification, FlowyError> {
  ChatNotificationParser({
    super.id,
    required super.callback,
  }) : super(
          tyParser: (ty, source) =>
              source == "Chat" ? ChatNotification.valueOf(ty) : null,
          errorParser: (bytes) => FlowyError.fromBuffer(bytes),
        );
}

typedef ChatNotificationHandler = Function(
  ChatNotification ty,
  FlowyResult<Uint8List, FlowyError> result,
);

class ChatNotificationListener {
  ChatNotificationListener({
    required String objectId,
    required ChatNotificationHandler handler,
  }) : _parser = ChatNotificationParser(id: objectId, callback: handler) {
    _subscription =
        RustStreamReceiver.listen((observable) => _parser?.parse(observable));
  }

  ChatNotificationParser? _parser;
  StreamSubscription<SubscribeObject>? _subscription;

  Future<void> stop() async {
    _parser = null;
    await _subscription?.cancel();
    _subscription = null;
  }
}
