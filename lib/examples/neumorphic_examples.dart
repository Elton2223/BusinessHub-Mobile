import 'package:flutter/material.dart';
import '../widgets/neumorphic_widgets.dart';
import '../flutter_flow/neumorphic_theme.dart';

class NeumorphicExamples extends StatefulWidget {
  const NeumorphicExamples({Key? key}) : super(key: key);

  @override
  State<NeumorphicExamples> createState() => _NeumorphicExamplesState();
}

class _NeumorphicExamplesState extends State<NeumorphicExamples> {
  bool switchValue = false;
  double progressValue = 0.7;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor,
      appBar: NeumorphicAppBar(
        title: 'Neumorphic Examples',
        baseColor: NeumorphicTheme.baseColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Basic Neumorphic Container
            Text(
              '1. Basic Neumorphic Container',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicContainer(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'This is a neumorphic container with your custom styling',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            // Example 2: Neumorphic Card
            Text(
              '2. Neumorphic Card',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Title',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This is a neumorphic card with your custom styling. It has a larger border radius and deeper shadows.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Example 3: Neumorphic Button
            Text(
              '3. Neumorphic Button',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Button pressed!')),
                );
              },
              child: Text(
                'Press Me',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Example 4: Neumorphic Text Field
            Text(
              '4. Neumorphic Text Field',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicTextField(
              hintText: 'Enter your text here...',
              prefixIcon: Icons.edit,
            ),
            SizedBox(height: 30),

            // Example 5: Neumorphic Icon Button
            Text(
              '5. Neumorphic Icon Button',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                NeumorphicIconButton(
                  icon: Icons.favorite,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Heart pressed!')),
                    );
                  },
                ),
                SizedBox(width: 20),
                NeumorphicIconButton(
                  icon: Icons.share,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Share pressed!')),
                    );
                  },
                ),
                SizedBox(width: 20),
                NeumorphicIconButton(
                  icon: Icons.settings,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Settings pressed!')),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 30),

            // Example 6: Neumorphic Switch
            Text(
              '6. Neumorphic Switch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Toggle Switch: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                NeumorphicSwitch(
                  value: switchValue,
                  onChanged: (value) {
                    setState(() {
                      switchValue = value;
                    });
                  },
                ),
                SizedBox(width: 10),
                Text(
                  switchValue ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: switchValue ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Example 7: Neumorphic Progress Indicator
            Text(
              '7. Neumorphic Progress Indicator',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicProgressIndicator(
              value: progressValue,
              progressColor: Colors.blue,
            ),
            SizedBox(height: 10),
            Text(
              'Progress: ${(progressValue * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),

            // Example 8: Neumorphic List Tile
            Text(
              '8. Neumorphic List Tile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicListTile(
              leading: Icon(Icons.person, color: Colors.grey[600]),
              title: Text(
                'User Profile',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              subtitle: Text(
                'Tap to view profile details',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile tapped!')),
                );
              },
            ),
            SizedBox(height: 30),

            // Example 9: Neumorphic Badge
            Text(
              '9. Neumorphic Badge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                NeumorphicBadge(
                  label: '3',
                  child: NeumorphicIconButton(
                    icon: Icons.notifications,
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: 20),
                NeumorphicBadge(
                  label: 'NEW',
                  backgroundColor: Colors.green,
                  child: NeumorphicIconButton(
                    icon: Icons.mail,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Example 10: Neumorphic Divider
            Text(
              '10. Neumorphic Divider',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicDivider(
              height: 2,
              margin: EdgeInsets.symmetric(vertical: 10),
            ),
            SizedBox(height: 30),

            // Example 11: Custom Styling
            Text(
              '11. Custom Styling',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            NeumorphicContainer(
              borderRadius: 25.0,
              depth: 12.0,
              baseColor: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Custom styled container with different border radius and depth',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: NeumorphicFAB(
        child: Icon(Icons.add, color: Colors.grey[700]),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('FAB pressed!')),
          );
        },
      ),
    );
  }
}
