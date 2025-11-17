class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Spring Boot API 응답 구조에 맞춰 처리
    // 1. ApiResponse 래퍼가 있는 경우: {success: true, data: {...}}
    // 2. 직접 데이터를 반환하는 경우: {...}
    // 3. Page 객체인 경우: {content: [...], page: 0, ...}
    
    if (json.containsKey('success')) {
      // ApiResponse 래퍼 형식
      return ApiResponse<T>(
        success: json['success'] ?? false,
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : json['data'] as T?,
        message: json['message'],
        error: json['error'] != null
            ? ApiError.fromJson(json['error'] is Map<String, dynamic> 
                ? json['error'] as Map<String, dynamic>
                : {'code': 'ERROR', 'message': json['error'].toString()})
            : null,
      );
    } else if (json.containsKey('content') && json.containsKey('page')) {
      // Page 객체 형식 (페이징 응답)
      return ApiResponse<T>(
        success: true,
        data: fromJsonT != null ? fromJsonT(json) : json as T,
      );
    } else {
      // 직접 데이터 반환 형식
      return ApiResponse<T>(
        success: true,
        data: fromJsonT != null ? fromJsonT(json) : json as T,
      );
    }
  }

  bool get isSuccess => success && error == null;
  bool get isError => !success || error != null;
}

class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? '알 수 없는 오류가 발생했습니다.',
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PageResponse<T>(
      content: (json['content'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      page: json['page'] ?? 0,
      size: json['size'] ?? 20,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}
