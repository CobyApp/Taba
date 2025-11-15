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
        template: LetterStyle(
          background: const Color(0xFFFFF1F7),
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
        template: LetterStyle(
          background: const Color(0xFF1E1A3B),
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
        template: LetterStyle(
          background: const Color(0xFFE6F3FF),
          textColor: AppColors.textPrimary,
          fontFamily: 'Poppins',
          fontSize: 16,
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
