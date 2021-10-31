import '../../core/application/paginated_repos_notifier.dart';
import '../infrastructure/searched_repos_repository.dart';

class SearchedReposNotifier extends PaginatedReposNotifier {
  SearchedReposNotifier(this._reposRepository);

  final SearchedReposRepository _reposRepository;

  Future<void> getFirstSearchedReposPage(String query) async {
    super.resetState();
    await getNextSearchedReposPage(query);
  }

  Future<void> getNextSearchedReposPage(String query) async {
    super.getNextPage(
      (page) => _reposRepository.getSearchedReposPage(query, page),
    );
  }
}
