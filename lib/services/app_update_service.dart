import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_aig_admins_app/view/widgets/app_update_dialog.dart';

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  bool _hasCheckedInSession = false;

  /// Checks for update in background and shows dialog if update is available
  Future<void> checkForUpdate(BuildContext context, {bool forceCheck = false}) async {
    if (_hasCheckedInSession && !forceCheck) return;
    _hasCheckedInSession = true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version; // e.g. "2.0.15"
      final String packageName = packageInfo.packageName; // e.g. "com.smartaig.admins.app"

      String storeVersion = "";
      String updateUrl = "";

      // 1. Try NewVersionPlus
      try {
        final newVersion = NewVersionPlus(
          androidId: packageName,
          iOSId: packageName,
        );

        final status = await newVersion.getVersionStatus();
        if (status != null && status.storeVersion.isNotEmpty) {
          storeVersion = status.storeVersion;
          updateUrl = status.appStoreLink;
        }
      } catch (e) {
        debugPrint("NewVersionPlus check error: $e");
      }

      // 2. Fallback for iOS using iTunes API if storeVersion is empty
      if (Platform.isIOS && (storeVersion.isEmpty || updateUrl.isEmpty)) {
        try {
          final response = await http.get(
            Uri.parse('https://itunes.apple.com/lookup?bundleId=$packageName'),
          ).timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['resultCount'] != null && data['resultCount'] > 0) {
              final result = data['results'][0];
              storeVersion = result['version'] ?? "";
              updateUrl = result['trackViewUrl'] ?? "";
            }
          }
        } catch (e) {
          debugPrint("iTunes lookup error: $e");
        }
      }

      // Default fallback update URLs if missing
      if (updateUrl.isEmpty) {
        if (Platform.isAndroid) {
          updateUrl = "https://play.google.com/store/apps/details?id=$packageName";
        } else if (Platform.isIOS) {
          updateUrl = "https://apps.apple.com/app/id$packageName";
        }
      }

      // Check if store version is higher than current local version
      if (storeVersion.isNotEmpty && _isVersionHigher(currentVersion, storeVersion)) {
        if (context.mounted) {
          AppUpdateDialog.show(
            context,
            currentVersion: currentVersion,
            storeVersion: storeVersion,
            updateUrl: updateUrl,
          );
        }
      }
    } catch (e) {
      debugPrint("AppUpdateService error: $e");
    }
  }

  /// Compare semantic version strings e.g. "2.0.15" vs "2.0.16"
  bool _isVersionHigher(String currentVersion, String storeVersion) {
    try {
      final cleanCurrent = currentVersion.split('+')[0].trim();
      final cleanStore = storeVersion.split('+')[0].trim();

      final List<int> currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final List<int> storeParts = cleanStore.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLength = currentParts.length > storeParts.length ? currentParts.length : storeParts.length;

      for (int i = 0; i < maxLength; i++) {
        final currentPart = i < currentParts.length ? currentParts[i] : 0;
        final storePart = i < storeParts.length ? storeParts[i] : 0;

        if (storePart > currentPart) {
          return true;
        } else if (storePart < currentPart) {
          return false;
        }
      }
    } catch (e) {
      debugPrint("Version compare error: $e");
    }
    return false;
  }

  /// Launch App Store / Play Store URL
  static Future<void> launchStore(String urlString) async {
    try {
      if (urlString.isNotEmpty) {
        final Uri url = Uri.parse(urlString);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // Fallback redirect
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final packageName = packageInfo.packageName;

      if (Platform.isAndroid) {
        final marketUri = Uri.parse("market://details?id=$packageName");
        if (await canLaunchUrl(marketUri)) {
          await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        } else {
          final webUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } else if (Platform.isIOS) {
        final iosUri = Uri.parse("https://apps.apple.com/app/id$packageName");
        await launchUrl(iosUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Launch store error: $e");
    }
  }
}
