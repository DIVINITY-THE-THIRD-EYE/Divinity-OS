import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/l10n/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'services/app_check_service.dart';

// Secrets are injected at build time via --dart-define-from-file=dart_defines.json
// (or individual --dart-define flags in CI). Never commit dart_defines.json.
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

// Reports all Riverpod provider errors to Crashlytics as non-fatal.
class _CrashlyticsProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    _supabaseUrl.isNotEmpty,
    'SUPABASE_URL not defined — pass --dart-define-from-file=dart_defines.json',
  );
  assert(
    _supabaseAnonKey.isNotEmpty,
    'SUPABASE_ANON_KEY not defined — pass --dart-define-from-file=dart_defines.json',
  );

  await Supabase.initialize(
    url: _supabaseUrl,
    publishableKey: _supabaseAnonKey,
  );

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Secure client-side requests using App Check
  await AppCheckService.init();

  // Setup Remote Config default parameters
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setDefaults({
    'ai_model_name': 'gemini-1.5-flash',
    'ai_system_instruction':
        'You are Divinity, a helpful and calm wellness academy coach.',
    'streak_milestone_target': 10,
    'auth_enable_email': true,
    'auth_enable_google': true,
    'auth_enable_apple': true,
    'auth_enable_phone': true,
    'auth_enable_anonymous': false,
  });
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ),
  );
  await remoteConfig.fetchAndActivate();

  // Wire Flutter framework errors and uncaught async errors to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(
    ProviderScope(
      observers: [_CrashlyticsProviderObserver()],
      child: const DivinityApp(),
    ),
  );
}

class DivinityApp extends ConsumerWidget {
  const DivinityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Divinity',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
