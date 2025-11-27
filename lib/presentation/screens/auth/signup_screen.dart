import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/screens/auth/terms_screen.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:dio/dio.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: '${AppStrings.photoSelectionError(locale)}: $e');
      }
    }
  }

  Future<void> _takeProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        // iOS에서 카메라 권한이 없거나 카메라가 없을 때 발생하는 에러 처리
        final errorMessage = e.message?.toLowerCase() ?? e.code.toLowerCase();
        if (errorMessage.contains('camera') || 
            errorMessage.contains('not available') ||
            errorMessage.contains('no camera') ||
            errorMessage.contains('source type 1') ||
            errorMessage.contains('source type unavailable') ||
            errorMessage.contains('permission') ||
            errorMessage.contains('privacy')) {
          showTabaError(
            context, 
            message: AppStrings.cameraNotAvailable(locale),
          );
        } else {
          showTabaError(
            context, 
            message: '${AppStrings.photoError(locale)}: ${e.message ?? e.code}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('camera') || 
            errorMessage.contains('not available') ||
            errorMessage.contains('no camera')) {
          showTabaError(
            context, 
            message: AppStrings.cameraNotAvailable(locale),
          );
        } else {
          showTabaError(
            context, 
            message: '${AppStrings.photoError(locale)}: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showImagePickerOptions() {
    TabaModalSheet.show(
      context: context,
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.localeNotifier,
        builder: (context, locale, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppStrings.selectFromGallery(locale)),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppStrings.takePhoto(locale)),
                onTap: () {
                  Navigator.pop(context);
                  _takeProfileImage();
                },
              ),
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(AppStrings.removePhoto(locale)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                    });
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  bool _isLoading = false;

  Future<void> _submit() async {
    final locale = AppLocaleController.localeNotifier.value;
    
    if (!_agreeTerms || !_agreePrivacy) {
      if (mounted) {
        showTabaError(context, message: AppStrings.agreeTermsRequired(locale));
      }
      return;
    }
    
    if (_passwordCtrl.text != _confirmCtrl.text) {
      if (mounted) {
        showTabaError(context, message: AppStrings.passwordMismatch(locale));
      }
      return;
    }

    if (_emailCtrl.text.isEmpty ||
        _nicknameCtrl.text.isEmpty ||
        _passwordCtrl.text.isEmpty) {
      if (mounted) {
        showTabaError(context, message: AppStrings.allFieldsRequired(locale));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 에러 메시지도 함께 받기 위해 signupWithError 사용
      final result = await DataRepository.instance.signupWithError(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        nickname: _nicknameCtrl.text.trim(),
        agreeTerms: _agreeTerms,
        agreePrivacy: _agreePrivacy,
        profileImage: _profileImage,
      );

      if (mounted) {
        if (result.success) {
          // 회원가입 성공 시 화면을 닫고 콜백 호출
          Navigator.of(context).pop();
          widget.onSuccess();
        } else {
          // API에서 반환한 구체적인 에러 메시지 표시
          final errorMessage = result.errorMessage ?? AppStrings.signupFailed(locale);
          showTabaError(context, message: errorMessage);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMessage = AppStrings.signupFailed(locale);
        
        if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
          // 400 Bad Request 또는 409 Conflict (이미 존재하는 이메일 등)
          if (e.response?.data != null) {
            try {
              final errorData = e.response!.data as Map<String, dynamic>;
              final error = errorData['error'] as Map<String, dynamic>?;
              final apiMessage = error?['message'] as String? ?? 
                                errorData['message'] as String?;
              if (apiMessage != null && apiMessage.isNotEmpty) {
                errorMessage = apiMessage;
              }
            } catch (_) {
              // JSON 파싱 실패 시 기본 메시지 사용
            }
          }
        } else if (e.type == DioExceptionType.connectionTimeout || 
                   e.type == DioExceptionType.receiveTimeout) {
          errorMessage = AppStrings.networkTimeout(locale);
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = AppStrings.networkConnectionError(locale);
        }
        
        showTabaError(context, message: errorMessage);
      }
    } catch (e) {
      if (mounted) {
        showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: AppColors.gradientDusk,
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    NavHeader(
                      showBackButton: true,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.xl,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                        Text(
                          AppStrings.signupSubtitle(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl * 1.5),
                        // 프로필 이미지 선택
                        Center(
                          child: GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white.withAlpha(30),
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? const Icon(
                                          Icons.add_a_photo,
                                          size: 40,
                                          color: Colors.white70,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.neonPink,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          AppStrings.selectProfilePhoto(locale),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl * 1.5),
                        TabaCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              TabaTextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                labelText: AppStrings.email(locale),
                                hintText: AppStrings.emailHint(locale),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TabaTextField(
                                controller: _nicknameCtrl,
                                labelText: AppStrings.nickname(locale),
                                hintText: AppStrings.nicknamePlaceholder(locale),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TabaTextField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                labelText: AppStrings.password(locale),
                                hintText: AppStrings.passwordPlaceholder(locale),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TabaTextField(
                                controller: _confirmCtrl,
                                obscureText: true,
                                labelText: AppStrings.confirmPassword(locale),
                                hintText: AppStrings.passwordPlaceholder(locale),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreeTerms,
                                    onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppStrings.agreeToTerms(locale),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () async {
                                      final agreed = await TabaModalSheet.show<bool>(
                                        context: context,
                                        fixedSize: true,
                                        child: const TermsOnlyContent(),
                                      );
                                      if (agreed == true && mounted) {
                                        setState(() => _agreeTerms = true);
                                      }
                                    },
                                    child: Text(
                                      AppStrings.viewTerms(locale),
                                      style: const TextStyle(decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreePrivacy,
                                    onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                                  ),
                                  Expanded(
                                    child: Text(
                                      AppStrings.agreeToPrivacy(locale),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14, color: Colors.white70),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () async {
                                      final agreed = await TabaModalSheet.show<bool>(
                                        context: context,
                                        fixedSize: true,
                                        child: const PrivacyOnlyContent(),
                                      );
                                      if (agreed == true && mounted) {
                                        setState(() => _agreePrivacy = true);
                                      }
                                    },
                                    child: Text(
                                      AppStrings.viewTerms(locale),
                                      style: const TextStyle(decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TabaButton(
                                onPressed: (_agreeTerms && _agreePrivacy && !_isLoading)
                                    ? _submit
                                    : null,
                                label: AppStrings.signupButton(locale),
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}


