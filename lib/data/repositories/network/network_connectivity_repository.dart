/// 기기의 네트워크 연결 상태 조회 및 변경 감지를 추상화한 저장소 인터페이스입니다.
abstract interface class NetworkConnectivityRepository {
  /// 현재 연결된 활성 네트워크가 존재하는지 확인합니다.
  Future<bool> isConnected();

  /// 온오프라인 네트워크 연결 상태 변경을 실시간으로 방출하는 스트림.
  Stream<bool> get onConnectivityChanged;
}
