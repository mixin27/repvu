import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

import '../domain/github_repo_detail.dart';

part 'github_repo_detail_dto.freezed.dart';
part 'github_repo_detail_dto.g.dart';

@freezed
class GithubRepoDetailDTO with _$GithubRepoDetailDTO {
  const GithubRepoDetailDTO._();
  const factory GithubRepoDetailDTO({
    required String fullName,
    required String html,
    required bool starred,
  }) = _GithubRepoDetailDTO;

  factory GithubRepoDetailDTO.fromJson(Map<String, dynamic> json) =>
      _$GithubRepoDetailDTOFromJson(json);

  GithubRepoDetail toDomain() => GithubRepoDetail(
        fullName: fullName,
        html: html,
        starred: starred,
      );

  static const lastUsedFieldName = 'lastUsed';

  Map<String, dynamic> toSembast() {
    final json = toJson();
    json.remove('fullName');
    json[lastUsedFieldName] = Timestamp.now();
    return json;
  }

  factory GithubRepoDetailDTO.fromSembast(
    RecordSnapshot<String, Map<String, dynamic>> snapshot,
  ) {
    // We need to copy as a modifiable map because `Sembast` use unmodifiable map.
    final copiedMap = Map<String, dynamic>.from(snapshot.value);
    copiedMap['fullName'] = snapshot.key;

    return GithubRepoDetailDTO.fromJson(copiedMap);
  }
}
