// * ===========  Data  ===========
class UpdateUserResponseData {
  final String newName;

  UpdateUserResponseData({
    required this.newName,
  }) : super();

  factory UpdateUserResponseData.fromMap(Map<dynamic, dynamic> map) {
    return UpdateUserResponseData(
      newName: map[UpdateUserResponseDataFields.newName.name],
    );
  }
}

// * ===========  Fields  ===========
enum UpdateUserResponseDataFields {
  newName,
}
