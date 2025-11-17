import 'dart:io';
import 'package:dio/dio.dart';
import 'package:taba_app/core/network/api_client.dart';
import 'package:taba_app/data/dto/api_response.dart';

class FileService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<String>> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        '/files/upload',
        data: formData,
      );

      return ApiResponse<String>.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['url'] as String,
      );
    } catch (e) {
      return ApiResponse<String>(
        success: false,
        error: ApiError(
          code: 'UPLOAD_IMAGE_ERROR',
          message: e.toString(),
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

