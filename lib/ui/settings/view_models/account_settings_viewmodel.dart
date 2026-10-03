import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
class AccountSettingsState {
  final List<String> linkedProviders;
  final Map<String, String> providerEmails;
  final bool isEmailVerified;
  final bool isProcessing;

  const AccountSettingsState({
    this.linkedProviders = const [],
    this.providerEmails = const {},
    this.isEmailVerified = false,
    this.isProcessing = false,
  });

  bool get hasPassword => linkedProviders.contains('password');
  String? get passwordEmail => providerEmails['password'];

  bool get isGoogleLinked => linkedProviders.contains('google.com');
  String? get googleEmail => providerEmails['google.com'];

  bool get isAppleLinked => linkedProviders.contains('apple.com');
  String? get appleEmail => providerEmails['apple.com'];

  AccountSettingsState copyWith({
    List<String>? linkedProviders,
    Map<String, String>? providerEmails,
    bool? isEmailVerified,
    bool? isProcessing,
  }) {
    return AccountSettingsState(
      linkedProviders: linkedProviders ?? this.linkedProviders,
      providerEmails: providerEmails ?? this.providerEmails,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class AccountSettingsViewModel extends Notifier<AccountSettingsState> {
  void _syncState() {
    final authRepository = ref.read(authRepositoryProvider);
    state = state.copyWith(
      linkedProviders: authRepository.linkedProviders,
      providerEmails: authRepository.providerEmails,
      isEmailVerified: authRepository.isEmailVerified,
      isProcessing: false,
    );
  }

  @override
  AccountSettingsState build() {
    ref.watch(authViewModelProvider);
    final authRepository = ref.watch(authRepositoryProvider);

    return AccountSettingsState(
      linkedProviders: authRepository.linkedProviders,
      providerEmails: authRepository.providerEmails,
      isEmailVerified: authRepository.isEmailVerified,
    );
  }

  Future<Result<bool>> checkEmailVerification() async {
    state = state.copyWith(isProcessing: true);

    final result = await ref.read(authRepositoryProvider).checkEmailVerified();

    switch (result) {
      case Ok(:final value):
        if (value) {
          await ref.read(authViewModelProvider.notifier).refreshCurrentUser();
        }
        _syncState();
      case Error():
        state = state.copyWith(isProcessing: false);
    }

    return result;
  }

  Future<Result<void>> resendVerificationEmail() async {
    state = state.copyWith(isProcessing: true);

    final result = await ref
        .read(authRepositoryProvider)
        .resendVerificationEmail();

    state = state.copyWith(isProcessing: false);

    return result;
  }

  Future<Result<bool>> linkGoogle() async {
    state = state.copyWith(isProcessing: true);

    final result = await ref.read(authRepositoryProvider).linkGoogle();

    switch (result) {
      case Ok(value: true):
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();
        _syncState();
      case Ok(value: false):
        break;
      case Error():
        break;
    }

    state = state.copyWith(isProcessing: false);
    return result;
  }

  Future<Result<bool>> linkApple() async {
    state = state.copyWith(isProcessing: true);

    final result = await ref.read(authRepositoryProvider).linkApple();

    switch (result) {
      case Ok(value: true):
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();
        _syncState();
      case Ok(value: false):
        break;
      case Error():
        break;
    }

    state = state.copyWith(isProcessing: false);
    return result;
  }

  Future<Result<void>> linkEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isProcessing: true);

    final result = await ref
        .read(authRepositoryProvider)
        .linkEmailAndPassword(email: email, password: password);

    switch (result) {
      case Ok():
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();
        _syncState();
      case Error():
        break;
    }

    state = state.copyWith(isProcessing: false);
    return result;
  }

  Future<Result<void>> unlinkProvider(String providerId) async {
    state = state.copyWith(isProcessing: true);

    final result = await ref
        .read(authRepositoryProvider)
        .unlinkProvider(providerId);

    switch (result) {
      case Ok():
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();
        _syncState();
      case Error():
        break;
    }

    state = state.copyWith(isProcessing: false);
    return result;
  }

  Future<Result<void>> signOut() async {
    state = state.copyWith(isProcessing: true);

    final result = await ref.read(authViewModelProvider.notifier).signOut();

    state = state.copyWith(isProcessing: false);
    return result;
  }
}

final accountSettingsViewModelProvider =
    NotifierProvider.autoDispose<
      AccountSettingsViewModel,
      AccountSettingsState
    >(() {
      return AccountSettingsViewModel();
    });
