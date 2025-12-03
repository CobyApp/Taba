import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/services/auth_service.dart';
import 'package:taba_app/data/services/block_service.dart';
import 'package:taba_app/data/services/bouquet_service.dart';
import 'package:taba_app/data/services/file_service.dart';
import 'package:taba_app/data/services/friend_service.dart';
import 'package:taba_app/data/services/invite_code_service.dart';
import 'package:taba_app/data/dto/invite_code_dto.dart';
import 'package:taba_app/data/dto/add_friend_response_dto.dart';
import 'package:taba_app/data/dto/block_dto.dart';
import 'package:taba_app/data/services/letter_service.dart';
import 'package:taba_app/data/services/notification_service.dart';
import 'package:taba_app/data/services/settings_service.dart';
import 'package:taba_app/data/services/user_service.dart';
import 'package:taba_app/data/services/fcm_service.dart';
import 'package:taba_app/core/services/app_badge_service.dart';
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
  final FcmService _fcmService = FcmService.instance;
  final BlockService _blockService = BlockService();

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

  /// 회원가입 (에러 메시지 포함)
  /// 성공 여부와 함께 에러 메시지도 반환
  Future<({bool success, String? errorMessage})> signupWithError({
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
      return (success: true, errorMessage: null);
    }
    return (success: false, errorMessage: response.error?.message ?? response.message);
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
    
    // 로그아웃 시 배지 초기화
    try {
      await AppBadgeService.instance.removeBadge();
      print('✅ 로그아웃 시 배지 초기화 완료');
    } catch (e) {
      print('❌ 로그아웃 시 배지 초기화 실패: $e');
    }
    
    await _authService.logout();
  }

  Future<bool> isAuthenticated() async {
    return await _authService.isAuthenticated();
  }

  // Letters
  Future<List<Letter>> getPublicLetters({int page = 0, int size = 20, List<String>? languages}) async {
    final response = await _letterService.getPublicLetters(
      page: page,
      size: size,
      languages: languages,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.content.map((dto) => dto.toModel()).toList();
    }
    return [];
  }

  /// 공개 편지 목록 조회 (페이징 정보 포함)
  Future<({List<Letter> letters, bool hasMore})> getPublicLettersWithPagination({int page = 0, int size = 20, List<String>? languages}) async {
    final response = await _letterService.getPublicLetters(
      page: page,
      size: size,
      languages: languages,
    );
    if (response.isSuccess && response.data != null) {
      return (
        letters: response.data!.content.map((dto) => dto.toModel()).toList(),
        hasMore: !response.data!.last, // PageResponse의 last 필드 사용
      );
    }
    return (letters: <Letter>[], hasMore: false);
  }

  Future<Letter?> getLetter(String letterId) async {
    final response = await _letterService.getLetter(letterId);
    if (response.isSuccess && response.data != null) {
      return response.data!.toModel();
    }
    // 404 에러인 경우 null 반환 (삭제된 편지)
    // 에러 정보는 response.error에 있음
    return null;
  }

  /// 편지 조회 시 에러 정보를 포함하여 반환
  /// 삭제된 편지인지 확인하기 위해 사용
  Future<({Letter? letter, bool isNotFound})> getLetterWithError(String letterId) async {
    final response = await _letterService.getLetter(letterId);
    if (response.isSuccess && response.data != null) {
      return (letter: response.data!.toModel(), isNotFound: false);
    }
    // 404 에러인지 확인
    // API 명세서: 404 Not Found - LETTER_NOT_FOUND
    final errorMessage = response.error?.message.toLowerCase() ?? '';
    final isNotFound = response.error?.code == 'GET_LETTER_ERROR' && 
                       (errorMessage.contains('찾을 수 없') ||
                        errorMessage.contains('not found') ||
                        errorMessage.contains('404'));
    return (letter: null, isNotFound: isNotFound);
  }

  Future<bool> createLetter({
    required String title,
    required String content,
    required String preview,
    required String visibility,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
    String? recipientId,
    String? language,
    DateTime? scheduledAt, // 예약 전송 시간 (선택사항)
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
        language: language,
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

  Future<({bool success, String? message})> deleteLetter(String letterId) async {
    final response = await _letterService.deleteLetter(letterId);
    if (response.isSuccess) {
      // API 명세서: Response에 message가 포함될 수 있음
      final message = response.message;
      return (success: true, message: message);
    } else {
      // 에러 메시지 반환
      final errorMessage = response.error?.message;
      return (success: false, message: errorMessage);
    }
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
    String? language,
  }) async {
    try {
      final response = await _letterService.replyLetter(
        letterId: letterId,
        title: title,
        content: content,
        preview: preview,
        template: template,
        attachedImages: attachedImages,
        language: language,
      );
      
      if (!response.isSuccess && response.error != null) {
        print('답장 전송 실패: ${response.error?.message}');
      }
      
      return response.isSuccess;
    } catch (e) {
      print('답장 전송 예외: $e');
      return false;
    }
  }


  Future<List<SharedFlower>> getFriendLetters({
    required String friendId,
    int page = 0,
    int size = 20,
    String sort = 'sentAt,asc', // API 명세서: 오름차순 (오래된 편지부터 최신 편지 순서)
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
          
          // 서버에서 공개편지 추가 로직 처리
          return flowers;
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

  /// 친구 편지 목록 조회 (페이징 정보 포함)
  Future<({List<SharedFlower> flowers, bool hasMore})> getFriendLettersWithPagination({
    required String friendId,
    int page = 0,
    int size = 20,
    String sort = 'sentAt,asc', // API 명세서: 오름차순 (오래된 편지부터 최신 편지 순서)
  }) async {
    try {
      final response = await _bouquetService.getFriendLetters(
        friendId: friendId,
        page: page,
        size: size,
        sort: sort,
      );
      
      if (response.isSuccess && response.data != null) {
        final flowers = response.data!.content.map((dto) => dto.toModel()).toList();
        
        // 서버에서 공개편지 추가 로직 처리
        // PageResponse의 last 필드를 사용하여 더 불러올 페이지가 있는지 확인
        final hasMore = !response.data!.last;
        
        return (flowers: flowers, hasMore: hasMore);
      }
      
      return (flowers: <SharedFlower>[], hasMore: false);
    } catch (e) {
      print('getFriendLettersWithPagination 예외: $e');
      return (flowers: <SharedFlower>[], hasMore: false);
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

  /// 읽지 않은 알림 개수 조회
  /// API 명세서: GET /notifications/unread-count
  Future<int> getUnreadNotificationCount() async {
    final response = await _notificationService.getUnreadCount();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return 0;
  }

  /// 뱃지 동기화
  /// API 명세서: POST /notifications/badge/sync
  /// 앱이 포그라운드로 올라오거나 알림 목록 화면 진입 시 호출
  Future<int> syncBadge() async {
    final response = await _notificationService.syncBadge();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return 0;
  }

  // Friends
  Future<List<FriendProfile>> getFriends() async {
    final response = await _friendService.getFriends();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((dto) => dto.toModel()).toList();
    }
    return [];
  }

  Future<AddFriendResponseDto?> addFriendByInviteCode(String inviteCode) async {
    final response = await _friendService.addFriendByInviteCode(inviteCode);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return null;
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
    if (imageFiles.isEmpty) {
      return [];
    }
    
    final response = await _fileService.uploadImages(imageFiles);
    if (response.isSuccess && response.data != null) {
      // 업로드된 URL 개수가 첨부된 파일 개수와 일치하는지 확인
      if (response.data!.length == imageFiles.length) {
      return response.data!;
      } else {
        throw Exception('일부 이미지 업로드에 실패했습니다. (${response.data!.length}/${imageFiles.length})');
      }
    }
    
    // 업로드 실패 시 에러 메시지와 함께 예외 발생
    final errorMessage = response.error?.message ?? '이미지 업로드에 실패했습니다.';
    throw Exception(errorMessage);
  }

  // Invite Codes
  Future<InviteCodeDto?> generateInviteCode() async {
    try {
    final response = await _inviteCodeService.generateCode();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
      // 에러가 있으면 로그 출력 (디버깅용)
      if (response.error != null) {
        print('초대 코드 생성 실패: ${response.error?.code} - ${response.error?.message}');
      }
      return null;
    } catch (e, stackTrace) {
      print('초대 코드 생성 예외: $e');
      print('Stack trace: $stackTrace');
    return null;
    }
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

  /// 회원탈퇴
  /// DELETE /users/{userId}
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await _userService.deleteUser(userId);
      if (response.isSuccess) {
        // 회원탈퇴 성공 시 로그아웃 처리
        await logout();
      }
      return response.isSuccess;
    } catch (e) {
      print('deleteUser 예외: $e');
      return false;
    }
  }

  // Block (차단)
  
  /// 사용자 차단
  /// POST /blocks/{userId}
  /// 차단하면 친구 관계가 자동으로 삭제됩니다.
  Future<({bool success, String? message})> blockUser(String userId) async {
    try {
      final response = await _blockService.blockUser(userId);
      if (response.isSuccess) {
        return (success: true, message: response.message ?? response.data);
      }
      return (success: false, message: response.error?.message ?? '사용자 차단에 실패했습니다.');
    } catch (e) {
      print('blockUser 예외: $e');
      return (success: false, message: '예상치 못한 오류가 발생했습니다.');
    }
  }

  /// 차단 해제
  /// DELETE /blocks/{userId}
  Future<({bool success, String? message})> unblockUser(String userId) async {
    try {
      final response = await _blockService.unblockUser(userId);
      if (response.isSuccess) {
        return (success: true, message: response.message ?? response.data);
      }
      return (success: false, message: response.error?.message ?? '차단 해제에 실패했습니다.');
    } catch (e) {
      print('unblockUser 예외: $e');
      return (success: false, message: '예상치 못한 오류가 발생했습니다.');
    }
  }

  /// 차단한 사용자 목록 조회
  /// GET /blocks
  Future<List<BlockedUserDto>> getBlockedUsers() async {
    try {
      final response = await _blockService.getBlockedUsers();
      print('📋 getBlockedUsers API 응답: success=${response.isSuccess}, data=${response.data?.length ?? 0}명');
      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      print('📋 getBlockedUsers 실패: ${response.error?.message}');
      return [];
    } catch (e) {
      print('getBlockedUsers 예외: $e');
      return [];
    }
  }
}

