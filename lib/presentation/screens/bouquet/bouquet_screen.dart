import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/screens/write/write_letter_page.dart';
import 'package:taba_app/presentation/screens/common/letter_detail_screen.dart';

class BouquetScreen extends StatefulWidget {
  const BouquetScreen({super.key, required this.friendBouquets});

  final List<FriendBouquet> friendBouquets;

  @override
  State<BouquetScreen> createState() => _BouquetScreenState();
}

class _BouquetScreenState extends State<BouquetScreen> {
  int _selectedIndex = 0;
  late Set<String> _readFlowerIds;
  final Map<String, String> _customBouquetNames = {};

  @override
  void initState() {
    super.initState();
    _readFlowerIds = {
      for (final bouquet in widget.friendBouquets)
        ...bouquet.sharedFlowers
            .where((flower) => flower.isRead || flower.sentByMe)
            .map((flower) => flower.id),
    };
  }

  FriendBouquet get _selectedBouquet => widget.friendBouquets[_selectedIndex];
  String _resolveBouquetName(FriendBouquet bouquet) =>
      _customBouquetNames[bouquet.friend.user.id] ?? bouquet.bouquetName;

  void _selectFriend(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  int _unreadFor(FriendBouquet bouquet) {
    return bouquet.sharedFlowers
        .where(
          (flower) =>
              !flower.sentByMe && !_readFlowerIds.contains(flower.id),
        )
        .length;
  }

  void _openFlower(SharedFlower flower) {
    if (!flower.sentByMe && !_readFlowerIds.contains(flower.id)) {
      setState(() {
        _readFlowerIds.add(flower.id);
      });
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LetterDetailScreen(
          letter: flower.letter,
          friendName: _selectedBouquet.friend.user.nickname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.friendBouquets.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientGalaxy,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const SizedBox.shrink(),
            centerTitle: false,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_florist_outlined,
                  size: 64,
                  color: Colors.white54,
                ),
                SizedBox(height: 16),
                Text(
                  '아직 꽃다발이 없어요',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '친구와 편지를 주고받으면 꽃다발이 생겨요',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selected = _selectedBouquet;
    final unread = _unreadFor(selected);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientGalaxy,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const SizedBox.shrink(),
          centerTitle: false,
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _composeLetterToSelectedFriend,
                icon: const Icon(Icons.edit),
                label: const Text('이 친구에게 편지 보내기'),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _FriendStoryStrip(
                  bouquets: widget.friendBouquets,
                  selectedIndex: _selectedIndex,
                  unreadResolver: _unreadFor,
                  onSelect: _selectFriend,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: _FriendSummaryCard(
                    bouquet: selected,
                    unreadCount: unread,
                    bouquetName: _resolveBouquetName(selected),
                    onTap: () => _openBouquetDetail(selected),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                sliver: _ChatMessagesSliver(
                  flowers: selected.sharedFlowers,
                  readFlowerIds: _readFlowerIds,
                  onOpen: _openFlower,
                  friendAvatarUrl: selected.friend.user.avatarUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareBouquet(FriendBouquet bouquet) {
    final snippet = bouquet.sharedFlowers
        .take(4)
        .map((f) => '• ${f.title} (${f.flower.emoji})')
        .join('\n');
    final shareText = '''
[Taba 꽃다발 공유]
${bouquet.friend.user.nickname}과 나눈 꽃 ${bouquet.totalFlowers}개

$snippet

Taba에서 씨앗을 잡아 나와 친구가 되어줘!
초대 코드: ${bouquet.friend.inviteCode}
''';
    Clipboard.setData(ClipboardData(text: shareText));
    showTabaNotice(
      context,
      title: '꽃다발 공유 링크 복사',
      message: '${bouquet.friend.user.nickname}과의 꽃다발을 친구에게 전해보세요.',
      icon: Icons.share,
    );
  }

  void _openBouquetDetail(FriendBouquet bouquet) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final controller =
            TextEditingController(text: _resolveBouquetName(bouquet));
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      Text(
                        '꽃다발 상세',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${bouquet.friend.user.nickname}과 만든 꽃다발',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: '꽃다발 이름',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    onSubmitted: (value) {
                      final trimmed = value.trim();
                      if (trimmed.isEmpty) return;
                      _saveBouquetName(bouquet, trimmed);
                      showTabaNotice(
                        context,
                        title: '꽃다발 이름을 저장했어요',
                        message: trimmed,
                        icon: Icons.local_florist,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: bouquet.sharedFlowers
                        .map(
                          (flower) => Container(
                            width: 150,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.midnightGlass,
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  flower.flower.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  flower.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  flower.preview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () => _shareBouquet(bouquet),
                    icon: const Icon(Icons.share),
                    label: const Text('꽃다발 공유하기'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _saveBouquetName(FriendBouquet bouquet, String name) {
    if (name.isEmpty) return;
    setState(() {
      _customBouquetNames[bouquet.friend.user.id] = name;
    });
  }

  void _composeLetterToSelectedFriend() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WriteLetterPage(),
      ),
    );
  }
}

class _FriendStoryStrip extends StatelessWidget {
  const _FriendStoryStrip({
    required this.bouquets,
    required this.selectedIndex,
    required this.unreadResolver,
    required this.onSelect,
  });

  final List<FriendBouquet> bouquets;
  final int selectedIndex;
  final int Function(FriendBouquet) unreadResolver;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemBuilder: (context, index) {
          final bouquet = bouquets[index];
          final selected = index == selectedIndex;
          final unread = unreadResolver(bouquet);
          return GestureDetector(
            onTap: () => onSelect(index),
            child: SizedBox(
              width: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.white.withAlpha(60),
                            width: selected ? 3 : 1.5,
                          ),
                          boxShadow: [
                            if (selected)
                              BoxShadow(
                                color: bouquet
                                    .resolveTheme(AppColors.neonPink)
                                    .withAlpha(120),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(bouquet.friend.user.avatarUrl),
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neonPink,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      bouquet.friend.user.nickname,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(selected ? 255 : 200),
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: bouquets.length,
      ),
    );
  }
}

class _FriendSummaryCard extends StatelessWidget {
  const _FriendSummaryCard({
    required this.bouquet,
    required this.unreadCount,
    required this.bouquetName,
    required this.onTap,
  });

  final FriendBouquet bouquet;
  final int unreadCount;
  final String bouquetName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = bouquet.resolveTheme(AppColors.neonPink);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              color.withAlpha(220),
              Colors.white.withAlpha(16),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bouquetName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bouquet.friend.user.nickname} · 꽃 ${bouquet.totalFlowers}개',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bloom ${(bouquet.bloomLevel * 100).round()}% · 신뢰 ${bouquet.trustScore}%',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  unreadCount > 0 ? '$unreadCount' : '0',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0 ? '읽지 않은 꽃' : '모든 꽃 읽음',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.flower,
    required this.isUnread,
    required this.onTap,
  });

  final SharedFlower flower;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final directionColor = flower.sentByMe ? AppColors.neonBlue : Colors.white;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
        child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.midnightGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? AppColors.neonPink.withAlpha(120) : Colors.white24,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFFFF), Color(0x33FFFFFF)],
                ),
                border: Border.all(color: Colors.white30),
              ),
              child: Center(
                child: Text(
                  flower.flower.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          flower.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.neonPink,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    flower.preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        flower.sentByMe
                            ? Icons.north_east
                            : Icons.south_west,
                        size: 16,
                        color: directionColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        flower.directionLabel,
                        style: TextStyle(
                          color: directionColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        flower.seedId,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _timeAgo(flower.sentAt),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    }
    return '${diff.inDays}일 전';
  }
}

class _ChatMessagesSliver extends StatelessWidget {
  const _ChatMessagesSliver({
    required this.flowers,
    required this.readFlowerIds,
    required this.onOpen,
    required this.friendAvatarUrl,
  });

  final List<SharedFlower> flowers;
  final Set<String> readFlowerIds;
  final ValueChanged<SharedFlower> onOpen;
  final String friendAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final separatedCount = math.max(0, flowers.length * 2 - 1);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) return const SizedBox(height: 12);
          final i = index ~/ 2;
          final item = flowers[i];
          final isUnread = !item.sentByMe && !readFlowerIds.contains(item.id);
          return _ChatBubble(
            contentTitle: item.title,
            contentPreview: item.preview,
            emoji: item.flower.emoji,
            isMine: item.sentByMe,
            timeLabel: _timeAgoStatic(item.sentAt),
            isUnread: isUnread,
            friendAvatarUrl: friendAvatarUrl,
            onTap: () => onOpen(item),
          );
        },
        childCount: separatedCount,
      ),
    );
  }

  static String _timeAgoStatic(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.contentTitle,
    required this.contentPreview,
    required this.emoji,
    required this.isMine,
    required this.timeLabel,
    required this.isUnread,
    required this.friendAvatarUrl,
    required this.onTap,
  });

  final String contentTitle;
  final String contentPreview;
  final String emoji;
  final bool isMine;
  final String timeLabel;
  final bool isUnread;
  final String friendAvatarUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.neonBlue.withAlpha(40) : AppColors.midnightGlass;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(isMine ? 20 : 4),
      bottomRight: Radius.circular(isMine ? 4 : 20),
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final bubbleMaxWidth = screenWidth * 0.98;

    final bubble = InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: radius,
          border: Border.all(
            color: isUnread ? AppColors.neonPink.withAlpha(120) : Colors.white24,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      contentTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isUnread)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.neonPink,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                contentPreview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMine) ...[
                CircleAvatar(radius: 14, backgroundImage: NetworkImage(friendAvatarUrl)),
                const SizedBox(width: 8),
                Flexible(child: bubble),
                const Spacer(),
              ] else ...[
                const Spacer(),
                Flexible(child: bubble),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: isMine ? 0 : 36, right: isMine ? 0 : 0),
              child: Text(
                timeLabel,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

