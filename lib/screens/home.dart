// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app_2/models/firebase_category_model.dart';
import 'package:quiz_app_2/models/studentmodel.dart';
import 'package:quiz_app_2/provider/quiz_provider.dart';
import 'package:quiz_app_2/provider/student_provider.dart';
import 'package:quiz_app_2/provider/subscription_provider.dart';
import 'package:quiz_app_2/provider/theme_provider.dart';
import 'package:quiz_app_2/widgets/category_grid_card.dart';
import 'package:quiz_app_2/widgets/leaderboard_tile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final quizProvider = context.read<QuizProvider>();
    final studentProvider = context.read<StudentSignUpProvider>();

   
      quizProvider.fetchCategories();
    

    
      studentProvider.fetchTopStudents();
    
  });
}

  Future<void> _handleCategoryTap(FirebaseCategoryModel category) async {
    if (!mounted) return;

    final studentProvider = context.read<StudentSignUpProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    // Ensure we have the current student loaded
    if (studentProvider.currentStudent == null) {
      await studentProvider.fetchCurrentUser();
    }

    if (!mounted) return;

    final student = studentProvider.currentStudent;
    final msisdn = student?.msisdn ?? '';

    if (msisdn.isEmpty) {
      // No mobile on record — send to subscription screen with category context
      context.push('/subscription', extra: category);
      return;
    }

    // Already subscribed locally
if (student?.isSubscribed == true) {
  context.push('/question', extra: category);
  return;
}

    // Show loading indicator while checking
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final isSubscribed = await subscriptionProvider.checkSubscription(msisdn);

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    if (isSubscribed) {

  await studentProvider.updateSubscriptionStatus(
    true,
    "REGISTERED",
    msisdn,
  );

  context.push('/question', extra: category);

} else {

  context.push('/subscription', extra: category);

}
  }

  //icons no more fixed
  IconData getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'english':
        return Icons.language;

      case 'bangla':
        return Icons.menu_book;

      case 'math':
      case 'mathematics':
        return Icons.calculate;

      case 'general knowledge':
        return Icons.public;

      case 'science':
        return Icons.science;

      case 'history':
        return Icons.history_edu;

      case 'geography':
        return Icons.public;

      case 'computer':
      case 'computer science':
        return Icons.computer;

      case 'programming':
        return Icons.code;

      default:
        return Icons.extension;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
  final isDark = themeProvider.isDark;
    return Scaffold(
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.teal,
  foregroundColor: Colors.white,
  title: const Row(
    children: [
      
      SizedBox(width: 10),
      Text(
        "QuizifyMe",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: .5,
        ),
      ),
    ],
  ),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 14),
      child: GestureDetector(
        onTap: () {
          context.push("/real-profile");
        },
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white24,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
),

      body: 
      
      Container(
        decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? const [
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ]
          : const [
              Color(0xffF8FFFE),
              Color(0xffEEF8F7),
            ],
    ),),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<StudentSignUpProvider>(
  builder: (context, provider, child) {

    final student = provider.currentStudent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff00897B),
            Color(0xff26A69A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Hello, ${student?.name ?? "Learner"}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Ready for today's challenge?\nChoose a category and earn more points.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 18),

              
              ],
            ),
          ),

          const SizedBox(width: 15),

          const Icon(
            Icons.emoji_events_rounded,
            color: Colors.amber,
            size: 72,
          ),
        ],
      ),
    );
  },
),
                  const SizedBox(height: 22),
                  Consumer<StudentSignUpProvider>(
  builder: (context, provider, child) {
    final student = provider.currentStudent;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            "Points",
            "${student?.score ?? 0}",
            Icons.workspace_premium_rounded,
            Colors.amber,
          ),
        ),

        const SizedBox(width: 15),

        Expanded(
          child: _buildStatCard(
            "Quizzes",
            "${student?.quizTaken ?? 0}",
            Icons.quiz_rounded,
            Colors.teal,
          ),
        ),
      ],
    );
  },
),

const SizedBox(height: 25),

const Row(
  children: [
    Icon(
      Icons.grid_view_rounded,
      color: Colors.teal,
    ),
    SizedBox(width: 8),
    Text(
      "Browse Categories",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

SizedBox(height: 18),
        
                  
                  Consumer<QuizProvider>(
                    builder: (context, quizProvider, child) {
                      ///adding
                      final categories = quizProvider.firebaseCategories;
                      //loading shotto hoy+ category null hoy, tahole ghurte thakbe
                      //1.error
                      if (quizProvider.isLoading && categories.isEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }
                      //2.error
                      if (quizProvider.errorMesg != null && categories.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                quizProvider.errorMesg!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red),
                              ),
                              SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () =>
                                    quizProvider.fetchCategories(),
                                child: Text("Retry"),
                              ),
                            ],
                          ),
                        );
                      }
        
                      //3. error empty state
        
                      if (categories.isEmpty) {
                        return Center(
                          child: Text(
                            "no categories found",
        
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }
        
                      //4. data state (using triviacategory from response model)
        
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final callTheDatabase = categories[index];
                          return CategoryGridCard(
                            
                            title: callTheDatabase.name,
                            subtitle:
                                "${callTheDatabase.questioncount} Questions",
                            icon: getCategoryIcon(callTheDatabase.name),
                            onTap: () {
                              _handleCategoryTap(callTheDatabase);
                            },
                          );
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.9,
                          mainAxisSpacing: 14,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
        
                  Consumer<StudentSignUpProvider>(
                    builder: (context, studentProvider, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
  children: [
    Icon(
      Icons.emoji_events_rounded,
      color: Colors.amber,
    ),
    SizedBox(width: 8),
    Text(
      "Top Performers",
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),
                        TextButton(onPressed: (){
                          context.push("/leaderboard");
                        
                        }, child: Text("See All", style: TextStyle(color: Colors.teal.shade600)))
                            ],
                          ), ..._buildTopStudentsList(studentProvider.topStudents),
                        ]);
                    },
                  ),
        
                  // expanded
                ],
              ),
            ),
          ),
        ),
      ),

      
    );
  }

  List<Widget> _buildTopStudentsList(List<StudentModel> students) {
    if (students.isEmpty) {
      return [
        const Text(
          'No leaderboard data yet.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ];
    }

    // Take only top 3 for home screen
    final topStudents = students.take(3).toList();

    return List.generate(topStudents.length, (index) {
      return LeaderboardTile(
        student: topStudents[index],
        rank: index + 1,
        isTopThree: true,
      );
    });
  }

// new widget
Widget _buildStatCard(
  String title,
  String value,
  IconData icon,
  Color iconColor,
) {
  return Container(
    padding: const EdgeInsets.symmetric(
      vertical: 18,
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      children: [

        Icon(
          icon,
          color: iconColor,
          size: 30,
        ),

        const SizedBox(height: 10),

        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
  title,
  style: TextStyle(
    color: Theme.of(context)
        .textTheme
        .bodyMedium
        ?.color
        ?.withValues(alpha: 0.7),
  ),
)
      ],
    ),
  );
}


}
