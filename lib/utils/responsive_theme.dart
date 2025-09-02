import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class ResponsiveTheme {
  static ResponsiveTheme? _instance;
  static ResponsiveTheme get instance => _instance ??= ResponsiveTheme._internal();
  
  ResponsiveTheme._internal();

  // Responsive text styles
  TextStyle getResponsiveTextStyle({
    required double baseSize,
    FontWeight? weight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: baseSize,
      fontWeight: weight ?? FontWeight.normal,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  // Responsive headline styles
  TextStyle getResponsiveHeadline({
    required ResponsiveUtils responsive,
    FontWeight? weight,
    Color? color,
    double? height,
  }) {
    return getResponsiveTextStyle(
      baseSize: responsive.headlineFontSize,
      weight: weight ?? FontWeight.bold,
      color: color,
      height: height,
    );
  }

  // Responsive title styles
  TextStyle getResponsiveTitle({
    required ResponsiveUtils responsive,
    FontWeight? weight,
    Color? color,
    double? height,
  }) {
    return getResponsiveTextStyle(
      baseSize: responsive.titleFontSize,
      weight: weight ?? FontWeight.w600,
      color: color,
      height: height,
    );
  }

  // Responsive body styles
  TextStyle getResponsiveBody({
    required ResponsiveUtils responsive,
    FontWeight? weight,
    Color? color,
    double? height,
  }) {
    return getResponsiveTextStyle(
      baseSize: responsive.bodyFontSize,
      weight: weight ?? FontWeight.normal,
      color: color,
      height: height,
    );
  }

  // Responsive small text styles
  TextStyle getResponsiveSmall({
    required ResponsiveUtils responsive,
    FontWeight? weight,
    Color? color,
    double? height,
  }) {
    return getResponsiveTextStyle(
      baseSize: responsive.smallFontSize,
      weight: weight ?? FontWeight.normal,
      color: color,
      height: height,
    );
  }

  // Responsive button styles
  ButtonStyle getResponsiveButtonStyle({
    required ResponsiveUtils responsive,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation ?? 2.0,
      padding: padding ?? responsive.getResponsivePadding(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? responsive.mediumBorderRadius,
        ),
      ),
    );
  }

  // Responsive card decoration
  BoxDecoration getResponsiveCardDecoration({
    required ResponsiveUtils responsive,
    Color? color,
    double? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(
        borderRadius ?? responsive.mediumBorderRadius,
      ),
      border: border,
      boxShadow: boxShadow ?? [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Responsive input decoration
  InputDecoration getResponsiveInputDecoration({
    required ResponsiveUtils responsive,
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Color? borderColor,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding ?? responsive.getResponsivePadding(),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? responsive.smallBorderRadius,
        ),
        borderSide: BorderSide(
          color: borderColor ?? Colors.grey.shade400,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? responsive.smallBorderRadius,
        ),
        borderSide: BorderSide(
          color: borderColor ?? Colors.grey.shade400,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? responsive.smallBorderRadius,
        ),
        borderSide: BorderSide(
          color: borderColor ?? Colors.blue,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? responsive.smallBorderRadius,
        ),
        borderSide: BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
      ),
    );
  }

  // Responsive container decoration
  BoxDecoration getResponsiveContainerDecoration({
    required ResponsiveUtils responsive,
    Color? color,
    double? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius != null
          ? BorderRadius.circular(borderRadius)
          : BorderRadius.circular(responsive.smallBorderRadius),
      border: border,
      boxShadow: boxShadow,
      gradient: gradient,
    );
  }

  // Responsive spacing
  EdgeInsets getResponsiveSpacing({
    required ResponsiveUtils responsive,
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(responsive.getResponsiveSpacing(all));
    }
    
    return EdgeInsets.fromLTRB(
      left != null ? responsive.getResponsiveSpacing(left) : 0,
      top != null ? responsive.getResponsiveSpacing(top) : 0,
      right != null ? responsive.getResponsiveSpacing(right) : 0,
      bottom != null ? responsive.getResponsiveSpacing(bottom) : 0,
    );
  }

  // Responsive margins
  EdgeInsets getResponsiveMargins({
    required ResponsiveUtils responsive,
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(responsive.getResponsiveSpacing(all));
    }
    
    return EdgeInsets.fromLTRB(
      left != null ? responsive.getResponsiveSpacing(left) : 0,
      top != null ? responsive.getResponsiveSpacing(top) : 0,
      right != null ? responsive.getResponsiveSpacing(right) : 0,
      bottom != null ? responsive.getResponsiveSpacing(bottom) : 0,
    );
  }

  // Enhanced responsive theme features
  TextStyle getResponsiveButtonText({
    required ResponsiveUtils responsive,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      color: color ?? Colors.white,
      fontSize: fontSize ?? responsive.bodyFontSize,
      fontWeight: fontWeight ?? FontWeight.w600,
    );
  }

  TextStyle getResponsiveLabelText({
    required ResponsiveUtils responsive,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      color: color ?? Colors.grey[700],
      fontSize: fontSize ?? responsive.smallFontSize,
      fontWeight: fontWeight ?? FontWeight.w500,
    );
  }

  TextStyle getResponsiveHintText({
    required ResponsiveUtils responsive,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      color: color ?? Colors.grey[500],
      fontSize: fontSize ?? responsive.smallFontSize,
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }

  // Responsive card theme
  CardTheme getResponsiveCardTheme({
    required ResponsiveUtils responsive,
    Color? color,
    double? elevation,
    double? margin,
    double? borderRadius,
  }) {
    return CardTheme(
      color: color ?? Colors.white,
      elevation: elevation ?? (responsive.isTablet ? 4.0 : 2.0),
      margin: EdgeInsets.all(margin ?? responsive.cardMargin),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          borderRadius ?? responsive.mediumBorderRadius,
        ),
      ),
    );
  }

  // Responsive app bar theme
  AppBarTheme getResponsiveAppBarTheme({
    required ResponsiveUtils responsive,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    double? titleSpacing,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor ?? Colors.blue[600],
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? (responsive.isTablet ? 8.0 : 4.0),
      titleSpacing: titleSpacing ?? (responsive.isTablet ? 24.0 : 16.0),
      centerTitle: responsive.isTablet,
    );
  }
}

// Extension for easy access
extension ResponsiveThemeExtension on BuildContext {
  ResponsiveTheme get responsiveTheme => ResponsiveTheme.instance;
}
