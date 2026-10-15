import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/hardware/network_connectivity_service.dart';
import 'network_connectivity_repository.dart';

final class NetworkConnectivityRepositoryLocal
    implements NetworkConnectivityRepository {
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

  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return false;
    }
    return results.any((result) => result != ConnectivityResult.none);
  }
}
