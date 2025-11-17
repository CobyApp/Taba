import 'package:taba_app/data/dto/user_dto.dart';

class SignupRequest {
  final String email;
  final String password;
  final String nickname;
  final bool agreeTerms;
  final bool agreePrivacy;
  
  SignupRequest({
    required this.email,
    required this.password,
    required this.nickname,
    required this.agreeTerms,
    required this.agreePrivacy,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nickname': nickname,
      'agreeTerms': agreeTerms,
      'agreePrivacy': agreePrivacy,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;
  
  LoginRequest({
    required this.email,
    required this.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class AuthResponse {
  final String? token;
  final String? userId;
  final UserDto? user;
  
  AuthResponse({
    this.token,
    this.userId,
    this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      userId: json['userId'],
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
    );
  }
}

class ForgotPasswordRequest {
  final String email;
  
  ForgotPasswordRequest({required this.email});
  
  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

class ResetPasswordRequest {
  final String token;
  final String newPassword;
  
  ResetPasswordRequest({
    required this.token,
    required this.newPassword,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'newPassword': newPassword,
    };
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  
  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

