import "package:dio/dio.dart";
import "../core/constants/app_constants.dart";
import "api_exception.dart";
import "storage_service.dart";

/// Thin wrapper around Dio: attaches the bearer token to every request,
/// unwraps the backend's { success, data } / { success, data, pagination }
/// envelope, and transparently refreshes the access token once on a 401
/// before giving up and forcing a re-login.
class ApiClient {
  ApiClient(this._storage)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra["skipAuth"] != true) {
            final token = await _storage.getAccessToken();
            if (token != null) options.headers["Authorization"] = "Bearer $token";
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthEndpoint = error.requestOptions.path.contains("/auth/");
          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              try {
                final cloned = await _dio.fetch(error.requestOptions);
                return handler.resolve(cloned);
              } catch (_) {
                // fall through to original error
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final StorageService _storage;

  /// Called by AuthNotifier when the session has just been invalidated, so
  /// the UI can react (e.g. redirect to /login) without this layer knowing
  /// about routing.
  void Function()? onSessionExpired;

  Future<bool> _tryRefresh() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await _dio.post(
        "/auth/refresh",
        data: {"refreshToken": refreshToken},
        options: Options(extra: {"skipAuth": true}),
      );
      final data = response.data["data"];
      await _storage.updateAccessToken(data["accessToken"]);
      return true;
    } catch (_) {
      await _storage.clear();
      onSessionExpired?.call();
      return false;
    }
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query, required T Function(dynamic) parse}) async {
    try {
      final response = await _dio.get(path, queryParameters: query);
      return parse(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> post<T>(String path, {Object? data, required T Function(dynamic) parse}) async {
    try {
      final response = await _dio.post(path, data: data);
      return parse(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> patch<T>(String path, {Object? data, required T Function(dynamic) parse}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return parse(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<T> delete<T>(String path, {required T Function(dynamic) parse}) async {
    try {
      final response = await _dio.delete(path);
      return parse(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final data = e.response?.data;
    String message = "Something went wrong. Please try again.";
    if (data is Map && data["message"] != null) {
      final m = data["message"];
      message = m is List ? m.join(", ") : m.toString();
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      message = "Could not reach the server. Check your connection.";
    }
    return ApiException(message, statusCode: e.response?.statusCode);
  }
}

/// Helpers to pull `data` / `{data, pagination}` out of the standard envelope.
dynamic unwrapData(dynamic body) => body is Map && body.containsKey("data") ? body["data"] : body;

int parseInt(dynamic val, [int fallback = 0]) {
  if (val == null) return fallback;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? fallback;
  return fallback;
}

int? parseIntNullable(dynamic val) {
  if (val == null) return null;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

double parseDouble(dynamic val, [double fallback = 0.0]) {
  if (val == null) return fallback;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? fallback;
  return fallback;
}

double? parseDoubleNullable(dynamic val) {
  if (val == null) return null;
  if (val is double) return val;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

bool parseBool(dynamic val, [bool fallback = false]) {
  if (val == null) return fallback;
  if (val is bool) return val;
  if (val is String) return val.toLowerCase() == "true" || val == "1";
  if (val is num) return val != 0;
  return fallback;
}

class Paginated<T> {
  Paginated({required this.data, required this.page, required this.limit, required this.total, required this.totalPages});
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  factory Paginated.fromJson(dynamic body, T Function(Map<String, dynamic>) fromJson) {
    final list = (body["data"] as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
    final pagination = body["pagination"] as Map<String, dynamic>? ?? {};
    return Paginated(
      data: list,
      page: parseInt(pagination["page"], 1),
      limit: parseInt(pagination["limit"], 20),
      total: parseInt(pagination["total"], list.length),
      totalPages: parseInt(pagination["totalPages"], 1),
    );
  }
}
