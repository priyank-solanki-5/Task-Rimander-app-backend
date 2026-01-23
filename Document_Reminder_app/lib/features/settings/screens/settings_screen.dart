import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  bool _isLoading = true;
  UserSettings _settings = UserSettings();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _authService.getUserSettings();
    if (mounted) {
      setState(() {
        if (settings != null) {
          _settings = settings;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(UserSettings newSettings) async {
    // Optimistic update
    setState(() => _settings = newSettings);

    final success = await _authService.updateUserSettings(newSettings);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update settings'),
            backgroundColor: Colors.red,
          ),
        );
        // Revert on failure
        _loadSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader('Appearance'),
                  _buildDropdownTile(
                    title: 'Theme',
                    value: _settings.theme,
                    items: const ['light', 'dark', 'system'],
                    onChanged: (val) {
                      if (val != null) {
                        _updateSettings(
                          UserSettings.fromJson({
                            ..._settings.toJson(),
                            'theme': val,
                          }),
                        );
                      }
                    },
                  ),
                  const Divider(),
                  _buildSectionHeader('Localization'),
                  _buildDropdownTile(
                    title: 'Language',
                    value: _settings.language,
                    items: const ['en', 'es', 'fr', 'de'],
                    onChanged: (val) {
                      if (val != null) {
                        _updateSettings(
                          UserSettings.fromJson({
                            ..._settings.toJson(),
                            'language': val,
                          }),
                        );
                      }
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Date Format',
                    value: _settings.dateFormat,
                    items: const ['YYYY-MM-DD', 'DD/MM/YYYY', 'MM/DD/YYYY'],
                    onChanged: (val) {
                      if (val != null) {
                        _updateSettings(
                          UserSettings.fromJson({
                            ..._settings.toJson(),
                            'dateFormat': val,
                          }),
                        );
                      }
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Time Format',
                    value: _settings.timeFormat,
                    items: const ['12h', '24h'],
                    onChanged: (val) {
                      if (val != null) {
                        _updateSettings(
                          UserSettings.fromJson({
                            ..._settings.toJson(),
                            'timeFormat': val,
                          }),
                        );
                      }
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Week Starts On',
                    value: _settings.weekStartsOn,
                    items: const ['monday', 'sunday'],
                    onChanged: (val) {
                      if (val != null) {
                        _updateSettings(
                          UserSettings.fromJson({
                            ..._settings.toJson(),
                            'weekStartsOn': val,
                          }),
                        );
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: items.contains(value) ? value : items.first,
        underline: const SizedBox(),
        items: items.map((e) {
          return DropdownMenuItem(value: e, child: Text(e.toUpperCase()));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
