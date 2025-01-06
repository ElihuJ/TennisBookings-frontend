import '../global_helpers/index.dart';

class QueryParams {
  final Map<String, String> queryParams;

  QueryParams(this.queryParams);

  String? operator [](String key) => queryParams[key];
}

class ClubSelectedQueryParams extends QueryParams {
  static const clubIdParam = 'clubId';
  late String _clubId;

  ClubSelectedQueryParams(Map<String, String> queryParams) : super(queryParams) {
    try {
      _clubId = queryParams[clubIdParam]!;
    } catch (e) {
      e.tbLogger('Error in ClubSelectedQueryParams', DebugLevel.error);
    }
  }

  String get clubId => _clubId;
}
