import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/core/storage/token_storage.dart';
import 'package:taba_app/data/dto/api_response.dart';
import 'package:taba_app/data/dto/user_dto.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _tokenStorage.saveToken(
          apiResponse.data!.token,
          apiResponse.data!.user.id,
        );
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        error: ApiError(
          code: 'LOGIN_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<LoginResponse>> signup({
    required String email,
    required String password,
    required String nickname,
    required bool agreeTerms,
    required bool agreePrivacy,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/signup',
        data: {
          'email': email,
          'password': password,
          'nickname': nickname,
          'agreeTerms': agreeTerms,
          'agreePrivacy': agreePrivacy,
        },
      );

      final apiResponse = ApiResponse<LoginResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        await _tokenStorage.saveToken(
          apiResponse.data!.token,
          apiResponse.data!.user.id,
        );
      }

      return apiResponse;
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        error: ApiError(
          code: 'SIGNUP_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'FORGOT_PASSWORD_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'RESET_PASSWORD_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return ApiResponse<void>.fromJson(
        response.data as Map<String, dynamic>,
        null,
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'CHANGE_PASSWORD_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (e) {
      // 에러가 나도 토큰은 제거
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  Future<bool> isAuthenticated() async {
    return await _tokenStorage.hasToken();
  }
}

class LoginResponse {
  final String token;
  final UserDto user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
