import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'core/utils/global_keys.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Root widget for the 4Sale marketplace app.
class ForSaleApp extends ConsumerWidget {
  const ForSaleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final lang = ref.watch(languageProvider);
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: '4Sale',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: GlobalKeys.scaffoldMessengerKey,

          // Theme
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,

          // Routing
          routerConfig: router,

          // Locale
          locale: Locale(lang.locale),
          supportedLocales: const [Locale('ar'), Locale('en')],

          // Localization delegates (required for Material/Cupertino widgets)
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          builder: (context, child) {
            return Directionality(
              textDirection: lang.textDirection,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
