import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  final FirebaseRemoteConfig _remoteConfig;

  UpdateService(this._remoteConfig);

  Future<void> initialize() async {
    await _remoteConfig.setDefaults({
      'latest_version': '1.0.0',
      'update_url_android': '',
      'update_url_ios': '',
    });
    await _remoteConfig.fetchAndActivate();
  }

  String get latestVersion => _remoteConfig.getString('latest_version');

  String get updateUrl => Platform.isAndroid
      ? _remoteConfig.getString('update_url_android')
      : _remoteConfig.getString('update_url_ios');

  Future<String> getCurrentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  bool isUpdateAvailable(String latest, String current) {
    final latestParts = latest.split('.').map(int.parse).toList();
    final currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}
