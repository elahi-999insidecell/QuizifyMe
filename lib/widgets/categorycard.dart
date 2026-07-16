import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback click;

  const CategoryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.click
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      
      color: const Color.fromARGB(255, 202, 243, 239),
      child: ListTile(
        onTap: click,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Text(
          subtitle,
           maxLines: 1,
          overflow: TextOverflow.ellipsis,
          ),
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(icon, color: Colors.white),
        ),
        trailing: Icon(Icons.arrow_forward_ios_outlined, size: 10,),
      ),
    );
  }
}
