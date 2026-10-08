import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
      appBar: AppBar(
        title: const Text('서비스 이용약관'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '무브스케치 서비스 이용약관',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '시행일자: 2026년 10월 6일 | 버전: 1.0.0',
                style: textTheme.labelMedium,
              ),
              const Divider(height: 32.0),
              _buildSection(
                context,
                title: '제1조 (목적)',
                content:
                '본 약관은 무브스케치(MoveSketch, 이하 "서비스")가 제공하는 위치 기반 운동 세션 트래킹 및 소셜 스케치 공유 서비스의 이용 조건 및 절차, 운영자와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
              ),
              _buildSection(
                context,
                title: '제2조 (용어의 정의)',
                content:
                '1. "서비스"란 단말기(스마트폰 등)를 통해 조깅, 자전거 등의 이동 경로를 GPS로 기록하고, 경로에 기반한 스케치를 생성 및 소셜 피드에 공유할 수 있는 무브스케치 애플리케이션을 의미합니다.\n'
                    '2. "회원"이란 본 약관에 동의하고 계정을 생성하여 서비스를 이용하는 자를 의미합니다.\n'
                    '3. "스케치"란 회원의 GPS 이동 경로와 운동 데이터를 시각화하여 생성된 결과물 및 이미지를 의미합니다.\n'
                    '4. "게시물"이란 회원이 서비스 내에 게시한 스케치, 댓글, 프로필 캐릭터 등의 정보를 의미합니다.',
              ),
              _buildSection(
                context,
                title: '제3조 (약관의 효력 및 개정)',
                content:
                '1. 본 약관은 회원이 서비스 가입 시 동의함으로써 효력이 발생합니다.\n'
                    '2. 서비스는 관련 법령을 위배하지 않는 범위 내에서 약관을 개정할 수 있으며, 개정 시 시행일자 7일 전부터 앱 내 공지사항을 통해 고지합니다.',
              ),
              _buildSection(
                context,
                title: '제4조 (회원가입 및 계정 관리)',
                content:
                '1. 이용자는 이메일 또는 소셜 로그인(Google, Apple) 연동을 통해 회원가입을 신청합니다.\n'
                    '2. 회원은 본인의 계정 정보를 성실히 관리할 책임이 있으며, 타인에게 양도하거나 대여할 수 없습니다.\n'
                    '3. 회원은 언제든지 앱 내 [설정 > 계정 정보 > 회원 탈퇴]를 통해 탈퇴할 수 있으며, 탈퇴 즉시 모든 데이터는 영구 삭제됩니다.',
              ),
              _buildSection(
                context,
                title: '제5조 (서비스의 내용 및 제공)',
                content:
                '1. 서비스는 다음의 기능을 무료로 제공합니다.\n'
                    '  • 실시간 GPS 기반 운동(러닝, 사이클링) 경로 트래킹\n'
                    '  • 운동 경로 기반 스케치 아트 자동 생성 및 기록 저장\n'
                    '  • 스케치 피드 공유, 친구 검색 및 응원, 댓글 상호작용\n'
                    '2. 서비스는 연중무휴, 1일 24시간 제공을 원칙으로 하되, 시스템 정기점검 등의 사유로 일시 중단될 수 있습니다.',
              ),
              _buildSection(
                context,
                title: '제6조 (위치기반서비스에 관한 특약)',
                content:
                '1. 서비스는 회원의 단말기 GPS 센서를 활용하여 위치정보를 수집하며, 이는 운동 세션 기록 및 스케치 그래픽 생성에만 활용됩니다.\n'
                    '2. 백그라운드 수집: 운동 세션 실행 중 화면이 꺼지거나 타 앱으로 전환된 상태에서도 경로 유실을 방지하기 위해 백그라운드 위치를 수집합니다. 세션 종료 또는 일시정지 시 수집은 즉시 정지됩니다.\n'
                    '3. 위치정보 관리책임자: 정주원 (neont21@gmail.com)\n'
                    '4. 회원은 단말기 권한 설정을 통해 언제든지 위치 수집 동의를 철회할 수 있습니다.',
              ),
              _buildSection(
                context,
                title: '제7조 (게시물의 권리 및 관리)',
                content:
                '1. 회원이 서비스 내에 게시한 스케치, 댓글 등의 저작권은 해당 회원에게 귀속됩니다.\n'
                    '2. 회원은 서비스 내에서 자신의 게시물이 노출·공유되는 것에 동의합니다.\n'
                    '3. 타인의 권리를 침해하거나 음란, 혐오, 불법적인 내용이 포함된 게시물은 사전 통보 없이 블라인드 또는 삭제될 수 있으며, 해당 회원은 이용이 제한될 수 있습니다.',
              ),
              _buildSection(
                context,
                title: '제8조 (회원의 의무)',
                content:
                '1. 회원은 타인의 계정을 도용하거나 부정한 방법으로 서비스를 이용해서는 안 됩니다.\n'
                    '2. 회원은 서비스를 이용하여 허위 경로를 생성하거나 시스템에 과도한 부하를 주는 행위를 해서는 안 됩니다.',
              ),
              _buildSection(
                context,
                title: '제9조 (면책 조항)',
                content:
                '1. 서비스는 위성 신호 장애, 기상 악화, 고층 건물 밀집 지역 등 불가피한 GPS 음영 구역으로 인한 경로 및 거리의 오차에 대해 책임을 지지 않습니다.\n'
                    '2. 회원은 야외 운동 시 주변 교통 상황과 도로 안전에 각별히 주의해야 합니다. 회원의 부주의나 도로교통법 위반으로 인해 발생한 일체의 안전사고에 대해 서비스는 고의 또는 중과실이 없는 한 책임을 지지 않습니다.\n'
                    '3. 무료로 제공되는 서비스의 특성상 천재지변, 불가항력적 서버 장애로 인한 일시적 서비스 중단에 대해 손해배상 책임을 부담하지 않습니다.',
              ),
              _buildSection(
                context,
                title: '제10조 (분쟁의 해결 및 관할)',
                content:
                '서비스 이용과 관련하여 분쟁이 발생할 경우 대한민국 법률을 준거법으로 하며, 소송이 제기될 경우 민사소송법에 따른 관할법원으로 합니다.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}