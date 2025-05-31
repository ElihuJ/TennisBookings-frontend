import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../config/config.dart';

final firebase = fb_auth.FirebaseAuth.instance;

@immutable
class FirebaseAuth {
  final String? uid;
  final String? email;
  final bool emailVerified;
  final String? displayName;
  final String? photoUrl;
  final fb_auth.UserMetadata? metadata;
  final fb_auth.FirebaseAuth firebaseInstance;
  final GoogleSignIn googleSignIn;

  FirebaseAuth({
    this.displayName,
    this.email,
    required this.emailVerified,
    this.uid,
    this.metadata,
    this.photoUrl,
  })  : firebaseInstance = fb_auth.FirebaseAuth.instance,
        googleSignIn = Config().googleSignInConfig;
  FirebaseAuth.empty()
      : uid = null,
        email = null,
        emailVerified = false,
        displayName = null,
        photoUrl = null,
        metadata = null,
        firebaseInstance = fb_auth.FirebaseAuth.instance,
        googleSignIn = Config().googleSignInConfig;

  FirebaseAuth copyWith({
    String? uid,
    String? displayName,
    String? email,
    bool? emailVerified,
    fb_auth.UserMetadata? metadata,
    String? photoUrl,
  }) =>
      FirebaseAuth(
        uid: uid ?? this.uid,
        email: email ?? this.email,
        emailVerified: emailVerified ?? this.emailVerified,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        metadata: metadata ?? this.metadata,
      );

  @override
  String toString() {
    return 'FirebaseUser('
        'uid: $uid'
        'email: $email, '
        'emailVerified: $emailVerified'
        'displayName: $displayName, '
        'photoUrl: $photoUrl, '
        'metadata: $metadata, '
        ');';
  }

  @override
  bool operator ==(covariant FirebaseAuth other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.email == email &&
        other.emailVerified == emailVerified &&
        other.displayName == displayName &&
        other.photoUrl == photoUrl &&
        other.metadata == metadata;
  }

  @override
  int get hashCode => displayName.hashCode ^ email.hashCode ^ emailVerified.hashCode ^ uid.hashCode ^ photoUrl.hashCode ^ metadata.hashCode;
}
