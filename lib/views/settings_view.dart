import 'package:code_vault/views/settings/connected_devices_section.dart';
import 'package:code_vault/views/settings/server_section.dart';
import 'package:code_vault/views/settings/theme_section.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ServerSection(),
          ConnectedDevicesSection(),
          SizedBox(height: 24),
          ThemeSection(),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
