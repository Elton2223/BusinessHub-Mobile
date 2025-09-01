import 'package:flutter/material.dart';

class NeumorphicTheme {
  // Base colors for neumorphic design
  static const Color baseColor = Color(0xFFF0F0F0); // Light gray background
  static const Color lightShadow = Color(0xFFFFFFFF); // White shadow
  static const Color darkShadow = Color(0xFF989898); // Dark gray shadow
  
  // Neumorphic container decoration
  static BoxDecoration neumorphicContainer({
    double borderRadius = 52.0,
    double depth = 24.0,
    Color? baseColor,
    bool isPressed = false,
  }) {
    final color = baseColor ?? NeumorphicTheme.baseColor;
    
    if (isPressed) {
      return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: darkShadow,
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth * 2,
          ),
          BoxShadow(
            color: lightShadow,
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth * 2,
          ),
        ],
      );
    }
    
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: darkShadow,
          offset: Offset(depth, depth),
          blurRadius: depth * 2,
        ),
        BoxShadow(
          color: lightShadow,
          offset: Offset(-depth, -depth),
          blurRadius: depth * 2,
        ),
      ],
    );
  }
  
  // Neumorphic button decoration
  static BoxDecoration neumorphicButton({
    double borderRadius = 12.0,
    double depth = 6.0,
    Color? baseColor,
    bool isPressed = false,
  }) {
    return neumorphicContainer(
      borderRadius: borderRadius,
      depth: depth,
      baseColor: baseColor,
      isPressed: isPressed,
    );
  }
  
  // Neumorphic card decoration
  static BoxDecoration neumorphicCard({
    double borderRadius = 20.0,
    double depth = 10.0,
    Color? baseColor,
  }) {
    return neumorphicContainer(
      borderRadius: borderRadius,
      depth: depth,
      baseColor: baseColor,
    );
  }
  
  // Neumorphic input field decoration
  static InputDecoration neumorphicInput({
    String? hintText,
    IconData? prefixIcon,
    Color? baseColor,
    double borderRadius = 12.0,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      filled: true,
      fillColor: baseColor ?? NeumorphicTheme.baseColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: Colors.blue.withOpacity(0.3),
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
  
  // Neumorphic app bar decoration
  static BoxDecoration neumorphicAppBar({
    Color? baseColor,
    double depth = 5.0,
  }) {
    return BoxDecoration(
      color: baseColor ?? NeumorphicTheme.baseColor,
      boxShadow: [
        BoxShadow(
          color: darkShadow.withOpacity(0.2),
          offset: Offset(0, depth),
          blurRadius: depth,
        ),
      ],
    );
  }
  
  // Neumorphic drawer decoration
  static BoxDecoration neumorphicDrawer({
    Color? baseColor,
    double depth = 8.0,
  }) {
    return BoxDecoration(
      color: baseColor ?? NeumorphicTheme.baseColor,
      boxShadow: [
        BoxShadow(
          color: darkShadow.withOpacity(0.3),
          offset: Offset(depth, 0),
          blurRadius: depth,
        ),
      ],
    );
  }
  
  // Neumorphic floating action button decoration
  static BoxDecoration neumorphicFAB({
    double borderRadius = 50.0,
    double depth = 8.0,
    Color? baseColor,
    bool isPressed = false,
  }) {
    return neumorphicContainer(
      borderRadius: borderRadius,
      depth: depth,
      baseColor: baseColor,
      isPressed: isPressed,
    );
  }
  
  // Neumorphic list tile decoration
  static BoxDecoration neumorphicListTile({
    double borderRadius = 12.0,
    double depth = 4.0,
    Color? baseColor,
  }) {
    return neumorphicContainer(
      borderRadius: borderRadius,
      depth: depth,
      baseColor: baseColor,
    );
  }
  
  // Neumorphic bottom navigation decoration
  static BoxDecoration neumorphicBottomNav({
    Color? baseColor,
    double depth = 8.0,
  }) {
    return BoxDecoration(
      color: baseColor ?? NeumorphicTheme.baseColor,
      boxShadow: [
        BoxShadow(
          color: darkShadow.withOpacity(0.2),
          offset: Offset(0, -depth),
          blurRadius: depth,
        ),
      ],
    );
  }
  
  // Neumorphic switch decoration
  static BoxDecoration neumorphicSwitch({
    double borderRadius = 25.0,
    double depth = 4.0,
    Color? baseColor,
    bool isActive = false,
  }) {
    final color = isActive 
        ? (baseColor ?? Colors.blue) 
        : (baseColor ?? NeumorphicTheme.baseColor);
    
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: darkShadow.withOpacity(0.3),
          offset: Offset(depth / 2, depth / 2),
          blurRadius: depth,
        ),
        BoxShadow(
          color: lightShadow.withOpacity(0.8),
          offset: Offset(-depth / 2, -depth / 2),
          blurRadius: depth,
        ),
      ],
    );
  }
  
  // Neumorphic progress indicator decoration
  static BoxDecoration neumorphicProgress({
    double borderRadius = 10.0,
    double depth = 4.0,
    Color? baseColor,
  }) {
    return BoxDecoration(
      color: baseColor ?? NeumorphicTheme.baseColor,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: darkShadow.withOpacity(0.3),
          offset: Offset(depth / 2, depth / 2),
          blurRadius: depth,
        ),
        BoxShadow(
          color: lightShadow.withOpacity(0.8),
          offset: Offset(-depth / 2, -depth / 2),
          blurRadius: depth,
        ),
      ],
    );
  }
}

// Neumorphic widget extensions
extension NeumorphicWidget on Widget {
  Widget withNeumorphicContainer({
    double borderRadius = 15.0,
    double depth = 8.0,
    Color? baseColor,
    bool isPressed = false,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding,
      decoration: NeumorphicTheme.neumorphicContainer(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
        isPressed: isPressed,
      ),
      child: this,
    );
  }
  
  Widget withNeumorphicCard({
    double borderRadius = 20.0,
    double depth = 10.0,
    Color? baseColor,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      decoration: NeumorphicTheme.neumorphicCard(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
      ),
      child: this,
    );
  }
  
  Widget withNeumorphicButton({
    double borderRadius = 12.0,
    double depth = 6.0,
    Color? baseColor,
    bool isPressed = false,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: NeumorphicTheme.neumorphicButton(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
        isPressed: isPressed,
      ),
      child: this,
    );
  }
}
