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
import 'package:taba_app/data/services/letter_service.dart';
import 'package:taba_app/data/services/notification_service.dart';
import 'package:taba_app/data/services/settings_service.dart';
import 'package:taba_app/data/services/user_service.dart';
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

  // Auth
  Future<bool> login(String email, String password) async {
    final response = await _authService.login(email: email, password: password);
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
    return response.isSuccess;
  }

  Future<bool> forgotPassword(String email) async {
    final response = await _authService.forgotPassword(email);
    return response.isSuccess;
  }

  Future<void> logout() async {
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
    required String flowerType,
    required String visibility,
    bool isAnonymous = false,
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
        flowerType: flowerType,
        visibility: visibility,
        isAnonymous: isAnonymous,
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

  /// 편지 답장 (자동 친구 추가)
  /// API 명세서: POST /letters/{letterId}/reply
  Future<bool> replyLetter({
    required String letterId,
    required String title,
    required String content,
    required String preview,
    required String flowerType,
    bool isAnonymous = false,
    Map<String, dynamic>? template,
    List<String>? attachedImages,
  }) async {
    try {
      final response = await _letterService.replyLetter(
        letterId: letterId,
        title: title,
        content: content,
        preview: preview,
        flowerType: flowerType,
        isAnonymous: isAnonymous,
        template: template,
        attachedImages: attachedImages,
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

  // Bouquets
  Future<List<FriendBouquet>> getBouquets() async {
    try {
      final response = await _bouquetService.getBouquets();
      print('Bouquet repository response: success=${response.isSuccess}, data=${response.data?.length ?? 0} items');
      if (response.isSuccess && response.data != null) {
        try {
          final bouquets = response.data!.map((dto) {
            try {
              return dto.toModel();
            } catch (e, stackTrace) {
              print('Error converting BouquetDto to model: $e');
              print('Stack trace: $stackTrace');
              print('DTO: $dto');
              rethrow;
            }
          }).toList();
          print('Successfully converted ${bouquets.length} bouquets');
          return bouquets;
        } catch (e, stackTrace) {
          print('Error converting BouquetDto to model: $e');
          print('Stack trace: $stackTrace');
          return [];
        }
      }
      if (response.error != null) {
        print('Bouquet API error: ${response.error!.message}');
        print('Error code: ${response.error!.code}');
      } else {
        print('Bouquet API error: response.isSuccess=${response.isSuccess}, data is null');
      }
      return [];
    } catch (e, stackTrace) {
      print('Error in getBouquets: $e');
      print('Stack trace: $stackTrace');
      return [];
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

  // Notifications
  Future<List<NotificationItem>> getNotifications({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _notificationService.getNotifications(
      page: page,
      size: size,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!.content.map((dto) => dto.toModel()).toList();
    }
    return [];
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

  // Files
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final response = await _fileService.uploadImages(imageFiles);
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    return [];
  }

  // Invite Codes
  Future<String?> generateInviteCode() async {
    final response = await _inviteCodeService.generateCode();
    if (response.isSuccess && response.data != null) {
      return response.data!.code;
    }
    return null;
  }

  Future<String?> getCurrentInviteCode() async {
    final response = await _inviteCodeService.getCurrentCode();
    if (response.isSuccess && response.data != null) {
      return response.data!.code;
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
    String? statusMessage,
    File? profileImage,
    String? avatarUrl, // 이미지 제거 시 null
  }) async {
    try {
      final response = await _userService.updateUser(
        userId: userId,
        nickname: nickname,
        statusMessage: statusMessage,
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

