import 'dart:html' as html;

class WebNotificationHelper {
  Future<bool> requestPermission() async {
    if (!html.Notification.supported) {
      return false;
    }

    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  Future<bool> showNotification({
    required String title,
    required String body,
  }) async {
    if (!html.Notification.supported) {
      return false;
    }

    final permission = html.Notification.permission;
    if (permission != 'granted') {
      final granted = await requestPermission();
      if (!granted) {
        return false;
      }
    }

    html.Notification(
      title,
      body: body,
      icon: 'icons/Icon-192.png',
    );
    return true;
  }
}
