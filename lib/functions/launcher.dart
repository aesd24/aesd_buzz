import 'package:url_launcher/url_launcher.dart';

void uriLauncher(Uri uri) {
  launchUrl(uri, mode: LaunchMode.inAppBrowserView);
}