/// A redacted diagnostic event emitted by a GrabKit module.
class GrabKitEvent {
  GrabKitEvent({
    required this.moduleId,
    required this.type,
    required this.message,
    DateTime? at,
    this.data = const {},
  }) : at = at ?? DateTime.now();

  final String moduleId;
  final String type;
  final String message;
  final DateTime at;
  final Map<String, Object?> data;
}
