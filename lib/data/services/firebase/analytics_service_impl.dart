import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:open_baby_sara/data/services/firebase/analytics_service.dart';

class AnalyticsServiceImpl extends AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> logActivitySaved(String babyID, String activityName) async {
    await _analytics.logEvent(
      name: 'activity_$activityName',
      parameters: {'babyID': babyID, 'activity_name': activityName},
    );
  }

  @override
  Future<void> logScreenView(String screenName) async {
    await _analytics.logEvent(
      name: 'screen_view_$screenName',
      parameters: {'firebase_screen': screenName, 'firebase_screen_class':screenName},
    );
  }

  @override
  Future<void> logSoundsView(String soundsName) async{
   await _analytics.logEvent(name: 'sound_played_$soundsName',parameters: {
     'sound_title':soundsName
   });
  }
}
