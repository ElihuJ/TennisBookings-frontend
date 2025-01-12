import 'package:flutter/foundation.dart';

@immutable
class CloudFunctions {
  final String? uid;

  get isLoggedIn => uid != null;

  const CloudFunctions({
    this.uid,
  });

  const CloudFunctions.empty() : uid = null;

  CloudFunctions copyWith({String? uid}) => CloudFunctions(
        uid: uid ?? this.uid,
      );

  @override
  String toString() {
    return 'FirebaseUser('
        'uid: $uid'
        ');';
  }

  @override
  bool operator ==(covariant CloudFunctions other) {
    if (identical(this, other)) return true;

    return other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
