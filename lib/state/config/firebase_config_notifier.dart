import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tennisbookings/global_helpers/config.dart';
import 'package:tennisbookings/global_helpers/index.dart';

import '../../global_types/index.dart';
import '../../models/index.dart';
import '../index.dart';
import 'index.dart';

class FirebaseConfigNotifier extends StateNotifier<FirebaseConfig> {
  FirebaseConfigNotifier() : super(FirebaseConfig.empty());
  final configCollection = FirebaseFirestore.instance.collection(FirestoreCollection.config);

  void loadConfig() async {
    try {
      'Loading config'.tbLogger('CONFIG');
      if (state.loaded) return;
      'Config is not Empty'.tbLogger('CONFIG');
      final doc = await configCollection.doc(ConfigDocuments.main).get();
      if (doc.exists) {
        final data = doc.data() as FirestoreResponse;
        'Config loaded: ${data.toString()}'.tbLogger('CONFIG', DebugLevel.error);
        state = FirebaseConfig.fromJson(data);
      }
    } catch (e) {
      e.tbLogger('ERROR LOADING CONFIG', DebugLevel.error);
    }
  }

  bool requireUpdate({required EventStatusNotifier eventStatusNotifier}) {
    'Checking for app update'.tbLogger('CONFIG');
    return versionCheck(config: state, eventStatusNotifier: eventStatusNotifier);
  }
}
