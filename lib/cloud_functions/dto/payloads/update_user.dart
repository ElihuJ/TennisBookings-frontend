import '../../../state/index.dart';

class UpdateUserPayload {
  final User user;
  final String newName;

  UpdateUserPayload({
    required this.user,
    required this.newName,
  });

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'newName': newName,
      };
}
