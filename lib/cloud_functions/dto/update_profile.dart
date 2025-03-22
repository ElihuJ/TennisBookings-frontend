import '../../global_helpers/index.dart';
import 'shared/index.dart';

class UpdateProfilePayload implements APIPayload {
  static final endpoint = 'updateProfile';

  final int dob;
  final String name;
  final String photoUrl;
  final String gender;

  UpdateProfilePayload({required this.dob, required this.name, required this.photoUrl, required this.gender}) : super();

  @override
  Map<String, dynamic> toJson() {
    return {
      'dob': dob,
      'name': name,
      'photoUrl': photoUrl,
      'gender': gender,
    };
  }

  @override
  String toString() {
    return 'UpdateProfilePayload(dob: $dob, name: $name, photoUrl: $photoUrl, gender: $gender)';
  }
}

// * ===========  Response  ===========

class UpdateProfileResponse extends BasicResponse {
  final BasicResponse response;

  UpdateProfileResponse({
    required this.response,
  }) : super(data: response.data, responseStatus: response.responseStatus);

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> map) {
    try {
      final response = BasicResponse.fromJson(map);
      return UpdateProfileResponse(response: response);
    } catch (e) {
      throw Exception('Error parsing UpdateProfileResponse: $e \n\n $map');
    }
  }
}
