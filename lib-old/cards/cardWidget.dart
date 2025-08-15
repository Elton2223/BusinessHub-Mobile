import 'package:flutter/material.dart';

class Card2Widget extends StatelessWidget {
  final String text;
  final String text2;
  final Icon icon;
  final String text3;
  final Color color;
  final Icon icon2;
  final Color color01;
  final Future<void> Function() action;

  const Card2Widget({
    Key? key,
    required this.text,
    required this.text2,
    required this.icon,
    required this.text3,
    required this.color,
    required this.icon2,
    required this.color01,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => action(),
      child: Container(
        width: 170,
        height: 99,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon2,
                  const SizedBox(width: 8),
                  Text(text, style: const TextStyle(color: Colors.white)),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(text2, style: const TextStyle(color: Colors.white)),
                  icon,
                  Text(text3, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}