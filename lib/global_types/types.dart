import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'enums.dart';

typedef ErrorInfo = (MessageType, String);

typedef Success = bool;

typedef ErrorCode = String;

typedef SignUpResult = (fb_auth.User?, ErrorInfo?);

typedef AiResponse = (String?, ErrorInfo?);

typedef FirestoreActionResult<T> = Future<(T, ErrorInfo?)>;

typedef StartAndEndOfWeek = (DateTime, DateTime);

// ^ ==================================== CLOUD FUNCTIONS ====================================
typedef FirestoreResponse = Map<String, dynamic>;
typedef FirestorePayload = FirestoreResponse;

// ^ ==================================== GENERAL ====================================
class Tuple<T1, T2> {
  final T1 item1;
  final T2? item2;

  const Tuple(this.item1, this.item2);

  @override
  String toString() {
    return 'Tuple{item1: $item1, item2: $item2}';
  }

  // getters
  T1 get first => item1;

  T2? get second => item2;
}

class SupportedLocales {
  static const en = 'en';
  static const es = 'es';
  static const pt = 'pt';
  static const fr = 'fr';
  static const de = 'de';
  static const it = 'it';

  static const all = [en, es, pt, fr, de, it];

  static const defaultLocale = en;

  SupportedLocales._();
}
