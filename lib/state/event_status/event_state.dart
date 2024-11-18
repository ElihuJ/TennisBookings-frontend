import 'package:flutter/foundation.dart';

import '../../types/index.dart';

enum EventType { loadingBox, message, none }

@immutable
class EventStatus {
  final String message;
  final EventType eventType;
  final String? title;
  final bool isLoading;
  final MessageType? messageType;

  const EventStatus({required this.eventType, required this.message, this.title, this.isLoading = false, this.messageType});

  const EventStatus.empty() : this(eventType: EventType.none, message: '');

  EventStatus copyWith({
    String? title,
    String? message,
    bool? isLoading,
    EventType? eventType,
    MessageType? messageType,
  }) =>
      EventStatus(
        title: title ?? this.title,
        message: message ?? this.message,
        isLoading: isLoading ?? this.isLoading,
        eventType: eventType ?? this.eventType,
        messageType: messageType ?? this.messageType,
      );

  @override
  String toString() {
    return 'LoadingStatus(title: $title, message: $message, isLoading: $isLoading,'
        'eventType: $eventType, messageType: $messageType)';
  }

  @override
  bool operator ==(covariant EventStatus other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.message == message &&
        other.isLoading == isLoading &&
        other.eventType == eventType &&
        other.messageType == messageType;
  }

  @override
  int get hashCode => title.hashCode ^ message.hashCode ^ isLoading.hashCode ^ eventType.hashCode ^ messageType.hashCode;
}
