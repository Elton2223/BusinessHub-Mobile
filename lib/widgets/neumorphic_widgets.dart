import 'package:flutter/material.dart';
import '../flutter_flow/neumorphic_theme.dart';

// Neumorphic Container Widget
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final bool isPressed;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 15.0,
    this.depth = 8.0,
    this.baseColor,
    this.isPressed = false,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: padding,
      margin: margin,
      decoration: NeumorphicTheme.neumorphicContainer(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
        isPressed: isPressed,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

// Neumorphic Card Widget
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const NeumorphicCard({
    Key? key,
    required this.child,
    this.borderRadius = 20.0,
    this.depth = 10.0,
    this.baseColor,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      padding: padding ?? EdgeInsets.all(16),
      margin: margin,
      decoration: NeumorphicTheme.neumorphicCard(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

// Neumorphic Button Widget
class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;
  final bool isLoading;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.borderRadius = 12.0,
    this.depth = 6.0,
    this.baseColor,
    this.padding,
    this.margin,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        margin: widget.margin,
        decoration: NeumorphicTheme.neumorphicButton(
          borderRadius: widget.borderRadius,
          depth: widget.depth,
          baseColor: widget.baseColor,
          isPressed: isPressed,
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.baseColor ?? Colors.grey,
                  ),
                ),
              )
            : widget.child,
      ),
    );
  }
}

// Neumorphic Text Field Widget
class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? baseColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const NeumorphicTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.baseColor,
    this.borderRadius = 12.0,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeumorphicTheme.neumorphicContainer(
        borderRadius: borderRadius,
        depth: 4.0,
        baseColor: baseColor,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        decoration: NeumorphicTheme.neumorphicInput(
          hintText: hintText,
          prefixIcon: prefixIcon,
          baseColor: baseColor,
          borderRadius: borderRadius,
        ).copyWith(
          suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}

// Neumorphic App Bar Widget
class NeumorphicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? baseColor;
  final double depth;
  final bool automaticallyImplyLeading;

  const NeumorphicAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.baseColor,
    this.depth = 5.0,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeumorphicTheme.neumorphicAppBar(
        baseColor: baseColor,
        depth: depth,
      ),
      child: AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// Neumorphic Drawer Widget
class NeumorphicDrawer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final double depth;

  const NeumorphicDrawer({
    Key? key,
    required this.child,
    this.baseColor,
    this.depth = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeumorphicTheme.neumorphicDrawer(
        baseColor: baseColor,
        depth: depth,
      ),
      child: child,
    );
  }
}

// Neumorphic Floating Action Button Widget
class NeumorphicFAB extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final VoidCallback? onPressed;

  const NeumorphicFAB({
    Key? key,
    required this.child,
    this.borderRadius = 50.0,
    this.depth = 8.0,
    this.baseColor,
    this.onPressed,
  }) : super(key: key);

  @override
  State<NeumorphicFAB> createState() => _NeumorphicFABState();
}

class _NeumorphicFABState extends State<NeumorphicFAB> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: 56,
        height: 56,
        decoration: NeumorphicTheme.neumorphicFAB(
          borderRadius: widget.borderRadius,
          depth: widget.depth,
          baseColor: widget.baseColor,
          isPressed: isPressed,
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}

// Neumorphic List Tile Widget
class NeumorphicListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final EdgeInsetsGeometry? margin;

  const NeumorphicListTile({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.borderRadius = 12.0,
    this.depth = 4.0,
    this.baseColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      margin: margin,
      decoration: NeumorphicTheme.neumorphicListTile(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
      ),
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );

    return container;
  }
}

// Neumorphic Switch Widget
class NeumorphicSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final Color? activeColor;

  const NeumorphicSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.borderRadius = 25.0,
    this.depth = 4.0,
    this.baseColor,
    this.activeColor,
  }) : super(key: key);

  @override
  State<NeumorphicSwitch> createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 50,
        height: 30,
        decoration: NeumorphicTheme.neumorphicSwitch(
          borderRadius: widget.borderRadius,
          depth: widget.depth,
          baseColor: widget.baseColor,
          isActive: widget.value,
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 300),
          alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            margin: EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: widget.value ? (widget.activeColor ?? Colors.blue) : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Neumorphic Progress Indicator Widget
class NeumorphicProgressIndicator extends StatelessWidget {
  final double value;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final Color? progressColor;
  final double height;

  const NeumorphicProgressIndicator({
    Key? key,
    required this.value,
    this.borderRadius = 10.0,
    this.depth = 4.0,
    this.baseColor,
    this.progressColor,
    this.height = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: NeumorphicTheme.neumorphicProgress(
        borderRadius: borderRadius,
        depth: depth,
        baseColor: baseColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            progressColor ?? Colors.blue,
          ),
        ),
      ),
    );
  }
}

// Neumorphic Bottom Navigation Bar Widget
class NeumorphicBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? baseColor;
  final double depth;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const NeumorphicBottomNavigationBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.baseColor,
    this.depth = 8.0,
    this.selectedItemColor,
    this.unselectedItemColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeumorphicTheme.neumorphicBottomNav(
        baseColor: baseColor,
        depth: depth,
      ),
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// Neumorphic Icon Button Widget
class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final double borderRadius;
  final double depth;
  final Color? baseColor;
  final Color? iconColor;
  final VoidCallback? onPressed;

  const NeumorphicIconButton({
    Key? key,
    required this.icon,
    this.size = 48.0,
    this.borderRadius = 12.0,
    this.depth = 6.0,
    this.baseColor,
    this.iconColor,
    this.onPressed,
  }) : super(key: key);

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: widget.size,
        height: widget.size,
        decoration: NeumorphicTheme.neumorphicButton(
          borderRadius: widget.borderRadius,
          depth: widget.depth,
          baseColor: widget.baseColor,
          isPressed: isPressed,
        ),
        child: Icon(
          widget.icon,
          color: widget.iconColor ?? Colors.grey[600],
          size: widget.size * 0.4,
        ),
      ),
    );
  }
}

// Neumorphic Divider Widget
class NeumorphicDivider extends StatelessWidget {
  final double height;
  final double depth;
  final Color? baseColor;
  final EdgeInsetsGeometry? margin;

  const NeumorphicDivider({
    Key? key,
    this.height = 1.0,
    this.depth = 2.0,
    this.baseColor,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: baseColor ?? NeumorphicTheme.baseColor,
        boxShadow: [
          BoxShadow(
            color: NeumorphicTheme.darkShadow.withOpacity(0.2),
            offset: Offset(0, depth / 2),
            blurRadius: depth,
          ),
        ],
      ),
    );
  }
}

// Neumorphic Badge Widget
class NeumorphicBadge extends StatelessWidget {
  final Widget child;
  final String? label;
  final Color? backgroundColor;
  final Color? labelColor;
  final double borderRadius;
  final double depth;

  const NeumorphicBadge({
    Key? key,
    required this.child,
    this.label,
    this.backgroundColor,
    this.labelColor,
    this.borderRadius = 8.0,
    this.depth = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (label != null)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: NeumorphicTheme.neumorphicContainer(
                borderRadius: borderRadius,
                depth: depth,
                baseColor: backgroundColor ?? Colors.red,
              ),
              child: Text(
                label!,
                style: TextStyle(
                  color: labelColor ?? Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
