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
import 'package:taba_app/core/storage/token_storage.dart';
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
  final TokenStorage _tokenStorage = TokenStorage();

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
  }) async {
    final response = await _authService.signup(
      email: email,
      password: password,
      nickname: nickname,
      agreeTerms: agreeTerms,
      agreePrivacy: agreePrivacy,
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

  Future<bool> likeLetter(String letterId) async {
    final response = await _letterService.likeLetter(letterId);
    return response.isSuccess;
  }

  Future<bool> saveLetter(String letterId) async {
    final response = await _letterService.saveLetter(letterId);
    return response.isSuccess;
  }

  Future<bool> reportLetter(String letterId, String reason) async {
    final response = await _letterService.reportLetter(
      letterId: letterId,
      reason: reason,
    );
    return response.isSuccess;
  }

  // Bouquets
  Future<List<FriendBouquet>> getBouquets() async {
    final response = await _bouquetService.getBouquets();
    if (response.isSuccess && response.data != null) {
      return response.data!.map((dto) => dto.toModel()).toList();
    }
    return [];
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
}

