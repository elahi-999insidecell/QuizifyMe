class ApiEndpoints {
  //base url
  static const String baseUrl = "https://opentdb.com";

  //time out duration
  static const int receiveTimeout = 15000;
  static const int connectionTimout = 15000;

  // bdApps OTP API Endpoint
  static const String sendOtpUrl = 'https://bdappsdigitalapps.com/elahi3252/send_otp.php';
  static const String verifyOtpUrl = 'https://bdappsdigitalapps.com/elahi3252/verify_otp.php';
  static const String checkSubscriptionUrl = 'https://bdappsdigitalapps.com/elahi3252/check_subscription.php';
  static const String unsubscribeUrl = 'https://bdappsdigitalapps.com/elahi3252/unsubscribe.php';
}
