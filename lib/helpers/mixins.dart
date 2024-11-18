mixin HasId {
  String get id;
}

mixin HasIdAndPhotoUrl on HasId, HasPhotoUrl {}

mixin HasPhotoUrl {
  String? get photoUrl;
  String get imageFolder;
}
