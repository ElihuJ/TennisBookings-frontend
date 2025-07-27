import '../global_helpers/index.dart';

class QueryParams {
  final Map<String, String> queryParams;

  QueryParams(this.queryParams);

  String? operator [](String key) => queryParams[key];

  void addFields(QueryParams params) {
    queryParams.addAll(params.queryParams);
  }

  @override
  String toString() {
    return 'QueryParams{queryParams: $queryParams}';
  }
}

class ClubSelectedQueryParams extends QueryParams {
  static const clubIdParam = 'clubId';
  late String _clubId;
  static const courtIdParam = 'courtId';
  late String? _courtId;
  static const bookingIdParam = 'bookingId';
  late String? _bookingId;

  ClubSelectedQueryParams(Map<String, String> queryParams) : super(queryParams) {
    try {
      _clubId = queryParams[clubIdParam]!;
      _courtId = queryParams[courtIdParam];
      _bookingId = queryParams[bookingIdParam];
    } catch (e) {
      e.tbLogger('Error in ClubSelectedQueryParams', DebugLevel.error);
      _clubId = '';
      _courtId = null;
      _bookingId = null;
    }
  }

  String get clubId => _clubId;
  String? get courtId => _courtId;
  String? get bookingId => _bookingId;

  @override
  String toString() {
    return 'ClubSelectedQueryParams{clubId: $_clubId, courtId: $_courtId, bookingId: $_bookingId}';
  }
}

class StripePaymentQueryParams extends QueryParams {
  static const paymentIntentParam = 'payment_intent';
  late String _paymentIntent;
  static const paymentIntentClientSecretParam = 'payment_intent_client_secret';
  late String _paymentIntentClientSecret;
  static const redirectStatusParam = 'redirect_status';
  late StripePaymentRedirectStatus _redirectStatus;
  static const clubIdParam = 'clubId';
  late String _clubId;
  static const courtIdParam = 'courtId';
  late String _courtId;

  StripePaymentQueryParams(Map<String, String> queryParams) : super(queryParams) {
    try {
      _paymentIntentClientSecret = queryParams[paymentIntentClientSecretParam] ?? '';
      _paymentIntent = queryParams[paymentIntentParam] ?? '';
      _clubId = queryParams[clubIdParam] ?? '';
      _courtId = queryParams[courtIdParam] ?? '';
      _redirectStatus = queryParams[redirectStatusParam] == 'succeeded'
          ? StripePaymentRedirectStatus.succeeded
          : queryParams[redirectStatusParam] == 'requires_action'
              ? StripePaymentRedirectStatus.requiresAction
              : StripePaymentRedirectStatus.requiresPaymentMethod;
    } catch (e) {
      e.tbLogger('Error in StripePaymentQueryParams', DebugLevel.error);
      _paymentIntentClientSecret = '';
      _paymentIntent = '';
      _redirectStatus = StripePaymentRedirectStatus.requiresPaymentMethod;
      _clubId = '';
      _courtId = '';
    }
  }

  String get paymentIntentClientSecret => _paymentIntentClientSecret;
  String get paymentIntent => _paymentIntent;
  StripePaymentRedirectStatus get redirectStatus => _redirectStatus;
  String get clubId => _clubId;
  String get courtId => _courtId;

  @override
  String toString() {
    return 'StripePaymentQueryParams{paymentIntentClientSecret: $_paymentIntentClientSecret, paymentIntent: $_paymentIntent},'
        'redirectStatus: $_redirectStatus, clubId: $_clubId, courtId: $_courtId}';
  }
}

enum StripePaymentRedirectStatus {
  requiresAction,
  succeeded,
  requiresPaymentMethod,
}
