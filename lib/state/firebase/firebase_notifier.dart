import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../config/apple_sign_in.dart';
import '../../global_helpers/index.dart';
import '../../global_types/index.dart';
import '../../models/index.dart';
import '../../strings/firebase/index.dart';
import '../index.dart';
import 'helpers.dart';

final usersCollection = FirebaseFirestore.instance.collection(FirestoreCollection.users);

class FirebaseAuthNotifier extends StateNotifier<FirebaseAuth> {
  FirebaseAuthNotifier() : super(FirebaseAuth.empty());

  Future<RegisterResult> createAccount({required String email, required String password}) async {
    ErrorInfo? errorMessage;
    try {
      final userCredentials = await firebase.createUserWithEmailAndPassword(email: email, password: password);
      final user = userCredentials.user;
      if (user != null) {
        user.sendEmailVerification();
        return (user, null);
      }
    } on fb_auth.FirebaseAuthException catch (error) {
      errorMessage = getErrorMessage(errorCode: error.code);
    } catch (error) {
      errorMessage = (MessageType.error, FirebaseErrorStrings.somethingWentWrong);
    }
    return (null, errorMessage);
  }

  Future<ErrorInfo?> login({required String email, required String password}) async {
    ErrorInfo? errorMessage;
    try {
      final userCredentials = await firebase.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredentials.user;
      if (user == null) {
        return (MessageType.error, FirebaseErrorStrings.loginFailed);
      }
      if (!user.emailVerified) {
        return (MessageType.info, FirebaseErrorStrings.notVerified);
      }
      loginUser(user);
      return null;
    } on fb_auth.FirebaseAuthException catch (error) {
      errorMessage = getErrorMessage(errorCode: error.code);
    } catch (error) {
      errorMessage = (MessageType.error, FirebaseErrorStrings.somethingWentWrong);
    }
    return errorMessage;
  }

  Future<ErrorInfo?> resetPassword({required String email}) async {
    try {
      await firebase.sendPasswordResetEmail(email: email);
      return null;
    } on fb_auth.FirebaseAuthException catch (error) {
      if (error.code == FirebaseAuthErrorCode.userNotFound) {
        return null;
      }
      return getErrorMessage(errorCode: error.code);
    }
  }

  Future<void> logout() async {
    await firebase.signOut();
    state = FirebaseAuth.empty();
  }

  Future<RegisterResult> signInWithGoogle({ResultHandler? resultHandler}) async {
    final localResultHandler = resultHandler ?? ResultHandler();
    try {
      final googleUser = await state.googleSignIn.signIn();
      googleUser?.tbLogger('Google User');
      if (googleUser == null) {
        localResultHandler.errorInfo = (MessageType.error, FirebaseErrorStrings.loginFailed);
        return (null, localResultHandler.error);
      }
      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await firebase.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        localResultHandler.errorInfo = (MessageType.error, FirebaseErrorStrings.loginFailed);
        return (null, localResultHandler.error);
      }
      // * Check if user exists in database
      final userDocument = await usersCollection.doc(state.firebaseInstance.currentUser?.uid).get();

      loginUser(user);
      // * If user does not exist, return user so we create user with user notifier
      // * With the user details
      if (!userDocument.exists) {
        return (user, localResultHandler.error);
      }
      // * If user exists, return null
      return (null, null);
    } on fb_auth.FirebaseAuthException catch (error) {
      error.tbLogger('Error Auth', DebugLevel.error);
      localResultHandler.errorInfo = getErrorMessage(errorCode: error.code);
      return (null, localResultHandler.error);
    } catch (error) {
      error.tbLogger('Error', DebugLevel.error);
      localResultHandler.errorInfo = (MessageType.error, FirebaseErrorStrings.somethingWentWrong);
      return (null, localResultHandler.error);
    }
  }

  void loginUser(fb_auth.User user) {
    state = FirebaseAuth(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      metadata: user.metadata,
    );
  }

  // * APPLE LOGIN

  Future<RegisterResult> signInWithApple({ResultHandler? resultHandler}) async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final localResultHandler = resultHandler ?? ResultHandler();
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: appleScopes,
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = fb_auth.OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final userCredential = await state.firebaseInstance.signInWithCredential(oauthCredential);
      final user = userCredential.user;

      if (user == null) {
        localResultHandler.errorInfo = (MessageType.error, FirebaseErrorStrings.loginFailed);
        return (null, localResultHandler.error);
      }

      // * Check if user exists in database
      // final userDocument = await usersCollection.doc(state.firebaseInstance.currentUser?.uid).get();

      loginUser(user);
      // * If user does not exist, return user so we create user with user notifier
      // * With the user details
      // if (!userDocument.exists) {
      // return (user, localResultHandler.error);
      // }
      // * If user exists, return null
      return (null, null);
    } on fb_auth.FirebaseAuthException catch (error) {
      localResultHandler.errorInfo = getErrorMessage(errorCode: error.code);
      return (null, localResultHandler.error);
    } catch (error) {
      localResultHandler.errorInfo = (MessageType.error, FirebaseErrorStrings.somethingWentWrong);
      return (null, localResultHandler.error);
    }
  }
}
