import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        children: [
          _buildSection('Giao diện', [
            _buildThemeSelector(context),
            _buildLanguageSelector(),
          ]),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildSection('Thông báo', [
            _buildNotificationToggle('Thông báo đơn hàng', true),
            _buildNotificationToggle('Thông báo khuyến mãi', true),
            _buildNotificationToggle('Thông báo hệ thống', false),
            _buildNotificationToggle('Thông báo push', true),
          ]),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildSection('Bảo mật', [
            _buildSecurityItem('Đổi mật khẩu', Icons.lock_outline),
            _buildSecurityItem('Xác thực 2 bước', Icons.security),
            _buildSecurityItem('Quản lý thiết bị', Icons.devices),
          ]),
          const SizedBox(height: AppDimensions.spacingLarge),
          _buildSection('Dữ liệu', [
            _buildDataItem('Xóa cache', Icons.cleaning_services),
            _buildDataItem('Sao lưu dữ liệu', Icons.backup),
            _buildDataItem('Khôi phục dữ liệu', Icons.restore),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMedium),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Chế độ giao diện'),
          subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context, themeProvider),
        );
      },
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: const Text('Ngôn ngữ'),
      subtitle: const Text('Tiếng Việt'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Show language selection dialog
      },
    );
  }

  Widget _buildNotificationToggle(String title, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (value) {
        // TODO: Update notification settings
      },
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSecurityItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Navigate to security settings
      },
    );
  }

  Widget _buildDataItem(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: Handle data operations
      },
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Theo hệ thống';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn chế độ giao diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Sáng'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Tối'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Theo hệ thống'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setThemeMode(value!);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}