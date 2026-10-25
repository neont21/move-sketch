import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/system/app_device_info.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

@immutable
final class InquiryState {
  final AppDeviceInfo? deviceInfo;
  final bool isLoadingDeviceInfo;
  final List<Uint8List> attachedImages;
  final bool isSubmitting;

  const InquiryState({
    this.deviceInfo,
    this.isLoadingDeviceInfo = false,
    this.attachedImages = const [],
    this.isSubmitting = false,
  });

  bool get canAddMoreImages => attachedImages.length < 3;

  InquiryState copyWith({
    AppDeviceInfo? deviceInfo,
    bool? isLoadingDeviceInfo,
    List<Uint8List>? attachedImages,
    bool? isSubmitting,
  }) {
    return InquiryState(
      deviceInfo: deviceInfo ?? this.deviceInfo,
      isLoadingDeviceInfo: isLoadingDeviceInfo ?? this.isLoadingDeviceInfo,
      attachedImages: attachedImages ?? this.attachedImages,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final class InquiryViewModel extends Notifier<InquiryState> {
  static const int maxImageCount = 3;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  final _imagePicker = ImagePicker();

  Future<void> _loadDeviceInfo() async {
    final deviceInfoService = ref.read(deviceInfoServiceProvider);

    try {
      final info = await deviceInfoService.getDeviceInfo();

      state = state.copyWith(deviceInfo: info, isLoadingDeviceInfo: false);
    } catch (_) {
      state = state.copyWith(
        deviceInfo: const AppDeviceInfo(
          osVersion: 'Unknown',
          deviceModel: 'Unknown Device',
          appVersion: '1.0.0',
        ),
        isLoadingDeviceInfo: false,
      );
    }
  }

  @override
  InquiryState build() {
    _loadDeviceInfo();

    return const InquiryState(isLoadingDeviceInfo: true);
  }

  Future<Result<void>> pickImage() async {
    if (!state.canAddMoreImages) {
      return Result.error(
        ValidationException('이미지는 최대 $maxImageCount장까지 첨부할 수 있습니다.'),
      );
    }

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return const Result.ok(null);
      }

      final Uint8List imageBytes = await pickedFile.readAsBytes();
      if (imageBytes.lengthInBytes > maxImageSizeBytes) {
        return Result.error(
          ValidationException('이미지 용량은 장당 5MB 이하여야 합니다.'),
        );
      }

      final List<Uint8List> updated = [
        ...state.attachedImages,
        imageBytes,
      ];

      state = state.copyWith(attachedImages: updated);
      return const Result.ok(null);
    } catch (exception) {
      return Result.error(
        ValidationException(
          '이미지를 불러오는 중 오류가 발생했습니다.',
          cause: exception,
        ),
      );
    }
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.attachedImages.length) {
      return;
    }
    final List<Uint8List> updated = [...state.attachedImages]..removeAt(index);
    state = state.copyWith(attachedImages: updated);
  }

  Future<Result<void>> submitInquiry({required String content}) async {
    final deviceInfo = state.deviceInfo;
    if (deviceInfo == null) {
      return const Result.error(
        ValidationException('기기 정보를 불러오는 중입니다. 잠시 후 다시 시도해 주세요.'),
      );
    }

    state = state.copyWith(isSubmitting: true);

    final currentUser = await ref.read(authViewModelProvider.future);
    final inquiry = Inquiry.create(
      deviceInfo: deviceInfo,
      content: content.trim(),
      userId: currentUser?.uid,
      userEmail: currentUser?.email,
    );

    final inquiryRepository = ref.read(inquiryRepositoryProvider);
    final result = await inquiryRepository.submitInquiry(
      inquiry,
      imageBytesList: state.attachedImages,
    );

    state = state.copyWith(isSubmitting: false);

    return result;
  }
}

final inquiryViewModelProvider =
    NotifierProvider.autoDispose<InquiryViewModel, InquiryState>(() {
      return InquiryViewModel();
    });
