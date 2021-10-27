import 'package:collection/collection.dart';
import 'package:sembast/sembast.dart';

import '../../../../core/infrastructure/sembast_database.dart';
import '../../../core/infrastructure/github_dto.dart';
import '../../../core/infrastructure/pagination_config.dart';

class StarredReposLocalService {
  StarredReposLocalService(this._sembastDatabase);

  final SembastDatabase _sembastDatabase;
  final _store = intMapStoreFactory.store('starredRepos');

  /// Update or Insert
  Future<void> upsertPage(
    List<GithubRepoDTO> dtos,
    int page,
  ) async {
    final sembastPage = page - 1;

    // 0, 1, 2 || 3, 4, 5 || 6, 7, 8
    await _store
        .records(
          dtos.mapIndexed(
            (index, _) => index + PaginationConfig.itemsPerPage * sembastPage,
          ),
        )
        .put(
          _sembastDatabase.instance,
          dtos.map((e) => e.toJson()).toList(),
        );
  }

  /// Get pages
  Future<List<GithubRepoDTO>> getPage(int page) async {
    final sembastPage = page - 1;

    final records = await _store.find(
      _sembastDatabase.instance,
      finder: Finder(
        limit: PaginationConfig.itemsPerPage,
        offset: PaginationConfig.itemsPerPage * sembastPage,
      ),
    );

    return records.map((e) => GithubRepoDTO.fromJson(e.value)).toList();
  }

  Future<int> getLocalPageCount() async {
    final repoCount = await _store.count(_sembastDatabase.instance);
    return (repoCount / PaginationConfig.itemsPerPage).ceil();
  }
}
