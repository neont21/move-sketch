import 'package:connectivity_plus/connectivity_plus.dart';

/// 기기의 현재 네트워크 연결 상태를 조회하고 변경 이벤트를 구독하는 서비스 클래스입니다.
class NetworkConnectivityService {
  final Connectivity _connectivity;

  NetworkConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// 현재 활성화된 네트워크 인터페이스 목록([ConnectivityResult])을 조회합니다.
  Future<List<ConnectivityResult>> checkConnectivity() {
    return _connectivity.checkConnectivity();
  }

  /// 네트워크 연결 인터페이스 상태 변경을 실시간으로 방출하는 스트림.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}