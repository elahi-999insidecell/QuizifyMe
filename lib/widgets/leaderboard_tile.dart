import 'package:flutter/material.dart';
import 'package:quiz_app_2/models/studentmodel.dart';

class LeaderboardTile extends StatelessWidget {
  final StudentModel student;
  final int rank;
  final bool isTopThree;

  const LeaderboardTile({
    super.key,
    required this.student,
    required this.rank,
    this.isTopThree = false,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color avatarColor;
    Color rankTextColor;

    if (rank == 1) {
      borderColor = Colors.amber;
      avatarColor = Colors.amber.shade200;
      rankTextColor = Colors.black87;
    } else if (rank == 2) {
      borderColor = Colors.blueGrey.shade200;
      avatarColor = Colors.blueGrey.shade100;
      rankTextColor = Colors.black87;
    } else if (rank == 3) {
      borderColor = Colors.brown.shade300;
      avatarColor = Colors.brown.shade300;
      rankTextColor = Colors.white;
    } else {
      borderColor = Colors.teal.shade100;
      avatarColor = Colors.teal.shade50;
      rankTextColor = Colors.teal.shade700;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: avatarColor,
            child: Text(
              "$rank",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rankTextColor,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              student.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            "${student.score} pts",
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}