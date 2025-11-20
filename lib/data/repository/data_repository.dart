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
import 'package:taba_app/data/dto/add_friend_response_dto.dart';
import 'package:taba_app/data/services/letter_service.dart';
import 'package:taba_app/data/services/notification_service.dart';
import 'package:taba_app/data/services/settings_service.dart';
import 'package:taba_app/data/services/user_service.dart';
import 'package:taba_app/data/services/fcm_service.dart';
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
    return null;
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
  }) async {
    try {
      final response = await _letterService.createLetter(
        title: title,
        content: content,
        preview: preview,
        visibility: visibility,
        template: template,
        attachedImages: attachedImages,
        scheduledAt: null, // 예약 발송 기능 제거
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
}

