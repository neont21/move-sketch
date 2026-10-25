import 'package:flutter/material.dart';
import '../../../domain/models/system/app_device_info.dart';

class InquiryDeviceInfoSection extends StatelessWidget {
  final AppDeviceInfo? deviceInfo;
  final bool isLoading;

  const InquiryDeviceInfoSection({
    super.key,
    required this.deviceInfo,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (isLoading || deviceInfo == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        TextFormField(
          key: ValueKey(deviceInfo!.deviceModel),
          initialValue: deviceInfo!.deviceModel,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '기기 모델',
          ),
          style: TextStyle(color: colorScheme.tertiaryContainer),
        ),
        TextFormField(
          key: ValueKey(deviceInfo!.osVersion),
          initialValue: deviceInfo!.osVersion,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'OS 버전',
          ),
          style: TextStyle(color: colorScheme.tertiaryContainer),
        ),
        TextFormField(
          key: ValueKey(deviceInfo!.appVersion),
          initialValue: deviceInfo!.appVersion,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: '앱 버전',
          ),
          style: TextStyle(color: colorScheme.tertiaryContainer),
        ),
      ],
    );
  }
}