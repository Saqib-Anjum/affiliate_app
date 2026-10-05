import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../providers/theme_provider.dart";
import "app_logo.dart";

/// Unified top header app bar used across all screens.
/// Features the official AiDx company logo, screen title, and theme mode toggle.
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showBackButton = false,
    this.bottom,
  });

  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(60.0 + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0.5,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      titleSpacing: showBackButton ? 0 : 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AiDxLogo(height: 32),
          if (title != null && title!.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
              height: 18,
              width: 1,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white70 : const Color(0xFF64748B),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (actions != null) ...actions!,
        // App-wide Theme Toggle (Light / Dark)
        IconButton(
          tooltip: isDark ? "Switch to Light Mode" : "Switch to Dark Mode",
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? const Color(0xFFFFE600) : const Color(0xFF475569),
            size: 22,
          ),
          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
        ),
        const SizedBox(width: 8),
      ],
      bottom: bottom,
    );
  }
}
