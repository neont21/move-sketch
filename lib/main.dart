import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'routing/app_router.dart';
import 'ui/core/theme/theme.dart';
import 'ui/core/view_models/push_notification_viewmodel.dart';
import 'utils/exceptions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await GoogleSignIn.instance.initialize();

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      final bool isFatal = error is! AppException &&
          error is! SocketException &&
          error is! HttpException;

      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        fatal: isFatal,
      );

      return true;
    };
  }

  await initializeDateFormatting('ko', null);

  runApp(const ProviderScope(child: MoveSketchApp()));
}

class MoveSketchApp extends ConsumerWidget {
  const MoveSketchApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(
      pushNotificationViewModelProvider.select(
        (state) => state.inAppNotificationBody,
      ),
      (previous, next) {
        if (next != null) {
          final destinationRoute = ref
              .read(pushNotificationViewModelProvider)
              .destinationRoute;
          final messenger = scaffoldMessengerKey.currentState;
          if (messenger != null) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              SnackBar(
                content: Text(next),
                action: destinationRoute != null
                    ? SnackBarAction(
                        label: '보기',
                        onPressed: () {
                          ref.read(routerProvider).push(destinationRoute);
                        },
                      )
                    : null,
              ),
            );
            ref
                .read(pushNotificationViewModelProvider.notifier)
                .clearNotification();
          }
        }
      },
    );

    ref.listen<String?>(
      pushNotificationViewModelProvider.select(
            (state) => state.destinationRoute,
      ),
          (previous, next) {
        if (next != null) {
          final inAppBody = ref
              .read(pushNotificationViewModelProvider)
              .inAppNotificationBody;
          if (inAppBody == null) {
            ref.read(routerProvider).push(next);
            ref
                .read(pushNotificationViewModelProvider.notifier)
                .clearNotification();
          }
        }
      },
    );

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: ref.watch(routerProvider),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      title: '무브스케치',
      theme: MoveSketchTheme.lightTheme,
      debugShowCheckedModeBanner: false,
    );
  }
}
