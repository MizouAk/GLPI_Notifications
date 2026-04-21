import 'package:flutter/material.dart';
import 'package:mobile_app/theme/app_colors.dart';
import 'package:mobile_app/widgets/common.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool inApp = true;
  bool email = true;
  bool sms = false;
  bool quietHours = true;
  String frequency = 'instant';
  String language = 'English';
  String timezone = 'Europe/Paris';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Personal · Settings', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text('My Notification Preferences', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SurfaceCard(
          child: Column(
            children: [
              _switchTile('In-app', 'Inbox and bell menu inside GLPI.', inApp, (v) => setState(() => inApp = v)),
              _switchTile('Email', 'Sent to your work address.', email, (v) => setState(() => email = v)),
              _switchTile('SMS / WhatsApp', 'For SLA breaches and on-call only.', sms, (v) => setState(() => sms = v)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ['instant', 'hourly_digest', 'daily_summary'].map((item) {
                  return ChoiceChip(
                    label: Text(item.replaceAll('_', ' ')),
                    selected: frequency == item,
                    onSelected: (_) => setState(() => frequency = item),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            children: [
              SwitchListTile(
                value: quietHours,
                onChanged: (value) => setState(() => quietHours = value),
                title: const Text('Quiet hours'),
                subtitle: const Text('Critical SLA alerts always bypass quiet hours.'),
                contentPadding: EdgeInsets.zero,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      enabled: quietHours,
                      decoration: const InputDecoration(labelText: 'From', hintText: '20:00'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      enabled: quietHours,
                      decoration: const InputDecoration(labelText: 'To', hintText: '07:30'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Locale', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: language,
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'Français', child: Text('Français')),
                  DropdownMenuItem(value: 'Português', child: Text('Português')),
                ],
                onChanged: (value) => setState(() => language = value ?? language),
                decoration: const InputDecoration(labelText: 'Language'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: timezone,
                items: const [
                  DropdownMenuItem(value: 'Europe/Paris', child: Text('Europe/Paris')),
                  DropdownMenuItem(value: 'Europe/London', child: Text('Europe/London')),
                  DropdownMenuItem(value: 'America/New_York', child: Text('America/New_York')),
                ],
                onChanged: (value) => setState(() => timezone = value ?? timezone),
                decoration: const InputDecoration(labelText: 'Timezone'),
              ),
              const SizedBox(height: 8),
              const Text('Muted tickets: INC-10018', style: TextStyle(color: AppColors.mutedForeground)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _switchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }
}
