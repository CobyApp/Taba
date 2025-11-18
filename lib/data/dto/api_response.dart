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
    } else if (json.containsKey('content') && (json.containsKey('page') || json.containsKey('number'))) {
      // Page 객체 형식 (페이징 응답)
      // API 명세서: {content: [...], totalElements, totalPages, size, number}
      // PageResponse는 ApiResponse의 data로 래핑되어 있으므로 직접 파싱
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
  
  // API 명세서에 따른 필드 (number는 page와 동일)
  final int number; // API 명세서에서 사용하는 필드명
  
  // Swagger 응답 구조 지원 (optional)
  final int? pageSize;
  final int? offset;
  final bool? paged;
  final bool? unpaged;
  
  PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    int? number,
    this.pageSize,
    this.offset,
    this.paged,
    this.unpaged,
  }) : number = number ?? page; // number가 없으면 page 사용
  
  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    // API 명세서 및 Swagger 응답 구조에 따른 페이지네이션 파싱
    // Swagger: { success: true, data: { content: [...], totalElements, totalPages, size, number, first, last, pageable: {...} } }
    // API 명세서: { success: true, data: { content: [...], totalElements, totalPages, size, number } }
    
    // pageable 객체에서 값 추출 (Swagger 응답 형식)
    final pageable = json['pageable'] as Map<String, dynamic>?;
    final pageableSize = pageable?['pageSize'] as int?;
    final pageableOffset = pageable?['offset'] as int?;
    final pageableNumber = pageable?['pageNumber'] as int?;
    
    // 직접 필드에서 값 추출 (API 명세서 형식)
    final size = json['size'] as int? ?? pageableSize ?? 20;
    final offset = pageableOffset ?? 0;
    final number = json['number'] as int? ?? pageableNumber ?? 0;
    final page = number; // number와 page는 동일
    
    final totalElements = json['totalElements'] as int? ?? 0;
    final totalPages = json['totalPages'] as int? ?? 0;
    
    // first와 last 계산 (명시되지 않은 경우)
    final first = json['first'] as bool? ?? (number == 0);
    final last = json['last'] as bool? ?? (totalPages == 0 || number >= totalPages - 1);
    
    // pageable 객체의 추가 정보
    final pageablePaged = pageable?['paged'] as bool?;
    final pageableUnpaged = pageable?['unpaged'] as bool?;
    
    return PageResponse<T>(
      content: (json['content'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item))
              .toList() ??
          [],
      page: page,
      number: number,
      size: size,
      totalElements: totalElements,
      totalPages: totalPages,
      first: first,
      last: last,
      pageSize: pageableSize ?? size,
      offset: offset,
      paged: pageablePaged ?? json['paged'] as bool?,
      unpaged: pageableUnpaged ?? json['unpaged'] as bool?,
    );
  }
  
  bool get hasMore => !last;
}
