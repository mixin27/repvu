import 'package:dio/dio.dart';

import '../../../../core/infrastructure/dio_extensions.dart';
import '../../../../core/infrastructure/network_exceptions.dart';
import '../../../../core/infrastructure/remote_response.dart';
import '../../../core/infrastructure/github_dto.dart';
import '../../../core/infrastructure/github_headers.dart';
import '../../../core/infrastructure/github_headers_cache.dart';
import '../../../core/infrastructure/pagination_config.dart';

class StarredReposRemoteService {
  StarredReposRemoteService(this._dio, this._headersCache);

  final Dio _dio;
  final GithubHeadersCache _headersCache;

  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredReposPage(
    int page,
  ) async {
    final requestUri = Uri.https(
      'api.github.com',
      '/user/starred',
      {
        'page': '$page',
        'per_page': PaginationConfig.itemsPerPage.toString(),
      },
    );

    final previousHeaders = await _headersCache.getHeaders(requestUri);

    try {
      final response = await _dio.getUri(
        requestUri,
        options: Options(
          headers: {
            'If-None-Match': previousHeaders?.etag ?? '',
          },
        ),
      );

      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
          maxPage: previousHeaders?.link?.maxPage ?? 0,
        );
      } else if (response.statusCode == 200) {
        // Parse headers and save to cache.
        final headers = GithubHeaders.parse(response);
        await _headersCache.saveHeaders(requestUri, headers);

        // Convert from dynamic response data to Map<String, dynamic> and
        // transform to List.
        final convertedData = (response.data as List<dynamic>)
            .map((e) => GithubRepoDTO.fromJson(e as Map<String, dynamic>))
            .toList();
        return RemoteResponse.withNewData(
          convertedData,
          maxPage: headers.link?.maxPage ?? 1, // important: set 1, not 0
        );
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return const RemoteResponse.noConnection();
      } else if (e.error != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }
}
