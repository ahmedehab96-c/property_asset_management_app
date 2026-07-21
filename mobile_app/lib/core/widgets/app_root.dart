import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_asset_management_app/core/providers/locale_notifier.dart';
import 'package:property_asset_management_app/core/providers/theme_notifier.dart';
import 'package:property_asset_management_app/l10n/app_localizations.dart';
import 'package:property_asset_management_app/theme/app_theme.dart';

/// MaterialApp موحّد — موبايل وأدمن.
class AppRoot extends ConsumerWidget {
  const AppRoot({
    super.key,
    required this.title,
    required this.home,
    this.appKeyPrefix = 'app',
  });

  final String title;
  final Widget home;
  final String appKeyPrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeSyncProvider);
    final themeMode = ref.watch(themeModeSyncProvider);
    final isArabic = locale.languageCode == 'ar';

    return MaterialApp(
      key: ValueKey('${appKeyPrefix}_${locale.languageCode}_$themeMode'),
      title: title,
      debugShowCheckedModeBanner: false,
      locale: locale,
      themeMode: themeMode,
      theme: buildLightTheme(context),
      darkTheme: buildDarkTheme(context),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
          ),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      home: home,
    );
  }
}
