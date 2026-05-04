import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/products_service.dart';
import '../core/cache/offline_cache.dart';
import '../core/network/connectivity_service.dart';
import '../models/product.dart';

// ── State ─────────────────────────────────────────────────────────────────
class PaginatedProductsState {
  final List<Product> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final bool isOffline;

  const PaginatedProductsState({
    this.items = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.isOffline = false,
  });

  PaginatedProductsState copyWith({
    List<Product>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    bool? isOffline,
  }) =>
      PaginatedProductsState(
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
class PaginatedProductsNotifier
    extends Notifier<PaginatedProductsState> {
  static const _cacheKey = 'products_page_1';
  String? _category;
  String? _search;

  @override
  PaginatedProductsState build() {
    _loadInitial();
    return const PaginatedProductsState();
  }

  void setFilters({String? category, String? search}) {
    _category = category;
    _search = search;
    state = const PaginatedProductsState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final online = await isOnline();

    if (!online) {
      final cached = OfflineCache.getStale<List<dynamic>>(_cacheKey);
      final cachedProducts = cached?.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList() ?? [];
      state = state.copyWith(
        items: cachedProducts,
        isLoading: false,
        isOffline: true,
        hasMore: false,
      );
      return;
    }

    try {
      final res = await ProductsService.list(
        category: _category,
        search: _search,
        page: 1,
      );
      final items = res.results;
      final count = res.count;
      final hasMore = items.length < count;

      await OfflineCache.set(_cacheKey, items.map((e) => e.toJson()).toList());

      state = state.copyWith(
        items: items,
        isLoading: false,
        hasMore: hasMore,
        currentPage: 1,
        isOffline: false,
      );
    } catch (e) {
      final cached = OfflineCache.getStale<List<dynamic>>(_cacheKey);
      final cachedProducts = cached?.map((e) => Product.fromJson(Map<String, dynamic>.from(e))).toList() ?? [];
      state = state.copyWith(
        items: cachedProducts,
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
      final res = await ProductsService.list(
        category: _category,
        search: _search,
        page: nextPage,
      );
      final newItems = res.results;
      final count = res.count;
      final allItems = [...state.items, ...newItems];

      state = state.copyWith(
        items: allItems,
        isLoadingMore: false,
        hasMore: allItems.length < count,
        currentPage: nextPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = const PaginatedProductsState();
    await _loadInitial();
  }
}

final paginatedProductsProvider = NotifierProvider<
    PaginatedProductsNotifier, PaginatedProductsState>(
  PaginatedProductsNotifier.new,
);
