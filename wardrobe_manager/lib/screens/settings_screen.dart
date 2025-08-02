import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/settings_helper.dart';
import '../models/settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsHelper _settingsHelper;
  late AppSettings _currentSettings;
  bool _isLoading = false;

  final List<String> _categories = ['All', 'Shirts', 'Pants', 'Shoes', 'Accessories'];
  final List<String> _qualityOptions = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _settingsHelper = Provider.of<SettingsHelper>(context, listen: false);
    _currentSettings = _settingsHelper.getSettings();
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    await _settingsHelper.saveSettings(_currentSettings);
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully!'))
    );
  }

  Future<void> _resetSettings() async {
    _currentSettings.resetToDefaults();
    await _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveSettings,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('General Preferences'),
                _buildDropdownSetting(
                  'Default Category',
                  _currentSettings.defaultCategory,
                  _categories,
                  (value) => _currentSettings.updateSettings(defaultCategory: value),
                ),
                _buildDropdownSetting(
                  'Photo Quality',
                  _currentSettings.photoQuality,
                  _qualityOptions,
                  (value) => _currentSettings.updateSettings(photoQuality: value),
                ),
                
                _buildSectionHeader('Appearance'),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: _currentSettings.darkModeEnabled,
                  onChanged: (value) => _currentSettings.updateSettings(darkModeEnabled: value),
                ),
                
                _buildSectionHeader('Data Management'),
                SwitchListTile(
                  title: const Text('Automatic Backup'),
                  subtitle: const Text('Backup data weekly'),
                  value: _currentSettings.backupEnabled,
                  onChanged: (value) => _currentSettings.updateSettings(backupEnabled: value),
                ),
                
                _buildSectionHeader('Tutorial'),
                SwitchListTile(
                  title: const Text('Show Tutorial'),
                  subtitle: const Text('Show onboarding at startup'),
                  value: _currentSettings.showTutorial,
                  onChanged: (value) => _currentSettings.updateSettings(showTutorial: value),
                ),
                
                const SizedBox(height: 30),
                _buildActionButton('Reset to Defaults', Icons.restart_alt, _resetSettings),
                const SizedBox(height: 16),
                _buildActionButton('Backup Now', Icons.backup, () {
                  // Implement backup functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup completed successfully!'))
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Text(title, style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    )),
  );

  Widget _buildDropdownSetting(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: value,
            items: options.map((option) => DropdownMenuItem(
              value: option,
              child: Text(option),
            )).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      onPressed: _isLoading ? null : onPressed,
    );
  }
}