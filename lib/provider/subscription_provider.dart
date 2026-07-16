import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../api/api_endpoints.dart';
import '../api/api_services.dart';

class SubscriptionProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOtpSent = false;
  String? _referenceNo;
  bool _isAlreadySubscribed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  String? get referenceNo => _referenceNo;
  bool get isAlreadySubscribed => _isAlreadySubscribed;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Sends the subscription OTP request to the backend send_otp.php API.
  Future<bool> sendOtp(String msisdn) async {
    _setLoading(true);
    _errorMessage = null;
    _isOtpSent = false;
    _referenceNo = null;
    _isAlreadySubscribed = false;
    notifyListeners();

    final requestData = {
      'user_mobile': msisdn,
    };
    debugPrint("==================== OTP REQUEST ====================");
    debugPrint("URL         : ${ApiEndpoints.sendOtpUrl}");
    debugPrint("Request Body: $requestData");
    debugPrint("====================================================");

    try {
      final response = await _apiService.post(
        ApiEndpoints.sendOtpUrl,
        data: requestData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      debugPrint("==================== OTP RESPONSE ====================");
      debugPrint("Status Code  : ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("=====================================================");

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map) {
          final isAlreadySubscribed = responseData['alreadySubscribed'] == true || 
                                      responseData['statusCode'] == 'E1351' ||
                                      responseData['statusDetail']?.toString().toLowerCase().contains('user already registered') == true ||
                                      responseData['message']?.toString().toLowerCase().contains('user already registered') == true;
          if (isAlreadySubscribed) {
            _isAlreadySubscribed = true;
            _setLoading(false);
            return true;
          }

          final isSuccess = responseData['success'] == true;
          
          if (isSuccess) {
            _isOtpSent = true;
            _referenceNo = responseData['referenceNo']?.toString();
            _setLoading(false);
            return true;
          } else {
            _errorMessage = responseData['message'] ?? 'Failed to send OTP. Please check the number.';
            _setLoading(false);
            return false;
          }
        } else {
          _errorMessage = 'Invalid response format from server.';
          _setLoading(false);
          return false;
        }
      } else {
        _errorMessage = 'Server returned error status code: ${response.statusCode}';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      String msg = 'Failed to send OTP due to network error.';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          msg = data['message'] ?? msg;
        } else {
          msg = data.toString();
        }
      } else {
        msg = e.message ?? msg;
      }
      _errorMessage = msg;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Verifies the OTP with the backend verify_otp.php API.
  Future<bool> verifyOtp(String otp, String referenceNo) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    final requestData = {
      'Otp': otp,
      'referenceNo': referenceNo,
    };
    debugPrint("==================== VERIFY OTP REQUEST ====================");
    debugPrint("URL         : ${ApiEndpoints.verifyOtpUrl}");
    debugPrint("Request Body: $requestData");
    debugPrint("========================================================");

    try {
      final response = await _apiService.post(
        ApiEndpoints.verifyOtpUrl,
        data: requestData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      debugPrint("==================== VERIFY OTP RESPONSE ====================");
      debugPrint("Status Code  : ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("=========================================================");

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map) {
          final statusCode = responseData['statusCode']?.toString();
          
          if (statusCode == 'S1000') {
            _setLoading(false);
            return true;
          } else {
            _errorMessage = responseData['statusDetail'] ?? responseData['message'] ?? 'OTP verification failed.';
            _setLoading(false);
            return false;
          }
        } else {
          _errorMessage = 'Invalid response format from server.';
          _setLoading(false);
          return false;
        }
      } else {
        _errorMessage = 'Server returned error status code: ${response.statusCode}';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      String msg = 'Failed to verify OTP due to network error.';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          msg = data['message'] ?? msg;
        } else if (data is Map && data.containsKey('statusDetail')) {
          msg = data['statusDetail'] ?? msg;
        } else {
          msg = data.toString();
        }
      } else {
        msg = e.message ?? msg;
      }
      _errorMessage = msg;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Checks subscription status from bdApps getStatus API via check_subscription.php.
  Future<bool> checkSubscription(String mobile) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    final requestData = {
      'user_mobile': mobile,
    };
    debugPrint("==================== CHECK SUBSCRIPTION REQUEST ====================");
    debugPrint("URL         : ${ApiEndpoints.checkSubscriptionUrl}");
    debugPrint("Request Body: $requestData");
    debugPrint("=============================================================");

    try {
      final response = await _apiService.post(
        ApiEndpoints.checkSubscriptionUrl,
        data: requestData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      debugPrint("==================== CHECK SUBSCRIPTION RESPONSE ====================");
      debugPrint("Status Code  : ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("==============================================================");

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map) {
          if (responseData.containsKey('error')) {
            _errorMessage = responseData['error']?.toString() ?? 'Failed to check subscription status';
            _setLoading(false);
            return false;
          }

          final bool isSubscribed = responseData['isSubscribed'] == true;
          _setLoading(false);
          return isSubscribed;
        } else {
          _errorMessage = 'Invalid response format from server.';
          _setLoading(false);
          return false;
        }
      } else {
        _errorMessage = 'Server returned error status code: ${response.statusCode}';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      String msg = 'Failed to check subscription due to network error.';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          msg = data['error'] ?? msg;
        } else {
          msg = data.toString();
        }
      } else {
        msg = e.message ?? msg;
      }
      _errorMessage = msg;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }

  /// Sends the unsubscription request to the backend unsubscribe.php API.
  Future<bool> unsubscribe(String mobile) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    final requestData = {
      'user_mobile': mobile,
    };
    debugPrint("==================== UNSUBSCRIBE REQUEST ====================");
    debugPrint("URL         : ${ApiEndpoints.unsubscribeUrl}");
    debugPrint("Request Body: $requestData");
    debugPrint("=========================================================");

    try {
      final response = await _apiService.post(
        ApiEndpoints.unsubscribeUrl,
        data: requestData,
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      debugPrint("==================== UNSUBSCRIBE RESPONSE ====================");
      debugPrint("Status Code  : ${response.statusCode}");
      debugPrint("Response Body: ${response.data}");
      debugPrint("==========================================================");

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map) {
          final isSuccess = responseData['success'] == true || 
                            responseData['statusCode'] == 'E1951' || 
                            responseData['subscriptionStatus'] == 'UNREGISTERED';
          if (isSuccess) {
            _setLoading(false);
            return true;
          } else {
            _errorMessage = responseData['error'] ?? responseData['statusDetail'] ?? 'Unsubscription failed.';
            _setLoading(false);
            return false;
          }
        } else {
          _errorMessage = 'Invalid response format from server.';
          _setLoading(false);
          return false;
        }
      } else {
        _errorMessage = 'Server returned error status code: ${response.statusCode}';
        _setLoading(false);
        return false;
      }
    } on DioException catch (e) {
      String msg = 'Failed to unsubscribe due to network error.';
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          msg = data['error'] ?? msg;
        } else {
          msg = data.toString();
        }
      } else {
        msg = e.message ?? msg;
      }
      _errorMessage = msg;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _setLoading(false);
      return false;
    }
  }
}
