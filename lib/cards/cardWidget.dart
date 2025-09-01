import 'package:flutter/material.dart';
import '../widgets/neumorphic_widgets.dart';

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
    return NeumorphicContainer(
      borderRadius: 20.0,
      depth: 10.0,
      baseColor: color,
      onTap: () => action(),
      child: Container(
        width: 170,
        height: 99,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  icon2,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    text2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  icon,
                  Text(
                    text3,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
