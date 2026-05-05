import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/sell/sell_screen.dart';
import '../../screens/auctions/auctions_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../screens/wishlist/wishlist_screen.dart';
import '../../screens/messages/conversations_screen.dart';
import '../../screens/messages/chat_screen.dart';
import '../../screens/agent/agent_screen.dart';
import '../../screens/search/smart_search_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/store/store_screen.dart';
import '../../screens/shell_screen.dart';

// Helper for SlideUp Transition
CustomTransitionPage _buildSlideUpTransition(Widget child, LocalKey key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

// Helper for Fade Transition
CustomTransitionPage _buildFadeTransition(Widget child, LocalKey key) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

/// A [ChangeNotifier] that listens to auth state changes so
/// GoRouter can re-evaluate its redirect without being recreated.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) {
      notifyListeners();
    });
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthChangeNotifier(ref);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      // Read current auth state (not watch — we use refreshListenable)
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      final isLoading = authState.isLoading;
      final path = state.uri.path;

      // Whitelist entry points
      final isEntryPoint = path == '/splash' || path == '/onboarding';
      if (isEntryPoint) return null;

      // Still loading auth — don't redirect
      if (isLoading) return null;

      final isAuthPage = path == '/login' || path == '/register' || path == '/forgot-password';

      // Rule 1: Not logged in and trying to access a restricted page -> go to login
      if (!isLoggedIn && !isAuthPage) {
        return '/login';
      }

      // Rule 2: Logged in and trying to access auth page -> go to home
      if (isLoggedIn && isAuthPage) {
        return '/';
      }

      // Allow access to the requested page
      return null;
    },
    routes: [
      // ── Splash & Onboarding (outside shell) ───────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Shell with bottom nav ─────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => _buildFadeTransition(
              const HomeScreen(),
              state.pageKey,
            ),
          ),
          GoRoute(
            path: '/auctions',
            name: 'auctions',
            pageBuilder: (context, state) => _buildFadeTransition(
              const AuctionsScreen(),
              state.pageKey,
            ),
          ),
          GoRoute(
            path: '/messages',
            name: 'messages',
            pageBuilder: (context, state) => _buildFadeTransition(
              const ConversationsScreen(),
              state.pageKey,
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => _buildSlideUpTransition(
              const ProfileScreen(),
              state.pageKey,
            ),
          ),
          GoRoute(
            path: '/store',
            name: 'store',
            pageBuilder: (context, state) => _buildFadeTransition(
              const StoreScreen(),
              state.pageKey,
            ),
          ),
        ],
      ),

      // ── Pages outside the bottom nav ──────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        name: 'productDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildSlideUpTransition(
            ProductDetailScreen(productId: id),
            state.pageKey,
          );
        },
      ),
      GoRoute(
        path: '/sell',
        name: 'sell',
        pageBuilder: (context, state) => _buildSlideUpTransition(
          const SellScreen(),
          state.pageKey,
        ),
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        name: 'chat',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/agent',
        name: 'agent',
        builder: (context, state) => const AgentScreen(),
      ),
      GoRoute(
        path: '/search',
        name: 'search',
        builder: (context, state) => const SmartSearchScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'editProfile',
        pageBuilder: (context, state) => _buildSlideUpTransition(
          const EditProfileScreen(),
          state.pageKey,
        ),
      ),
    ],
  );
});
