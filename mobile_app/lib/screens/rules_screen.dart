import 'package:flutter/material.dart';
import 'package:mobile_app/models/app_models.dart';
import 'package:mobile_app/widgets/common.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key, required this.rules});
  final List<NotificationRule> rules;

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Admin · Routing', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Text('Notification Rules', style: Theme.of(context).textTheme.titleLarge)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New rule'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.rules.map((rule) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(rule.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      Switch(
                        value: rule.enabled,
                        onChanged: (value) => setState(() => rule.enabled = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Edited ${rule.editedAt}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...rule.recipients.map((r) => Chip(label: Text(r))),
                      ...rule.channels.map(
                        (c) => Chip(
                          avatar: Icon(channelIcon(c), size: 16),
                          label: Text(channelLabel(c)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
