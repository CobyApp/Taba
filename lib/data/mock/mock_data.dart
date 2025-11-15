import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/data/models/user.dart';

class MockDataRepository {
  MockDataRepository._();

  static final MockDataRepository instance = MockDataRepository._();

  final List<TabaUser> users = [];
  final List<Letter> letters = [];
  final List<BouquetFolder> folders = [];
  final List<FriendProfile> friends = [];
  final List<NotificationItem> notifications = [];

  bool _seeded = false;

  void seed() {
    if (_seeded) return;
    _seeded = true;

    users.addAll([
      const TabaUser(
        id: 'u1',
        username: 'skylover',
        nickname: '라일락',
        avatarUrl: 'https://i.pravatar.cc/150?img=47',
        statusMessage: '오늘도 꽃 편지를 기다려요',
      ),
      const TabaUser(
        id: 'u2',
        username: 'mintcloud',
        nickname: '민트클라우드',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        statusMessage: '편지 잡으러 하늘로 ☁️',
      ),
      const TabaUser(
        id: 'u3',
        username: 'neoy2k',
        nickname: '네온',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        statusMessage: 'Y2K 감성 모으는 중',
      ),
    ]);

    letters.addAll([
      Letter(
        id: 'l1',
        title: '오늘의 새벽 공기',
        preview: '새벽 공기에 피어난 생각들을 담았어요.',
        content:
            '창문을 열자마자 새벽 공기가 밀려들어와요. 아직 말랑말랑한 하늘, 그 위로 천천히 떠오르는 꽃들을 보고 있으니 마음이 편안해졌어요. 당신에게도 이 감각이 닿았으면 해요.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 8)),
        sender: users.first,
        flower: FlowerType.sakura,
        likes: 42,
        views: 128,
        savedCount: 18,
        tags: const ['새벽', '감성'],
        template: const LetterStyle(
          background: Color(0xFFFFF1F7),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
      Letter(
        id: 'l2',
        title: '네온사인 아래에서',
        preview: '밤하늘을 닮은 편지를 보냈어요.',
        content:
            '도시의 불빛 속에서도 별빛은 숨어 있더라고요. 오늘은 유난히 하늘이 반짝여서, 당신 생각이 났어요. 밤 공기 속 네온사인처럼 선명해지는 마음을 담았어요.',
        sentAt: DateTime.now().subtract(const Duration(minutes: 34)),
        sender: users[2],
        flower: FlowerType.rose,
        likes: 58,
        views: 201,
        savedCount: 32,
        tags: const ['밤', 'Y2K'],
        template: const LetterStyle(
          background: Color(0xFF1E1A3B),
          textColor: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 18,
        ),
      ),
      Letter(
        id: 'l3',
        title: '햇살 한 줌',
        preview: '따뜻한 오후를 담은 편지예요.',
        content:
            '오늘은 오후 내내 햇살이 창문에 머물렀어요. 그 빛을 조금 접어 당신에게 보냅니다. 작은 기쁨이 꽃잎처럼 흩날리기를.',
        sentAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
        sender: users[1],
        flower: FlowerType.tulip,
        likes: 24,
        views: 92,
        savedCount: 15,
        tags: const ['햇살', '위로'],
        template: const LetterStyle(
          background: Color(0xFFE6F3FF),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
      Letter(
        id: 'l4',
        title: '차분해지는 플레이리스트',
        preview: '비오는 날 듣는 음악과 함께.',
        content:
            '오늘은 하루 종일 비가 내렸어요. 이어폰 속에서 흐르던 재즈가 마음을 차분하게 만들더라고요. 당신에게도 이 조용한 멜로디가 닿기를.',
        sentAt: DateTime.now().subtract(const Duration(hours: 3)),
        sender: users[1],
        flower: FlowerType.lavender,
        likes: 12,
        views: 55,
        savedCount: 9,
        tags: const ['음악', '비오는날'],
        template: const LetterStyle(
          background: Color(0xFFF5ECFF),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 15,
        ),
      ),
      Letter(
        id: 'l5',
        title: '숨겨둔 폴라로이드',
        preview: '책갈피에서 발견한 추억 이야기.',
        content:
            '오래된 책을 펼치다가 폴라로이드를 발견했어요. 그 안의 웃는 얼굴이 아직도 반짝거려서 순간 시간이 멈춘 줄 알았답니다.',
        sentAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 20)),
        sender: users.first,
        flower: FlowerType.daisy,
        likes: 31,
        views: 140,
        savedCount: 20,
        tags: const ['추억', '사진'],
        template: const LetterStyle(
          background: Color(0xFFFFFAEE),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
      Letter(
        id: 'l6',
        title: '새벽 러닝',
        preview: '도시가 잠들어 있을 때의 공기.',
        content:
            '해가 뜨기 전 러닝을 하면 도시가 나만의 것이 된 듯한 기분이 들어요. 아직 누구도 밟지 않은 길 위에 발걸음을 남겨요.',
        sentAt: DateTime.now().subtract(const Duration(hours: 6, minutes: 45)),
        sender: users[2],
        flower: FlowerType.sunflower,
        likes: 19,
        views: 77,
        savedCount: 8,
        tags: const ['운동', '새벽'],
        template: const LetterStyle(
          background: Color(0xFFFFF9D7),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 16,
        ),
      ),
      Letter(
        id: 'l7',
        title: '에메랄드 파도',
        preview: '바다에서 보낸 휴식의 기록.',
        content:
            '모래사를 밟을 때마다 사각거리는 소리가 들려요. 파도가 발목을 적시면 마음까지 맑아지는 것 같아요. 그 감각을 꽃잎에 담아보냈어요.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        sender: users.first,
        flower: FlowerType.tulip,
        likes: 65,
        views: 220,
        savedCount: 41,
        tags: const ['휴식', '바다'],
        template: const LetterStyle(
          background: Color(0xFFE1FFF9),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 17,
        ),
      ),
      Letter(
        id: 'l8',
        title: '별자리 연결선',
        preview: '오늘의 별자리에 대해 써봤어요.',
        content:
            '밤하늘을 바라보다가 별자리를 따라 연필로 선을 그려봤어요. 그 선 끝에 당신이 있다는 상상을 하니 괜히 마음이 포근해졌어요.',
        sentAt: DateTime.now().subtract(const Duration(days: 1, hours: 9)),
        sender: users[2],
        flower: FlowerType.rose,
        likes: 50,
        views: 197,
        savedCount: 28,
        tags: const ['별자리', '밤'],
        template: const LetterStyle(
          background: Color(0xFF120026),
          textColor: Colors.white,
          fontFamily: 'Poppins',
          fontSize: 18,
        ),
      ),
    ]);

    folders.addAll([
      BouquetFolder(
        id: 'f1',
        name: '전체',
        color: AppColors.neonPink,
        letters: letters,
      ),
      BouquetFolder(
        id: 'f2',
        name: '응원',
        color: AppColors.neonBlue,
        letters: letters.take(2).toList(),
      ),
      BouquetFolder(
        id: 'f3',
        name: '추억',
        color: AppColors.neonPurple,
        letters: letters.skip(1).toList(),
      ),
    ]);

    friends.addAll([
      FriendProfile(
        user: users[1],
        lastLetterAt: DateTime.now().subtract(const Duration(hours: 5)),
        friendCount: 32,
        sentLetters: 15,
        group: '친한 친구',
      ),
      FriendProfile(
        user: users[2],
        lastLetterAt: DateTime.now().subtract(
          const Duration(days: 1, hours: 3),
        ),
        friendCount: 18,
        sentLetters: 23,
        group: '동료',
      ),
    ]);

    notifications.addAll([
      NotificationItem(
        id: 'n1',
        title: '새 편지가 도착했어요!',
        subtitle: '네온님이 꽃 편지를 보냈어요.',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        category: NotificationCategory.letter,
      ),
      NotificationItem(
        id: 'n2',
        title: '좋아요를 받았어요',
        subtitle: '누군가 새벽 공기를 좋아해요.',
        time: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
        category: NotificationCategory.reaction,
      ),
      NotificationItem(
        id: 'n3',
        title: '친구 요청이 왔어요',
        subtitle: 'mintcloud 님이 친구를 신청했어요.',
        time: DateTime.now().subtract(const Duration(hours: 3, minutes: 40)),
        category: NotificationCategory.friend,
      ),
    ]);
  }
}
