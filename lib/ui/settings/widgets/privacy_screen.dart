import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  Widget _buildSection(
    BuildContext context, {
    required final String title,
    required final String content,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('개인정보 처리방침')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '무브스케치 개인정보 처리방침',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '시행일자: 2026년 10월 6일 | 버전: 1.0.0',
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const Divider(height: 32.0),
              _buildSection(
                context,
                title: '제1조 (개인정보의 처리 목적)',
                content:
                    '무브스케치(MoveSketch, 이하 "서비스")는 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 관련 법령에 따라 별도의 동의를 받는 등 필요한 조치를 이행합니다.\n'
                    '1. 회원 가입 및 계정 관리: 회원 식별, 계정 생성 및 본인 확인, 서비스 부정이용 방지, 계정 탈퇴 처리\n'
                    '2. 위치기반 서비스 제공: 조깅 및 라이딩 경로의 실시간 GPS 추적, 이동 거리·속도·시간 계산, 경로 기반 스케치 아트 생성\n'
                    '3. 소셜 커뮤니티 서비스: 스케치 피드 공유, 댓글 및 응원(좋아요), 친구 맺기 및 사용자 프로필 열람\n'
                    '4. 알림 서비스: 상호작용(댓글, 응원, 친구 요청)에 따른 실시간 푸시 알림(FCM) 발송\n'
                    '5. 앱 안정성 개선: Firebase Crashlytics를 통한 크래시 분석 및 서비스 오류 진단',
              ),
              _buildSection(
                context,
                title: '제2조 (처리하는 개인정보의 항목)',
                content:
                    '서비스 제공을 위해 처리하는 개인정보 항목은 다음과 같습니다.\n'
                    '1. 회원 가입 시 수집 항목\n'
                    '  • 이메일 가입: 이메일 주소, 비밀번호(암호화 일방향 해시), 닉네임, 선택 캐릭터\n'
                    '  • 소셜 로그인(Google, Apple): 소셜 식별자(UID), 이메일 주소, 닉네임, 프로필 이미지 URL\n'
                    '2. 서비스 이용 과정에서 수집되는 항목\n'
                    '  • 위치정보: 위도, 경도, 고도, 타임스탬프 (운동 세션 실행 시 포그라운드 및 백그라운드 수집)\n'
                    '  • 운동 데이터: 세션별 이동 경로 좌표 배열, 이동 거리, 소요 시간, 평균 속력\n'
                    '3. 자동 생성 및 수집 항목\n'
                    '  • 기기 고유 식별값, 운영체제(OS) 버전, FCM 푸시 토큰, 비정상 종료 진단 로그',
              ),
              _buildSection(
                context,
                title: '제3조 (개인정보의 처리 및 보유 기간)',
                content:
                    '1. 이용자의 개인정보는 원칙적으로 회원 탈퇴 시까지 보유 및 이용됩니다.\n'
                    '2. 이용자가 앱 내 [설정 > 계정 정보 > 회원 탈퇴]를 진행하는 경우, 개인정보 및 운동 세션 데이터는 지체 없이 영구 파기됩니다.\n'
                    '3. 단, 관계 법령에 따라 보존 의무가 있는 경우 해당 법령이 정한 기한 동안 보관합니다.\n'
                    '  • 통신비밀보호법에 따른 로그인 기록(접속로그): 3개월',
              ),
              _buildSection(
                context,
                title: '제4조 (개인정보의 제3자 제공)',
                content:
                    '서비스는 이용자의 개인정보를 제1조에서 명시한 범위 내에서만 처리하며, 이용자의 사전 동의 없이 개인정보를 제3자에게 제공하지 않습니다. 단, 법률의 특별한 규정 등 개인정보 보호법 제17조 및 제18조에 해당하는 경우에만 예외적으로 제공합니다.',
              ),
              _buildSection(
                context,
                title: '제5조 (개인정보처리의 위탁 및 국외 이전)',
                content:
                    '서비스는 안정적인 클라우드 인프라 제공을 위해 다음과 같이 개인정보 처리를 국외 위탁하고 있습니다.\n'
                    '1. 수탁자: Google LLC (Firebase)\n'
                    '2. 이전 국가: 미국 및 Google Cloud 글로벌 데이터센터 리전\n'
                    '3. 위탁 업무: 사용자 인증(Auth), 데이터베이스 보관(Firestore), 미디어 스토리지(Storage), 푸시 알림(FCM), 오류 진단(Crashlytics)\n'
                    '4. 보유 및 이용 기간: 회원 탈퇴 시 또는 서비스 종료 시까지',
              ),
              _buildSection(
                context,
                title: '제6조 (개인위치정보의 처리 및 보호)',
                content:
                    '1. 서비스는 「위치정보의 보호 및 이용 등에 관한 법률」을 준수합니다.\n'
                    '2. 수집된 개인위치정보는 이용자가 운동 세션을 기록하고 스케치 이미지를 생성하는 용도로만 사용되며, 타인에게 무단 제공되지 않습니다.\n'
                    '3. 백그라운드 위치 수집: 회원이 세션을 시작한 후 화면을 끄거나 앱을 백그라운드로 전환해도 끊김 없는 경로 기록을 위해 포그라운드 서비스 알림과 함께 위치를 수집합니다. 세션 종료 또는 일시정지 시 수집은 즉시 정지됩니다.\n'
                    '4. 소셜 피드 공유 시 위치정보 보호: 이용자가 피드에 운동 결과를 공유할 때 세부 이동 궤적 좌표는 공개되지 않으며, 이용자가 직접 선택한 대표 위치(출발지, 경유지, 도착지 중 1곳)의 개략적 지명만 표기되어 개인 거주지 및 사생활을 안전하게 보호합니다.\n'
                    '5. 이용자는 단말기 설정에서 위치 권한을 언제든지 철회할 수 있습니다.',
              ),
              _buildSection(
                context,
                title: '제7조 (개인정보의 파기 절차 및 방법)',
                content:
                    '1. 서비스는 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체 없이 해당 개인정보를 파기합니다.\n'
                    '2. 파기 방법: 전자적 파일 형태로 기록·저장된 개인정보는 기록을 재생할 수 없도록 영구 삭제(Firestore 및 Storage 레코드 파기)합니다.',
              ),
              _buildSection(
                context,
                title: '제8조 (정보주체의 권리·의무 및 행사방법)',
                content:
                    '1. 이용자는 언제든지 본인의 개인정보 열람, 정정, 삭제 요구 권리를 행사할 수 있습니다.\n'
                    '2. 권리 행사는 앱 내 [설정 > 계정 정보] 화면에서 직접 수정하거나 회원 탈퇴를 통해 즉시 처리할 수 있으며, 보호책임자에게 이메일로 요청하실 수도 있습니다.',
              ),
              _buildSection(
                context,
                title: '제9조 (만 14세 미만 아동의 개인정보 처리)',
                content:
                    '서비스는 만 14세 미만 아동의 개인정보를 수집하지 않으며, 회원 가입은 만 14세 이상의 이용자에 한하여 허용됩니다.',
              ),
              _buildSection(
                context,
                title: '제10조 (개인정보의 안전성 확보조치)',
                content:
                    '서비스는 개인정보의 안전성 확보를 위해 다음과 같은 기술적·관리적 조치를 취하고 있습니다.\n'
                    '1. 개인정보의 암호화: 비밀번호는 일방향 암호화되어 관리자도 확인할 수 없으며, 통신 구간은 TLS/HTTPS를 통해 안전하게 암호화됩니다.\n'
                    '2. 접근 제한: Cloud Firestore 보안 규칙을 통해 데이터베이스의 인가되지 않은 접근을 원천 차단하고 있습니다.',
              ),
              _buildSection(
                context,
                title: '제11조 (개인정보 자동 수집 장치의 설치·운영 및 거부)',
                content:
                    '1. 서비스는 웹 브라우저 쿠키를 사용하지 않습니다.\n'
                    '2. 모바일 앱 푸시 알림(FCM) 수신을 원하지 않는 경우, 앱 내 [설정 > 푸시 알림] 또는 기기 [설정 > 애플리케이션 > 무브스케치 > 알림]에서 언제든지 수신을 거부할 수 있습니다.',
              ),
              _buildSection(
                context,
                title: '제12조 (개인정보 보호책임자 및 권익침해 구제)',
                content:
                    '1. 개인정보 처리와 관련한 문의 및 불만처리는 아래의 보호책임자에게 문의해 주시기 바랍니다.\n'
                    '  • 개인정보 보호책임자: 정주원 (무브스케치 개발 및 운영)\n'
                    '  • 연락처 이메일: neont21@gmail.com\n\n'
                    '2. 기타 개인정보 침해에 대한 상담이나 신고는 아래 기관에 문의하실 수 있습니다.\n'
                    '  • 개인정보분쟁조정위원회: (국번없이) 1833-6972 (kopico.go.kr)\n'
                    '  • 개인정보침해신고센터: (국번없이) 118 (privacy.kisa.or.kr)\n'
                    '  • 대검찰청 사이버수사과: (국번없이) 1301 (spo.go.kr)\n'
                    '  • 경찰청 사이버수사국: (국번없이) 182 (ecrm.police.go.kr)',
              ),
              _buildSection(
                context,
                title: '제13조 (개인정보 처리방침의 변경)',
                content:
                    '본 개인정보 처리방침은 2026년 10월 6일부터 적용됩니다. 법령 및 방침에 따른 변경 내용의 추가, 삭제 및 정정이 있는 경우에는 앱 공지사항 또는 웹페이지를 통해 고지합니다.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
