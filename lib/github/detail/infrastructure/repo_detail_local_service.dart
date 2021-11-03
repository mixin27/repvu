import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

import '../../../core/infrastructure/sembast_database.dart';
import '../../core/infrastructure/github_headers_cache.dart';
import 'github_repo_detail_dto.dart';

class RepoDetailLocalService {
  static const cacheSize = 50;

  final SembastDatabase _sembastDatabase;
  final GithubHeadersCache _headersCache;

  final _store = stringMapStoreFactory.store('repoDetails');

  RepoDetailLocalService(
    this._sembastDatabase,
    this._headersCache,
  );

  Future<void> upsertRepoDetail(GithubRepoDetailDTO githubRepoDetailDTO) async {
    await _store.record(githubRepoDetailDTO.fullName).put(
          _sembastDatabase.instance,
          githubRepoDetailDTO.toSembast(),
        );

    final keys = await _store.findKeys(
      _sembastDatabase.instance,
      finder: Finder(
        sortOrders: [
          SortOrder(GithubRepoDetailDTO.lastUsedFieldName, false),
        ],
      ),
    );

    if (keys.length > cacheSize) {
      final keysToRemove = keys.sublist(cacheSize);
      for (final key in keysToRemove) {
        await _store.record(key).delete(_sembastDatabase.instance);

        // we also need to remove headers local cache
        await _headersCache.deleteHeaders(
          Uri.https(
            'api.github.com',
            '/repos/$key/readme',
          ),
        );
      }
    }
  }

  Future<GithubRepoDetailDTO?> getRepoDetail(String fullRepoName) async {
    final record = _store.record(fullRepoName);
    await record.update(
      _sembastDatabase.instance,
      {
        GithubRepoDetailDTO.lastUsedFieldName: Timestamp.now(),
      },
    );

    final recordSnapshot = await record.getSnapshot(_sembastDatabase.instance);

    if (recordSnapshot == null) {
      return null;
    }

    return GithubRepoDetailDTO.fromSembast(recordSnapshot);
  }
}
