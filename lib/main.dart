import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['flutter_samples (compass_app - Result)'],
      '''
Copyright 2024 The Flutter team. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
''',
    );
  });

  usePathUrlStrategy();

  if (defaultTargetPlatform == TargetPlatform.android) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } else {
    await GoogleSignIn.instance.initialize();

    bool isFatalError(Object error) {
      return error is! AppException &&
          error is! SocketException &&
          error is! HttpException &&
          error is! HandshakeException;
    }

    FlutterError.onError = (details) {
      final bool isFatal = isFatalError(details.exception);
      FirebaseCrashlytics.instance.recordFlutterError(details, fatal: isFatal);
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      final bool isFatal = isFatalError(error);

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
