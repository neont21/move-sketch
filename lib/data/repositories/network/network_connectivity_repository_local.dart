import 'package:connectivity_plus/connectivity_plus.dart';

import '../../services/hardware/network_connectivity_service.dart';
import 'network_connectivity_repository.dart';

/// [NetworkConnectivityService]를 통해 기기의 온오프라인 여부를 판별하는 [NetworkConnectivityRepository] 구현체입니다.
final class NetworkConnectivityRepositoryLocal
    implements NetworkConnectivityRepository {
  /// 네트워크 연결 상태 하드웨어 서비스.
  final NetworkConnectivityService networkConnectivityService;

  NetworkConnectivityRepositoryLocal({
    required this.networkConnectivityService,
  });

  @override
  Future<bool> isConnected() async {
    try {
      final results = await networkConnectivityService.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return networkConnectivityService.onConnectivityChanged
        .map(_hasActiveConnection)
        .distinct()
        .handleError((_) => false);
  }

  // 연결 결과 목록에 ConnectivityResult.none 이외의 유효한 네트워크가 하나 이상 포함되어 있는지 판별합니다.
  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return false;
    }
    return results.any((result) => result != ConnectivityResult.none);
  }
}
