import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/services/auth_service.dart';
import 'package:taba_app/data/services/bouquet_service.dart';
import 'package:taba_app/data/services/friend_service.dart';
import 'package:taba_app/data/services/letter_service.dart';
import 'package:taba_app/data/services/notification_service.dart';
import 'package:taba_app/data/services/user_service.dart';
import 'package:taba_app/core/storage/token_storage.dart';

class DataRepository {
  DataRepository._();
  static final DataRepository instance = DataRepository._();

  final AuthService _authService = AuthService();
  final LetterService _letterService = LetterService();
  final BouquetService _bouquetService = BouquetService();
  final FriendService _friendService = FriendService();
  final NotificationService _notificationService = NotificationService();
  final UserService _userService = UserService();
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

  // User
  Future<TabaUser?> getCurrentUser() async {
    final userId = await _tokenStorage.getUserId();
    if (userId == null) return null;
    
    final response = await _userService.getUser(userId);
    if (response.isSuccess && response.data != null) {
      return response.data!.toModel();
    }
    return null;
  }
}

