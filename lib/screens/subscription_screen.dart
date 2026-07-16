import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/firebase_category_model.dart';
import '../provider/student_provider.dart';
import '../provider/subscription_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  /// The category the user originally wanted to quiz in.
  /// If provided, successful subscription / already-subscribed
  /// will route directly to the question screen for this category.
  final FirebaseCategoryModel? pendingCategory;

  const SubscriptionScreen({super.key, this.pendingCategory});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // Converts a Bangladeshi local phone number (e.g. 01712345678)
  // into the international MSISDN format required by bdApps APIs (8801712345678).
  String _toMsisdn(String phone) {
    var p = phone.replaceAll(RegExp(r'\s+|-'), '');
    if (p.startsWith('+')) p = p.substring(1);
    if (p.startsWith('880')) return p;
    if (p.startsWith('0')) p = p.substring(1);
    if (p.length == 10 && p.startsWith('1')) return '880$p';
    return '';
  }

  void _handleSubscribe(String preloadedMsisdn) async {
    final subProvider = context.read<SubscriptionProvider>();
    String msisdn = preloadedMsisdn;

    if (msisdn.isEmpty) {
      if (!_formKey.currentState!.validate()) return;
      msisdn = _toMsisdn(_phoneController.text.trim());
    }

    if (msisdn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid Bangladeshi phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await subProvider.sendOtp(msisdn);
    if (mounted) {
      if (success) {
        if (subProvider.isAlreadySubscribed) {
          // Sync with Firestore & StudentSignUpProvider
          await context.read<StudentSignUpProvider>().updateSubscriptionStatus(true, 'REGISTERED', msisdn);

          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Already Subscribed!'),
                  ],
                ),
                content: const Text(
                  'You are already subscribed to QuizifyMe Premium. Enjoy all premium benefits!',
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      final category = widget.pendingCategory;
                      if (category != null) {
                        context.go('/question', extra: category);
                      } else {
                        context.go('/home');
                      }
                    },
                    child: const Text('Start Quiz! 🎉'),
                  ),
                ],
              ),
            );
          }
        } else {
          // New user — show OTP entry inline
          _showOtpDialog(msisdn, subProvider);
        }
      } else {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Subscription Failed'),
              ],
            ),
            content: Text(subProvider.errorMessage ?? "Could not send OTP. Please try again."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showOtpDialog(String msisdn, SubscriptionProvider subProvider) {
    final otpControllers = List.generate(6, (_) => TextEditingController());
    final otpFocusNodes = List.generate(6, (_) => FocusNode());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("OTP sent! Please check your SMS."),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Column(
                children: [
                  Icon(Icons.security, size: 48, color: Colors.teal),
                  SizedBox(height: 8),
                  Text(
                    'Enter OTP',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'We sent a 6-digit code to\n$msisdn',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 40,
                        height: 48,
                        child: TextFormField(
                          controller: otpControllers[index],
                          focusNode: otpFocusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.teal, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              otpFocusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              otpFocusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    for (var c in otpControllers) {
                      c.dispose();
                    }
                    for (var f in otpFocusNodes) {
                      f.dispose();
                    }
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final code = otpControllers.map((c) => c.text).join();
                    if (code.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter all 6 digits"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final referenceNo = subProvider.referenceNo;
                    if (referenceNo == null || referenceNo.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Reference ID missing. Please try again."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Close OTP dialog
                    Navigator.pop(dialogContext);
                    for (var c in otpControllers) {
                      c.dispose();
                    }
                    for (var f in otpFocusNodes) {
                      f.dispose();
                    }

                    // Verify OTP
                    final verified = await subProvider.verifyOtp(code, referenceNo);

                    if (mounted) {
                      if (verified) {
                        await context
                            .read<StudentSignUpProvider>()
                            .updateSubscriptionStatus(true, 'SUBSCRIBED', msisdn);

                        if (mounted) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                                  SizedBox(width: 8),
                                  Text('Successfully Subscribed!'),
                                ],
                              ),
                              content: const Text(
                                'Welcome to QuizifyMe Premium! You now have full access to all features.',
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    final category = widget.pendingCategory;
                                    if (category != null) {
                                      context.go('/question', extra: category);
                                    } else {
                                      context.go('/home');
                                    }
                                  },
                                  child: const Text('Start Quizzing! 🎉'),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: const Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Verification Failed'),
                              ],
                            ),
                            content: Text(
                              subProvider.errorMessage ?? 'Invalid OTP. Please try again.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showOtpDialog(msisdn, subProvider);
                                },
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentSignUpProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final student = studentProvider.currentStudent;
    final String existingMsisdn = student?.msisdn ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Subscribe', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Header Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.yellow, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'QUIZIFYME PREMIUM',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title & Description
                    const Center(
                      child: Text(
                        'Unlock Your Full Potential',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Get access to premium question sets, interactive leaderboard metrics, and complete solutions.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Pricing Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.greenAccent, Color.fromARGB(255, 56, 142, 118)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Daily Package',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'BDT 2.00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '/day',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+ VAT, SD & SC • Auto-renewable',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Benefits section
                    const Text(
                      'What is included:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitRow(Icons.check_circle_outline, 'Unlimited access to all categories'),
                    _buildBenefitRow(Icons.leaderboard_outlined, 'Compete in the leaderboard'),
                    _buildBenefitRow(Icons.help_outline, 'Detailed answer explanation & learning stats'),
                    _buildBenefitRow(Icons.block_outlined, 'Completely ad-free premium environment'),
                    
                    const SizedBox(height: 32),

                    // MSISDN Input or Confirmation
                    if (existingMsisdn.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone_android, color: Colors.greenAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Subscribing with Number',
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    existingMsisdn,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      const Text(
                        'Enter Phone Number to Subscribe',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number (e.g. 01XXXXXXXXX)',
                          hintText: '018XXXXXXXX',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLength: 11,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          final cleaned = value.replaceAll(RegExp(r'\s+|-'), '');
                          if (cleaned.length < 10) {
                            return 'Enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Subscribe Button
                    SizedBox(
  width: double.infinity,
  height: 58,
  child: ElevatedButton(
    onPressed: () => _handleSubscribe(existingMsisdn),
    style: ElevatedButton.styleFrom(
      elevation: 10,
      shadowColor: Colors.teal.withValues(alpha:0.45),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.workspace_premium_rounded,
          size: 26,
          color: Colors.amber,
        ),
        SizedBox(width: 12),
        Text(
          "Subscribe Now",
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
        SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_rounded,
          size: 24,
        ),
      ],
    ),
  ),
)
                    , const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading Overlay
          if (subProvider.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Sending Request...',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.greenAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
