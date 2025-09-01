import 'package:flutter/material.dart';
import '../../widgets/neumorphic_widgets.dart';

class Card2Component extends StatelessWidget {
  const Card2Component({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card 2 Component',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This is a neumorphic card component with your custom styling.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
