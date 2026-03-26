import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = ThemeProviderInherited.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your experience',
              style: TextStyle(
                color: isDark ? AppTheme.textSecondary : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Appearance Section
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context: context,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Toggle dark/light theme',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // AI Settings Section
            _buildSectionTitle('AI Settings'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context: context,
              icon: Icons.language,
              title: 'Summary Language',
              subtitle: 'English',
              onTap: () {},
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.tune,
              title: 'Summary Length',
              subtitle: 'Medium',
              onTap: () {},
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.dns_outlined,
              title: 'Backend URL',
              subtitle: 'http://localhost:5000',
              onTap: () => _showBackendUrlDialog(context),
            ),
            const SizedBox(height: 24),

            // Data Section
            _buildSectionTitle('Data & Storage'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context: context,
              icon: Icons.cloud_upload_outlined,
              title: 'Backup Notes',
              subtitle: 'Export all notes',
              onTap: () {},
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.cloud_download_outlined,
              title: 'Restore Notes',
              subtitle: 'Import from backup',
              onTap: () {},
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.delete_outline,
              title: 'Clear History',
              subtitle: 'Remove all summary history',
              onTap: () => _showClearHistoryDialog(context),
              isDestructive: true,
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            _buildSettingsTile(
              context: context,
              icon: Icons.info_outline,
              title: 'Version',
              subtitle: '1.0.0',
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.code,
              title: 'GitHub',
              subtitle: 'View source code',
              onTap: () {},
            ),
            _buildSettingsTile(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {},
            ),
            const SizedBox(height: 40),

            // Backend Connection Guide
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.accentCyan.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.integration_instructions,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Python Backend Setup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Run the Python backend server\n'
                    '2. Update the Backend URL above\n'
                    '3. Start summarizing with AI!',
                    style: TextStyle(
                      color: isDark ? AppTheme.textSecondary : Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('View Setup Guide'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDestructive ? Colors.red : AppTheme.primaryColor)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppTheme.textMuted : Colors.grey[500],
          ),
        ),
        trailing: trailing ??
            (onTap != null
                ? Icon(
                    Icons.chevron_right,
                    color: isDark ? AppTheme.textMuted : Colors.grey[400],
                  )
                : null),
      ),
    );
  }

  void _showBackendUrlDialog(BuildContext context) {
    final controller = TextEditingController(text: 'http://localhost:5000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your Python backend URL',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save backend URL
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all summary history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Clear history
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
