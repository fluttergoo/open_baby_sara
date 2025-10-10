import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_baby_sara/data/repositories/locator.dart';
import 'package:open_baby_sara/data/services/firebase/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> checkAppUpdate(BuildContext context) async {
  final updateService = getIt<UpdateService>();

  final latest = updateService.latestVersion;
  final current = await updateService.getCurrentVersion();

  final shouldUpdate = updateService.isUpdateAvailable(latest, current);

  if (shouldUpdate) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ), // Softer corners
            title: Row(
              children: [
                Icon(
                  Icons.system_update_alt,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ), // Engaging icon
                const SizedBox(width: 10),
                Text(
                  context.tr('new_update_available'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min, // Prevents content from taking full height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('good_news_a_newer'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 15),
                Text(
                  context.tr(
                    'whats_new:',
                  ), // Engaging section for potential release notes
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  context.tr('performance_improvements'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 15),
                Text(
                  '${context.tr('current_version:')} + $current',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  '${context.tr('latest_version:')}: $latest',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final url = updateService.updateUrl;
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                    debugPrint(url);
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor:
                      Theme.of(
                        context,
                      ).primaryColor, // Primary color for action button
                ),
                child: Text(
                  context.tr('update_now'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    () =>
                        Navigator.of(
                          ctx,
                        ).pop(), // Allows users to dismiss if not critical
                child: Text(
                  context.tr('maybe_later'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
