import '../../core/application/paginated_repos_notifier.dart';
import '../infrastructure/starred_repos_repository.dart';

class StarredReposNotifier extends PaginatedReposNotifier {
  StarredReposNotifier(this._reposRepository);

  final StarredReposRepository _reposRepository;

  Future<void> getFirstStarredReposPage() async {
    super.resetState();
    await getNextStarredReposPage();
  }

  Future<void> getNextStarredReposPage() async {
    super.getNextPage((page) => _reposRepository.getStarredReposPage(page));
  }
}
