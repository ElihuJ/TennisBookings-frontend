import '../global_types/index.dart';

abstract class HasJson<T> {
  factory HasJson.fromJson(FirestoreResponse json) => throw UnimplementedError();
  factory HasJson.empty() => throw UnimplementedError();
  Map<String, dynamic> toJson() => throw UnimplementedError();
}

abstract class HasName {
  String get name;
}

abstract class IsEnum {
  String get locale;
  String get name;
}
