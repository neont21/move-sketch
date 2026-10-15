abstract interface class NetworkConnectivityRepository {
  /// 연결된 네트워크가 존재하는지 확인한다.
  Future<bool> isConnected();

  /// 온오프라인 상태 전환을 실시간으로 확인한다.
  Stream<bool> get onConnectivityChanged;
}