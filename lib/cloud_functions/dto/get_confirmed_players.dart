import '../../models/index.dart';
import 'index.dart';

class GetConfirmedPlayersDataCache {
  final GetConfirmedPlayersDataPayload payload;
  final String cacheKey;
  GetConfirmedPlayersDataResponse? response;

  GetConfirmedPlayersDataCache({
    required this.payload,
    required this.cacheKey,
    this.response,
  });

  GetConfirmedPlayersDataResponse? loadFromCache(String key) {
    if (cacheKey == key) {
      return response;
    }
    return null;
  }

  @override
  String toString() {
    return 'GetConfirmedPlayersDataCache{payload: $payload, cacheKey: $cacheKey}';
  }
}

class GetConfirmedPlayersDataPayload extends BasicBookingPayload {
  static final getConfirmedPlayersDataEndpoint = 'getConfirmedPlayersData';

  final BasicBookingPayload payload;

  GetConfirmedPlayersDataPayload({
    required this.payload,
  }) : super(
          bookingId: payload.bookingId,
          clubId: payload.clubId,
          courtId: payload.courtId,
        );
}

// * ===========  Response  ===========

class GetConfirmedPlayersDataResponse {
  final GetConfirmedPlayersDataResponseData data;
  final ResponseStatus responseStatus;

  GetConfirmedPlayersDataResponse({
    required this.data,
    required this.responseStatus,
  }) : super();

  factory GetConfirmedPlayersDataResponse.fromJson(Map<String, dynamic> map) {
    try {
      final dataRaw = map[ResponseFields.data.name];
      final responseStatusRaw = map[ResponseFields.responseStatus.name];

      ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
      GetConfirmedPlayersDataResponseData data = GetConfirmedPlayersDataResponseData.fromJson(dataRaw);

      return GetConfirmedPlayersDataResponse(
        data: data,
        responseStatus: responseStatus,
      );
    } catch (e) {
      if (map.containsKey(ResponseFields.responseStatus.name)) {
        final responseStatusRaw = map[ResponseFields.responseStatus.name];
        ResponseStatus responseStatus = ResponseStatus.fromJson(responseStatusRaw);
        return GetConfirmedPlayersDataResponse(
          data: GetConfirmedPlayersDataResponseData(playersData: []),
          responseStatus: responseStatus,
        );
      }
      throw Exception('Error parsing GetConfirmedPlayersDataResponse: $e \n\n $map');
    }
  }

  @override
  String toString() {
    return 'GetConfirmedPlayersDataResponse{data: $data, responseStatus: $responseStatus}';
  }
}

// * ===========  Data  ===========
class GetConfirmedPlayersDataResponseData {
  final List<ConfirmedPlayerData> playersData;

  GetConfirmedPlayersDataResponseData({
    required this.playersData,
  }) : super();

  factory GetConfirmedPlayersDataResponseData.fromJson(Map<dynamic, dynamic> map) {
    final playersData = map[GetConfirmedPlayersDataResponseDataFields.playersData.name] as List;
    return GetConfirmedPlayersDataResponseData(
      playersData: playersData.map((e) => ConfirmedPlayerData.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'GetConfirmedPlayersDataResponseData{playersData: $playersData}';
  }
}

// * ===========  Fields  ===========
enum GetConfirmedPlayersDataResponseDataFields {
  playersData,
}
