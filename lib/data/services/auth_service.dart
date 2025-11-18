import 'dart:io';
import 'package:dio/dio.dart';
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
        
        // Swagger 테스트용 토큰 출력
        print('🔑 Bearer Token for Swagger (Login):');
        print('   ${apiResponse.data!.token}');
        print('   (Copy this token to use in Swagger Authorization)');
      }

      return apiResponse;
    } on DioException catch (e) {
      String errorMessage = '로그인에 실패했습니다.';
      if (e.response?.statusCode == 401) {
        errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<LoginResponse>(
        success: false,
        error: ApiError(
          code: 'LOGIN_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        error: ApiError(
          code: 'LOGIN_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
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
    File? profileImage,
  }) async {
    try {
      FormData formData;
      
      if (profileImage != null) {
        // multipart/form-data로 프로필 이미지 포함
        formData = FormData.fromMap({
          'email': email,
          'password': password,
          'nickname': nickname,
          'agreeTerms': agreeTerms,
          'agreePrivacy': agreePrivacy,
          'profileImage': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
        });
      } else {
        // 프로필 이미지 없이 일반 form-data
        formData = FormData.fromMap({
          'email': email,
          'password': password,
          'nickname': nickname,
          'agreeTerms': agreeTerms,
          'agreePrivacy': agreePrivacy,
        });
      }
      
      final response = await _apiClient.dio.post(
        '/auth/signup',
        data: formData,
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
        
        // Swagger 테스트용 토큰 출력
        print('🔑 Bearer Token for Swagger (Signup):');
        print('   ${apiResponse.data!.token}');
        print('   (Copy this token to use in Swagger Authorization)');
      }

      return apiResponse;
    } on DioException catch (e) {
      String errorMessage = '회원가입에 실패했습니다.';
      if (e.response?.statusCode == 400) {
        errorMessage = '입력 정보가 올바르지 않습니다.';
      } else if (e.response?.statusCode == 409) {
        errorMessage = '이미 존재하는 이메일입니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<LoginResponse>(
        success: false,
        error: ApiError(
          code: 'SIGNUP_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<LoginResponse>(
        success: false,
        error: ApiError(
          code: 'SIGNUP_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
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
    } on DioException catch (e) {
      String errorMessage = '비밀번호 찾기에 실패했습니다.';
      if (e.response?.statusCode == 404) {
        errorMessage = '등록되지 않은 이메일입니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'FORGOT_PASSWORD_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'FORGOT_PASSWORD_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
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
    } on DioException catch (e) {
      String errorMessage = '비밀번호 재설정에 실패했습니다.';
      if (e.response?.statusCode == 400) {
        errorMessage = '재설정 토큰이 유효하지 않거나 만료되었습니다.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'RESET_PASSWORD_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'RESET_PASSWORD_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
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
    } on DioException catch (e) {
      String errorMessage = '비밀번호 변경에 실패했습니다.';
      if (e.response?.statusCode == 400) {
        errorMessage = '현재 비밀번호가 올바르지 않습니다.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? 
                        (errorData['error'] is Map ? (errorData['error'] as Map)['message'] : errorData['error']) ??
                        errorData['errorMessage'] ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'CHANGE_PASSWORD_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        error: ApiError(
          code: 'CHANGE_PASSWORD_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
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
