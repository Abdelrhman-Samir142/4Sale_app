import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auctions_service.dart';
import '../core/cache/offline_cache.dart';
import '../core/network/connectivity_service.dart';

// ── State ─────────────────────────────────────────────────────────────────
class PaginatedAuctionsState {
  final List<dynamic> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool isOffline;

  const PaginatedAuctionsState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.isOffline = false,
  });

  PaginatedAuctionsState copyWith({
    List<dynamic>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? isOffline,
  }) =>
      PaginatedAuctionsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
        isOffline: isOffline ?? this.isOffline,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────
class PaginatedAuctionsNotifier
    extends Notifier<PaginatedAuctionsState> {
  static const _cacheKey = 'auctions_page_1';

  @override
  PaginatedAuctionsState build() {
    _loadInitial();
    return const PaginatedAuctionsState();
  }

  Future<void> _loadInitial() async {
    final online = await isOnline();

    if (!online) {
      final cached = OfflineCache.getStale<List<dynamic>>(_cacheKey);
      state = state.copyWith(
        items: cached ?? [],
        isLoading: false,
        isOffline: true,
        hasMore: false,
      );
      return;
    }

    try {
      final res = await AuctionsService.list(page: 1);
      final List<dynamic> items;
      int count;
      if (res is Map) {
        items = (res['results'] as List?) ?? [];
        count = (res['count'] as num?)?.toInt() ?? items.length;
      } else {
        items = res as List;
        count = items.length;
      }

      await OfflineCache.set(_cacheKey, items);

      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: items.length < count,
        currentPage: 1,
        isOffline: false,
      );
    } catch (e) {
      final cached = OfflineCache.getStale<List<dynamic>>(_cacheKey);
      state = state.copyWith(
        items: cached ?? [],
        isLoading: false,
        error: cached != null ? null : e.toString(),
        isOffline: cached != null,
        hasMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final res = await AuctionsService.list(page: nextPage);
      final List<dynamic> newItems;
      int count;
      if (res is Map) {
        newItems = (res['results'] as List?) ?? [];
        count = (res['count'] as num?)?.toInt() ?? 0;
      } else {
        newItems = res as List;
        count = 0;
      }
      final allItems = [...state.items, ...newItems];

      state = state.copyWith(
        items: allItems,
        isLoadingMore: false,
        hasMore: count > 0 ? allItems.length < count : false,
        currentPage: nextPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = const PaginatedAuctionsState();
    await _loadInitial();
  }
}

final paginatedAuctionsProvider = NotifierProvider<
    PaginatedAuctionsNotifier, PaginatedAuctionsState>(
  PaginatedAuctionsNotifier.new,
);
