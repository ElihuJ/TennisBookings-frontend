import '../config/config.dart';
import '../state/config/index.dart';
import '../state/index.dart';

/// Determines whether the app requires an update.
///
/// This function evaluates the current app version against the latest available version
/// and returns a boolean indicating if an update is necessary.
///
/// Returns:
/// - `true` if the app requires an update.
/// - `false` if the app is up-to-date.
bool versionCheck({
  required FirebaseConfig config,
  required EventNotifier eventStatusNotifier,
}) {
  bool requireUpdate = false;
  final configMajorVersion = config.majorVersion;
  final configMinorVersion = config.minorVersion;
  final configPatchVersion = config.patchVersion;
  final localMajorVersion = Config.majorVersion;
  final localMinorVersion = Config.minorVersion;
  final localPatchVersion = Config.patchVersion;

  if (configMajorVersion == null || configMinorVersion == null || configPatchVersion == null) return requireUpdate;
  bool isMajorVersionHigher = configMajorVersion > localMajorVersion;
  bool isMinorVersionHigher = configMajorVersion == localMajorVersion && configMinorVersion > localMinorVersion;
  bool isPatchVersionHigher =
      configMajorVersion == localMajorVersion && configMinorVersion == localMinorVersion && configPatchVersion > localPatchVersion;
  if (isMajorVersionHigher || isMinorVersionHigher || isPatchVersionHigher) requireUpdate = true;
  return requireUpdate;
}
