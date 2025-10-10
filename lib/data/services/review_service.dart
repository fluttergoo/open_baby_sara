import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();

  factory ReviewService() {
    return _instance;
  }

  ReviewService._internal();

  static const String _recordCountKey = 'recordCount';
  static const String _lastReviewRequestTimestampKey =
      'lastReviewRequestTimestamp';
  static const List<int> _reviewThresholds = [
    1,
    10,
    25,
    50,
    100,
    200,
    300,
    500,
  ];
  static const int _minTimeBetweenReviewsMs = 30 * 24 * 60 * 60 * 1000;

  Future<void> checkIfShouldRequestReview() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final InAppReview inAppReview = InAppReview.instance;

    int recordCount = prefs.getInt(_recordCountKey) ?? 0;
    int lastReviewRequestTimestamp =
        prefs.getInt(_lastReviewRequestTimestampKey) ?? 0;

    if (!await inAppReview.isAvailable()) {
      return;
    }

    bool isAtThreshold = _reviewThresholds.contains(recordCount);

    bool enoughTimePassed =
        (DateTime.now().millisecondsSinceEpoch - lastReviewRequestTimestamp) >
        _minTimeBetweenReviewsMs;

    if (isAtThreshold && enoughTimePassed) {
      print('ReviewService: Requesting review at record count $recordCount.');
      inAppReview.requestReview();
      await prefs.setInt(
        _lastReviewRequestTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<void> incrementRecordCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int recordCount = prefs.getInt(_recordCountKey) ?? 0;
    recordCount++;
    await prefs.setInt(_recordCountKey, recordCount);

    await checkIfShouldRequestReview();
  }

  Future<int> getCurrentRecordCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_recordCountKey) ?? 0;
  }

  Future<void> resetRecordCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_recordCountKey, 0);
    await prefs.setInt(_lastReviewRequestTimestampKey, 0);
  }
}
