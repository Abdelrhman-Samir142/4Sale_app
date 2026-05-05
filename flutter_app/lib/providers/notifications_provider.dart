import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notifications_service.dart';
import '../core/utils/app_snackbar.dart';

/// Unread notifications count — auto-fetched, cached, and automatically polled.
final unreadNotificationsProvider =
    AsyncNotifierProvider<UnreadNotificationsNotifier, int>(
        UnreadNotificationsNotifier.new);

class UnreadNotificationsNotifier extends AsyncNotifier<int> {
  Timer? _timer;
  int _lastCount = 0;

  @override
  Future<int> build() async {
    ref.onDispose(() => _timer?.cancel());
    _startPolling();
    final count = await _fetch();
    _lastCount = count;
    return count;
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final newCount = await _fetch();
        if (newCount > _lastCount) {
          // Trigger a global in-app notification when unread count increases
          AppSnackbar.showGlobal('لديك إشعار جديد 🔔\nYou have a new notification!');
        }
        if (newCount != _lastCount) {
          _lastCount = newCount;
          state = AsyncData(newCount);
        }
      } catch (_) {
        // Ignore silent network failures during background polling
      }
    });
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
    final count = await _fetch();
    _lastCount = count;
    state = AsyncData(count);
  }

  Future<void> markAllRead() async {
    await NotificationsService.markAllRead();
    _lastCount = 0;
    state = const AsyncData(0);
  }
}
