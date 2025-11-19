// Core types for AI Chat (shared across packages)

enum ContextLoaderType { pdf, txt, markdown, unknown }

class ChatViewReference {
  const ChatViewReference({
    required this.id,
    required this.name,
    this.isDocumentView = false,
  });
  final String id;
  final String name;
  final bool isDocumentView;
}

class ChatMessageMeta {
  const ChatMessageMeta({
    required this.id,
    required this.name,
    required this.data,
    required this.loaderType,
    required this.source,
  });
  final String id;
  final String name;
  final String data;
  final ContextLoaderType loaderType;
  final String source;
}
