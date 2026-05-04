import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_service.dart';

/// Unread notifications count — auto-fetched and cached.
final unreadNotificationsProvider =
    AsyncNotifierProvider<UnreadNotificationsNotifier, int>(
        UnreadNotificationsNotifier.new);

class UnreadNotificationsNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    return _fetch();
  }

  Future<int> _fetch() async {
    try {
      return await NotificationsService.unreadCount();
    } catch (_) {
      return 0;
    }
  }

  /// Call after marking notifications as read.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> markAllRead() async {
    await NotificationsService.markAllRead();
    state = const AsyncData(0);
  }
}
