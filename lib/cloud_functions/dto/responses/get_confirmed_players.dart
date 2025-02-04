import '../../../models/index.dart';
import 'index.dart';

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
      throw Exception('Error parsing GetConfirmedPlayersDataResponse: $e');
    }
  }
}

// * ===========  Data  ===========
class GetConfirmedPlayersDataResponseData {
  final List<ConfirmedPlayerData> playersData;

  GetConfirmedPlayersDataResponseData({
    required this.playersData,
  }) : super();

  factory GetConfirmedPlayersDataResponseData.fromJson(Map<dynamic, dynamic> map) {
    return GetConfirmedPlayersDataResponseData(
      playersData: map[GetConfirmedPlayersDataResponseDataFields.playersData.name],
    );
  }
}

// * ===========  Fields  ===========
enum GetConfirmedPlayersDataResponseDataFields {
  playersData,
}
