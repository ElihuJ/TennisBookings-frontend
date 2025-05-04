import '../global_helpers/index.dart';

class QueryParams {
  final Map<String, String> queryParams;

  QueryParams(this.queryParams);

  String? operator [](String key) => queryParams[key];
}

class ClubSelectedQueryParams extends QueryParams {
  static const clubIdParam = 'clubId';
  late String _clubId;
  static const courtIdParam = 'courtId';
  late String? _courtId;

  ClubSelectedQueryParams(Map<String, String> queryParams) : super(queryParams) {
    try {
      _clubId = queryParams[clubIdParam]!;
      _courtId = queryParams[courtIdParam];
    } catch (e) {
      e.tbLogger('Error in ClubSelectedQueryParams', DebugLevel.error);
      _clubId = '';
      _courtId = null;
    }
  }

  String get clubId => _clubId;
  String? get courtId => _courtId;

  @override
  String toString() {
    return 'ClubSelectedQueryParams{clubId: $_clubId, courtId: $_courtId}';
  }
}
