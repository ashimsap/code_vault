import 'package:code_vault/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_vault/providers/providers.dart';

class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeSettings = ref.watch(themeProvider);

    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Theme', style: TextStyle(fontSize: 16)),
                Switch(
                  value: themeSettings.themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    ref.read(themeProvider.notifier).setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
                  },
                  thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
                    return Icon(states.contains(MaterialState.selected) ? Icons.dark_mode : Icons.light_mode);
                  }),
                ),
              ],
            ),
            const Divider(height: 32),
            const Text('Accent Color', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: accentThemes.length,
              itemBuilder: (context, index) {
                final accent = accentThemes[index];
                final bool isActive = accent.name == themeSettings.accentTheme.name;
                return InkWell(
                  onTap: () => ref.read(themeProvider.notifier).setAccentTheme(accent),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accent.color,
                      shape: BoxShape.circle,
                      border: isActive ? Border.all(color: theme.colorScheme.onSurface, width: 3) : null,
                    ),
                    child: isActive ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
