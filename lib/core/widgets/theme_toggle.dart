import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';

/// Reusable theme toggle widget
/// 
/// Displays an animated icon button that toggles between light and dark mode.
/// Can be placed in AppBar, Settings, or anywhere else.
class ThemeToggle extends StatelessWidget {
  final double? iconSize;
  final Color? iconColor;
  final String? tooltip;

  const ThemeToggle({
    super.key,
    this.iconSize,
    this.iconColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return IconButton(
      onPressed: () async {
        await themeProvider.toggleTheme();
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(themeProvider.isDark),
          size: iconSize ?? 24,
          color: iconColor ?? Theme.of(context).iconTheme.color,
        ),
      ),
      tooltip: tooltip ?? (themeProvider.isDark ? 'Light Mode' : 'Dark Mode'),
    );
  }
}

/// Compact theme toggle with label
/// 
/// Useful for settings pages.
class ThemeToggleWithLabel extends StatelessWidget {
  const ThemeToggleWithLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListTile(
      leading: Icon(
        themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        'Dark Mode',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        themeProvider.isDark ? 'Enabled' : 'Disabled',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Switch(
        value: themeProvider.isDark,
        onChanged: (value) async {
          await themeProvider.setTheme(value);
        },
        activeColor: Theme.of(context).colorScheme.primary,
      ),
      onTap: () async {
        await themeProvider.toggleTheme();
      },
    );
  }
}
