import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/services/auth_service.dart';
import 'package:taba_app/data/services/bouquet_service.dart';
import 'package:taba_app/data/services/file_service.dart';
import 'package:taba_app/data/services/friend_service.dart';
import 'package:taba_app/data/services/invite_code_service.dart';
import 'package:taba_app/data/dto/invite_code_dto.dart';
import 'package:taba_app/data/services/letter_service.dart';
import 'package:taba_app/data/services/notification_service.dart';
import 'package:taba_app/data/services/settings_service.dart';
import 'package:taba_app/data/services/user_service.dart';
import 'package:taba_app/data/services/fcm_service.dart';
import 'package:taba_app/core/storage/reply_storage.dart';
import 'dart:io';

class DataRepository {
  DataRepository._();
  static final DataRepository instance = DataRepository._();

  final AuthService _authService = AuthService();
  final LetterService _letterService = LetterService();
  final BouquetService _bouquetService = BouquetService();
  final FriendService _friendService = FriendService();
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
  final FileService _fileService = FileService();
  final InviteCodeService _inviteCodeService = InviteCodeService();
  final SettingsService _settingsService = SettingsService();
  final FcmService _fcmService = FcmService();

  // Auth
  Future<bool> login(String email, String password) async {
    final response = await _authService.login(email: email, password: password);
    if (response.isSuccess && response.data != null) {
      // 로그인 성공 시 FCM 토큰 등록
      final userId = response.data!.user.id;
      await _fcmService.registerTokenToServer(userId);
    }
    return response.isSuccess;
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String nickname,
    required bool agreeTerms,
    required bool agreePrivacy,
    File? profileImage,
  }) async {
    final response = await _authService.signup(
      email: email,
      password: password,
      nickname: nickname,
      agreeTerms: agreeTerms,
      agreePrivacy: agreePrivacy,
      profileImage: profileImage,
    );
    if (response.isSuccess && response.data != null) {
      // 회원가입 성공 시 FCM 토큰 등록
      final userId = response.data!.user.id;
      await _fcmService.registerTokenToServer(userId);
    }
    return response.isSuccess;
  }

  Future<bool> forgotPassword(String email) async {
    final response = await _authService.forgotPassword(email);
    return response.isSuccess;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _authService.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    return response.isSuccess;
  }

  Future<void> logout() async {
    // 로그아웃 시 FCM 토큰 삭제
    await _fcmService.deleteToken();
    await _authService.logout();
  }

  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  // Letters
  Future<List<Letter>> getPublicLetters({int page = 0, int size = 20}) async {
    final response = await _letterService.getPublicLetters(
      page: page,
      size: size,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.content.map((dto) => dto.toModel()).toList();
    }
    return [];
  }

  Future<Letter?> getLetter(String letterId) async {
    final response = await _letterService.getLetter(letterId);
    if (response.isSuccess && response.data != null) {
      return response.data!.toModel();
    }
    return null;
  }

  Future<bool> createLetter({
    required String title,
    required String content,
    required String preview,
    required String visibility,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
    DateTime? scheduledAt,
    String? recipientId,
  }) async {
    try {
      final response = await _letterService.createLetter(
        title: title,
        content: content,
        preview: preview,
        visibility: visibility,
        template: template,
        attachedImages: attachedImages,
        scheduledAt: scheduledAt,
        recipientId: recipientId,
      );
      
      if (!response.isSuccess && response.error != null) {
        // 에러 메시지를 로그로 출력 (디버깅용)
        print('편지 생성 실패: ${response.error?.message}');
      }
      
      return response.isSuccess;
    } catch (e) {
      print('편지 생성 예외: $e');
      return false;
    }
  }


  Future<bool> reportLetter(String letterId, String reason) async {
    final response = await _letterService.reportLetter(
      letterId: letterId,
      reason: reason,
    );
    return response.isSuccess;
  }

  Future<bool> deleteLetter(String letterId) async {
    final response = await _letterService.deleteLetter(letterId);
    return response.isSuccess;
  }

  /// 편지 답장 (자동 친구 추가)
  /// API 명세서: POST /letters/{letterId}/reply
  Future<bool> replyLetter({
    required String letterId,
    required String title,
    required String content,
    required String preview,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
  }) async {
    try {
      final response = await _letterService.replyLetter(
        letterId: letterId,
        title: title,
        content: content,
        preview: preview,
        template: template,
        attachedImages: attachedImages,
      );
      
      if (!response.isSuccess && response.error != null) {
        print('답장 전송 실패: ${response.error?.message}');
      }
      
      // 답장 성공 시 원본 편지 ID 저장 (공개편지에 답장한 경우를 위해)
      if (response.isSuccess && response.data != null) {
        final replyLetterId = response.data!.id;
        await ReplyStorage.saveReplyOriginal(
          replyLetterId: replyLetterId,
          originalLetterId: letterId,
        );
      }
      
      return response.isSuccess;
    } catch (e) {
      print('답장 전송 예외: $e');
      return false;
    }
  }

  /// 답장한 편지의 원본 공개편지를 찾아서 목록에 추가
  /// 공개편지는 답장한 시점(sentAt)에 읽은 것으로 간주하고, 읽음 표시를 함
  Future<List<SharedFlower>> _addOriginalPublicLetters(
    List<SharedFlower> flowers,
    String friendId,
  ) async {
    try {
      // 이미 목록에 있는 편지 ID들
      final existingLetterIds = flowers.map((f) => f.letter.id).toSet();
      
      // 내가 보낸 답장들 중에서 원본 공개편지 찾기
      final myReplies = flowers.where((f) => f.sentByMe).toList();
      final originalPublicLetters = <SharedFlower>[];
      
      for (final reply in myReplies) {
        // 답장한 편지의 원본 편지 ID 조회
        final originalLetterId = await ReplyStorage.getOriginalLetterId(reply.id);
        if (originalLetterId == null) continue;
        
        // 이미 목록에 있으면 스킵
        if (existingLetterIds.contains(originalLetterId)) continue;
        
        // 원본 편지 조회
        final originalLetter = await getLetter(originalLetterId);
        if (originalLetter == null) continue;
        
        // 원본 편지가 공개편지이고, 친구가 보낸 편지인지 확인
        if (originalLetter.visibility == VisibilityScope.public &&
            originalLetter.sender.id == friendId) {
          // 원본 공개편지를 SharedFlower로 변환
          // sentAt은 답장한 시점으로 설정 (내가 읽은 시점)
          // isRead는 true로 설정 (답장을 했다는 것은 읽었다는 의미)
          final originalFlower = SharedFlower(
            id: originalLetter.id,
            letter: originalLetter,
            sentAt: reply.sentAt, // 답장한 시점 = 읽은 시점
            sentByMe: false, // 친구가 보낸 편지
            isRead: true, // 답장을 했다는 것은 읽었다는 의미
          );
          originalPublicLetters.add(originalFlower);
          existingLetterIds.add(originalLetterId);
        }
      }
      
      // 원본 공개편지들과 기존 편지들을 합쳐서 시간순으로 정렬 (최신순)
      final allFlowers = [...originalPublicLetters, ...flowers];
      allFlowers.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      
      return allFlowers;
    } catch (e) {
      print('원본 공개편지 추가 중 에러: $e');
      // 에러가 발생해도 기존 목록은 반환
      return flowers;
    }
  }

  Future<List<SharedFlower>> getFriendLetters({
    required String friendId,
    int page = 0,
    int size = 20,
    String sort = 'sentAt,desc', // 기본값: 최신순
  }) async {
    try {
      print('getFriendLetters 호출: friendId=$friendId, page=$page, size=$size, sort=$sort');
      final response = await _bouquetService.getFriendLetters(
        friendId: friendId,
        page: page,
        size: size,
        sort: sort,
      );
      print('getFriendLetters 응답: success=${response.isSuccess}, error=${response.error?.message}');
      
      if (response.isSuccess && response.data != null) {
        print('getFriendLetters 데이터: ${response.data!.content.length}개');
        try {
          final flowers = response.data!.content.map((dto) {
            try {
              return dto.toModel();
            } catch (e, stackTrace) {
              print('SharedFlowerDto toModel 에러: $e');
              print('Stack trace: $stackTrace');
              print('DTO: $dto');
              rethrow;
            }
          }).toList();
          print('getFriendLetters 변환 완료: ${flowers.length}개');
          
          // 답장한 편지의 원본 공개편지 추가
          final flowersWithOriginal = await _addOriginalPublicLetters(flowers, friendId);
          
          return flowersWithOriginal;
        } catch (e, stackTrace) {
          print('getFriendLetters 변환 에러: $e');
          print('Stack trace: $stackTrace');
          return [];
        }
      }
      
      if (response.error != null) {
        print('getFriendLetters API 에러: ${response.error!.message}');
        // 서버 에러(500)의 경우 빈 리스트 반환 (앱 크래시 방지)
        // UI에서 에러 메시지를 표시할 수 있도록 예외는 던짐
        final errorCode = response.error!.code;
        if (errorCode == 'INTERNAL_SERVER_ERROR' || errorCode.contains('500')) {
          print('getFriendLetters: 서버 에러로 인해 빈 리스트 반환');
          return [];
        }
        throw Exception(response.error!.message);
      }
      
      print('getFriendLetters: 데이터 없음');
      return [];
    } catch (e, stackTrace) {
      print('getFriendLetters 예외: $e');
      print('Stack trace: $stackTrace');
      // 서버 에러의 경우 빈 리스트 반환
      if (e.toString().contains('서버 오류') || e.toString().contains('500')) {
        print('getFriendLetters: 서버 에러로 인해 빈 리스트 반환');
        return [];
      }
      rethrow;
    }
  }

  // Notifications
  Future<List<NotificationItem>> getNotifications({
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _notificationService.getNotifications(
      category: category,
      page: page,
      size: size,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.content.map((dto) => dto.toModel()).toList();
    }
    return [];
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    final response = await _notificationService.markAsRead(notificationId);
    return response.isSuccess;
  }

  Future<bool> markAllNotificationsAsRead() async {
    final response = await _notificationService.markAllAsRead();
    return response.isSuccess;
  }

  Future<bool> deleteNotification(String notificationId) async {
    final response = await _notificationService.deleteNotification(notificationId);
    return response.isSuccess;
  }

  // Friends
  Future<List<FriendProfile>> getFriends() async {
    final response = await _friendService.getFriends();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((dto) => dto.toModel()).toList();
    }
    return [];
  }

  Future<bool> addFriendByInviteCode(String inviteCode) async {
    final response = await _friendService.addFriendByInviteCode(inviteCode);
    return response.isSuccess;
  }

  Future<bool> deleteFriend(String friendId) async {
    final response = await _friendService.deleteFriend(friendId);
    return response.isSuccess;
  }

  // Files
  Future<String?> uploadImage(File imageFile) async {
    final response = await _fileService.uploadImage(imageFile);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return null;
  }

  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final response = await _fileService.uploadImages(imageFiles);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return [];
  }

  // Invite Codes
  Future<InviteCodeDto?> generateInviteCode() async {
    final response = await _inviteCodeService.generateCode();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return null;
  }

  Future<InviteCodeDto?> getCurrentInviteCode() async {
    final response = await _inviteCodeService.getCurrentCode();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return null;
  }

  // Settings
  Future<bool> getPushNotificationSetting() async {
    final response = await _settingsService.getPushNotificationSetting();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return true; // 기본값
  }

  Future<bool> updatePushNotificationSetting(bool enabled) async {
    final response = await _settingsService.updatePushNotificationSetting(enabled);
    return response.isSuccess;
  }

  Future<String?> getLanguageSetting() async {
    final response = await _settingsService.getLanguageSetting();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return null;
  }

  Future<bool> updateLanguageSetting(String languageCode) async {
    final response = await _settingsService.updateLanguageSetting(languageCode);
    return response.isSuccess;
  }

  // User
  Future<TabaUser?> getCurrentUser() async {
    try {
      final response = await _userService.getCurrentUser();
      if (response.isSuccess && response.data != null) {
        return response.data!.toModel();
      }
      
      // 에러가 있으면 로그 출력 (디버깅용)
      if (response.error != null) {
        print('getCurrentUser 실패: ${response.error?.message}');
      }
      
      return null;
    } catch (e) {
      print('getCurrentUser 예외: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? nickname,
    File? profileImage,
    String? avatarUrl, // 이미지 제거 시 null
  }) async {
    try {
      final response = await _userService.updateUser(
        userId: userId,
        nickname: nickname,
        profileImage: profileImage,
        avatarUrl: avatarUrl,
      );
      return response.isSuccess;
    } catch (e) {
      print('updateUserProfile 예외: $e');
      return false;
    }
  }
}

