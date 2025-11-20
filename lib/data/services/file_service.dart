import 'dart:io';
import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';

class FileService {
  final ApiClient _apiClient = ApiClient.instance;

  Future<ApiResponse<String>> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // API 명세서: POST /files
      final response = await _apiClient.dio.post(
        '/files',
        data: formData,
      );

      if (response.data is! Map<String, dynamic>) {
        return ApiResponse<String>(
          success: false,
          error: ApiError(
            code: 'UPLOAD_IMAGE_ERROR',
            message: 'Invalid response format',
          ),
        );
      }

      // API 명세서: {success: true, data: {fileId: "uuid", url: "..."}}
      // url만 사용하므로 String으로 반환
      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) {
          if (data is Map<String, dynamic>) {
            return data['url'] as String;
          }
          throw Exception('Invalid response format: data is not a Map');
        },
      );
    } on DioException catch (e) {
      String errorMessage = '이미지 업로드에 실패했습니다.';
      // API 명세서: 401 Unauthorized, 400 Bad Request, 413 Payload Too Large (파일 크기 초과)
      if (e.response?.statusCode == 401) {
        errorMessage = '인증이 필요합니다. 다시 로그인해주세요.';
      } else if (e.response?.statusCode == 400) {
        // API 명세서: 400 Bad Request - 잘못된 파일 형식
        if (e.response?.data != null) {
          try {
            final errorData = e.response!.data as Map<String, dynamic>;
            final error = errorData['error'] as Map<String, dynamic>?;
            errorMessage = error?['message'] as String? ?? 
                         errorData['message'] as String? ?? 
                         '이미지 파일이 올바르지 않습니다.';
          } catch (_) {
            errorMessage = '이미지 파일이 올바르지 않습니다.';
          }
        } else {
          errorMessage = '이미지 파일이 올바르지 않습니다.';
        }
      } else if (e.response?.statusCode == 413) {
        // API 명세서: 413 Payload Too Large - 최대 파일 크기 10MB
        errorMessage = '파일 크기가 너무 큽니다. (최대 10MB)';
      } else if (e.response?.data != null) {
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          errorMessage = error?['message'] as String? ?? 
                        errorData['message'] as String? ?? 
                        errorData['errorMessage'] as String? ?? 
                        errorMessage;
        } catch (_) {}
      }
      
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPLOAD_IMAGE_ERROR',
          message: errorMessage,
        ),
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPLOAD_IMAGE_ERROR',
          message: '예상치 못한 오류가 발생했습니다: ${e.toString()}',
        ),
      );
    }
  }

  Future<ApiResponse<List<String>>> uploadImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];
    
    for (final file in imageFiles) {
      final result = await uploadImage(file);
      if (result.isSuccess && result.data != null) {
        uploadedUrls.add(result.data!);
      } else {
        return ApiResponse<List<String>>(
          success: false,
          error: result.error,
        );
      }
    }

    return ApiResponse<List<String>>(
      success: true,
      data: uploadedUrls,
    );
  }
}

