import 'package:flutter/material.dart';
import 'package:quiz_app_2/models/studentmodel.dart';

class TopRankCard extends StatelessWidget {
  final StudentModel student;
  final int rank;

  const TopRankCard({super.key, required this.student, required this.rank});

  @override
  Widget build(BuildContext context) {
    late List<Color> colors;
    late IconData medalIcon;
    late Color medalColor;

    switch (rank) {
      case 1:
        colors = [const Color(0xffFFD54F), const Color(0xffFFB300)];
        medalIcon = Icons.workspace_premium_rounded;
        medalColor = Colors.amber.shade900;
        break;

      case 2:
        colors = [const Color(0xffECEFF1), const Color(0xffB0BEC5)];
        medalIcon = Icons.military_tech_rounded;
        medalColor = Colors.blueGrey.shade700;
        break;

      default:
        colors = [const Color(0xffFFCCBC), const Color(0xffF57C00)];
        medalIcon = Icons.workspace_premium_rounded;
        medalColor = Colors.brown.shade700;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              "#$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: medalColor,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(medalIcon, color: medalColor, size: 30),

                const SizedBox(height: 6),

                Text(
                  student.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  rank == 1
                      ? "Champion"
                      : rank == 2
                      ? "Runner-up"
                      : "Third Place",
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                const Icon(Icons.star_rounded, color: Colors.teal, size: 22),

                const SizedBox(height: 4),

                Text(
                  "${student.score}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.teal,
                  ),
                ),

                const Text(
                  "pts",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
